//
//  AVPlayerVPVC.m
//  LvDemos
//
//  Created by guangbo on 15/4/2.
//
//

#import "AVPlayerVPVC.h"

NSString *const AVPlayerVPVCDidPlayNotification = @"AVPlayerVPVCDidPlayNotification";
NSString *const AVPlayerVPVCDidPauseNotification = @"AVPlayerVPVCDidPauseNotification";

static NSString *const kAVPlayerVPVC = @"AVPlayerVPVC";

static void *VPVCPlayerStatusObserverContext = &VPVCPlayerStatusObserverContext;
static void *VPVCPlayerLoadRangesObserverContext = &VPVCPlayerLoadRangesObserverContext;

@interface AVPlayerVPVC ()

@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerLayer *playerLayer;
@property (nonatomic) AVPlayerItem *playerItem;
@property (nonatomic) id playbackTimeObserver;

@property (nonatomic) BOOL hasPreparedToPlay;
@property (nonatomic) BOOL playAfterPrepared;

@end

@implementation AVPlayerVPVC

- (instancetype)initWithThemeStyle:(VideoPlayerThemeStyle)themeStyle controlBarMode:(VideoPlayerControlBarMode)controlBarMode
{
    if (self = [super initWithThemeStyle:themeStyle controlBarMode:controlBarMode]) {
        _player = [[AVPlayer alloc] init];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPlayerLayer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recvPlayToEndTimeNote:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    [self.player pause];
    
    if (_playerItem) {
        // 状态
        [_playerItem removeObserver:self forKeyPath:@"status" context:VPVCPlayerStatusObserverContext];
        // 缓冲进度
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:VPVCPlayerLoadRangesObserverContext];
    }
    
    // 监听播放进度
    if (_playbackTimeObserver) {
        [_player removeTimeObserver:_playbackTimeObserver];
        _playbackTimeObserver = nil;
    }
}

- (void)viewDidLayoutSubviews
{
    self.playerLayer.frame = self.playerContainnerView.layer.bounds;
}

- (void)setupPlayerLayer
{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [self.playerContainnerView.layer addSublayer:_playerLayer];
    }
}


- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem) {
        // 状态
        [_playerItem removeObserver:self forKeyPath:@"status" context:VPVCPlayerStatusObserverContext];
        // 缓冲进度
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:VPVCPlayerLoadRangesObserverContext];
        _playerItem = nil;
    }
    
    _playerItem = playerItem;
    
    // 监听状态和缓冲进度
    if (_playerItem) {
        [_playerItem addObserver:self
                      forKeyPath:@"status"
                         options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                         context:VPVCPlayerStatusObserverContext];
        [_playerItem addObserver:self
                      forKeyPath:@"loadedTimeRanges"
                         options:NSKeyValueObservingOptionNew
                         context:VPVCPlayerLoadRangesObserverContext];
    }
    
    // 监听播放进度
    if (_playbackTimeObserver) {
        [_player removeTimeObserver:_playbackTimeObserver];
        _playbackTimeObserver = nil;
    }
    
    if (_playerItem) {
        __weak AVPlayerVPVC *weakSelf = self;
        _playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
            // 更新界面
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf refreshCurrentPlayProgress];
            });
        }];
    }
    
    [self.player replaceCurrentItemWithPlayerItem:_playerItem];
}

- (AVPlayerItem *)currentPlayerItem
{
    return self.player.currentItem;
}

- (NSTimeInterval)secsForCMTime:(CMTime)time
{
    NSTimeInterval secs = 0;
    if (CMTIME_IS_NUMERIC(time)) {
        secs = CMTimeGetSeconds(time);
    }
    return secs;
}

#pragma mark - Notifications

- (void)recvPlayToEndTimeNote:(NSNotification *)note
{
    [self reset];
    [[NSNotificationCenter defaultCenter] postNotificationName:VPVCPlayerItemDidPlayToEndTimeNotification
                                                        object:self];
}


#pragma mark - KVO Observer method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (VPVCPlayerStatusObserverContext == context) {
        id newValue = change[NSKeyValueChangeNewKey];
        if (newValue && [newValue isKindOfClass:[NSNumber class]]) {
            [self handleWhenPlayerItemChangedStatus:((NSNumber *)newValue).integerValue];
        }
        return;
    }
    
    if (VPVCPlayerLoadRangesObserverContext == context) {
        [self handleWhenPlayerItemLoadedTimeRangesChanged];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (NSTimeInterval)loadedProgressDurationOfPlayerItem:(AVPlayerItem *)playerItem {
    if (!playerItem)
        return 0;
    
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    if (loadedTimeRanges.count == 0) {
        return 0;
    }
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    return startSeconds + durationSeconds;// 计算缓冲总进度
}

- (void)handleWhenPlayerItemChangedStatus:(AVPlayerItemStatus)status
{
    if (!self.player) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopActivityLoading];
    });
    
    switch (status) {
        case AVPlayerItemStatusReadyToPlay:
        {
            NSLog(@"AVPlayerStatusReadyToPlay");
            self.hasPreparedToPlay = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:VPVCPlayerItemReadyToPlayNotification object:self];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCurrentPlayProgress];
                
                // 是否立即播放
                if (self.playAfterPrepared) {
                    [self.player play];
                    
                    [self stopActivityLoading];
                    [self dismissPlayerNavAndControlPanel];
                    [self setPlayButttonPaused];
                }
            });
            
            break;
        }
        case AVPlayerItemStatusFailed:
            NSLog(@"AVPlayerItemStatusFailed");
            self.hasPreparedToPlay = NO;
            break;
        default:
            self.hasPreparedToPlay = NO;
            break;
    }
}

- (void)handleWhenPlayerItemLoadedTimeRangesChanged
{
    if (!self.player) {
        return;
    }
    
    AVPlayerItem *currentItem = [self.player currentItem];
    NSTimeInterval loadedProgress = [self loadedProgressDurationOfPlayerItem:currentItem];// 计算缓冲进度
    
    CMTime currentTime = currentItem.currentTime;
    NSTimeInterval currentSecs = CMTimeGetSeconds(currentTime);
    
    if (currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (loadedProgress < currentSecs) {
            // TODO: 提示暂停一下
        }
    }
}

- (void)reset
{
    [self.player pause];
    
    AVPlayerItem *currentItem = self.player.currentItem;
    if (currentItem) {
        __weak typeof(self)weakSelf = self;
        [currentItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished){
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf resetPlayControlView];
            });
        }];
    } else {
        [self resetPlayControlView];
    }
}



- (void)seekToTime:(NSTimeInterval)time
{
    AVPlayerItem *currentItem = self.player.currentItem;
    if (currentItem) {
        __weak typeof(self)weakSelf = self;
        [currentItem seekToTime:CMTimeMakeWithSeconds(time, 60) completionHandler:^(BOOL finished){
            if (finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf stopActivityLoading];
                });
            }
        }];
    }
}


#pragma mark - Override

- (BOOL)isPlaying
{
    return (self.player.rate == 1);
}

- (void)preparePlayURL:(NSURL *)videoURL immediatelyPlay:(BOOL)immediatelyPlay
{
    _videoURL = videoURL;
    self.playAfterPrepared = immediatelyPlay;
    if (videoURL) {
        // 准备好新的播放item
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoURL];
        self.playerItem = item;
    } else {
        self.playerItem = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startActivityLoading];
    });
}


- (void)play
{
    self.playAfterPrepared = YES;
    if (self.hasPreparedToPlay) {
        if (!self.isPlaying) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setPlayButttonPaused];
            });
            
            [[NSNotificationCenter defaultCenter]postNotificationName:AVPlayerVPVCDidPlayNotification
                                                               object:self];
            
            [self.player play];
        }
    }
}

- (void)pause
{
    self.playAfterPrepared = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setPlayButttonPlaying];
        [self stopActivityLoading];
    });
    
    [[NSNotificationCenter defaultCenter]postNotificationName:AVPlayerVPVCDidPauseNotification
                                                       object:self];
    
    [self.player pause];
}

- (void)stop
{
    
}


- (void)clickPlayPauseButton
{
    AVPlayer *thePlayer = self.player;
    if (thePlayer.rate == 0) {
        [self play];
    } else if (thePlayer.rate == 1){
        // playing
        [self pause];
    }
}


- (void)clickPlayPreviousButton
{
//    [self pause];
}


- (void)clickPlayNextButton
{
//    [self pause];
}


- (void)seekToPosition:(CGFloat)position
{
    [self seekToTime:position/1000.f];
}


- (void)didSetFullScreenCanvas
{
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
}

- (void)didSet100PercentCanvas
{
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (CGFloat)currentVideoDuration
{
    AVPlayerItem *currentItem = [self currentPlayerItem];
    if (currentItem) {
        return [self secsForCMTime:currentItem.duration] * 1000.f;
    }
    return 0;
}

- (CGFloat)currentVideoPlayPosition
{
    AVPlayerItem *currentItem = [self currentPlayerItem];
    if (currentItem) {
        return [self secsForCMTime:currentItem.currentTime] * 1000.f;
    }
    return 0;
}

- (void)didVPVCReceiveApplicationDidEnterForegroundNotification
{
    if (!self.isPlaying)
        [self play];
}

- (void)didVPVCReceiveApplicationDidEnterBackgroundNotification
{
    if (self.isPlaying)
        [self pause];
}

@end
