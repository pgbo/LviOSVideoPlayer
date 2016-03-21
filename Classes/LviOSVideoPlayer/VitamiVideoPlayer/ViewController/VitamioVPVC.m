//
//  VitamioVPVC.m
//  LvDemos
//
//  Created by guangbo on 15/4/2.
//
//

#import "VitamioVPVC.h"

NSString *const VitamioVPVCDidPlayNotification = @"VitamioVPVCDidPlayNotification";
NSString *const VitamioVPVCDidPauseNotification = @"VitamioVPVCDidPauseNotification";

static NSString *const kVitamioVPVC = @"VitamioVPVC";

@interface VitamioVPVC () <VMediaPlayerDelegate>

@property (nonatomic) UIView *playerCanvasView;
@property (nonatomic) VMediaPlayer *player;
@property (nonatomic) long currentVideoItemDuration;
@property (nonatomic) BOOL hasPreparedToPlay;
@property (nonatomic) BOOL playAfterPrepared;
@property (nonatomic) NSTimer *videoStatusPullTimer;

@end

@implementation VitamioVPVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPlayerAndCanvasView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.videoStatusPullTimer invalidate];
    self.playAfterPrepared = NO;
    self.hasPreparedToPlay = NO;
    
    [self.player pause];
    [self.player reset];
    [self.player unSetupPlayer];
    
}

- (void)setupPlayerAndCanvasView
{
    if (!_playerCanvasView) {
        UIView *canvasV = [[UIView alloc]initWithFrame:self.view.bounds];
        canvasV.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.playerContainnerView addSubview:canvasV];
        _playerCanvasView = canvasV;
    }
    if (!_player) {
        _player = [VMediaPlayer sharedInstance];
        [_player setupPlayerWithCarrierView:self.playerCanvasView withDelegate:self];
        [_player setVideoFillMode:VMVideoFillModeFit];
    }
}


- (void)pulledVideoStatus:(NSTimer *)timer
{
    if (self.currentVideoItemDuration > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshCurrentPlayProgress];
        });
    }
}

#pragma mark VMediaPlayerDelegate Implement / Required

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    NSLog(@"mediaPlayer:didPrepared");
    self.hasPreparedToPlay = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VPVCPlayerItemReadyToPlayNotification object:self];
    
    self.currentVideoItemDuration = [player getDuration];
    if (self.playAfterPrepared) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [self.player start];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissPlayerNavAndControlPanel];
            [self setPlayButttonPaused];
            [self stopActivityLoading];
            [self refreshCurrentPlayProgress];
            
            [self.videoStatusPullTimer invalidate];
            self.videoStatusPullTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/3
                                                                         target:self
                                                                       selector:@selector(pulledVideoStatus:)
                                                                       userInfo:nil
                                                                        repeats:YES];
        });
    }
}

- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    NSLog(@"playbackComplete");
    
    self.hasPreparedToPlay = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoStatusPullTimer invalidate];
        [self resetPlayControlView];
        [self showPlayerNavAndControlPanelWithDismissDelay:5.f];
    });
    
    [self.player pause];
    [self.player seekTo:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VPVCPlayerItemDidPlayToEndTimeNotification
                                                        object:self];
}

- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    NSLog(@"play failed, err: %@", arg);
    self.hasPreparedToPlay = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopActivityLoading];
        [self showPlayerNavAndControlPanelWithDismissDelay:-1.f];
    });
}

#pragma mark VMediaPlayerDelegate Implement / Optional

- (void)mediaPlayer:(VMediaPlayer *)player setupManagerPreference:(id)arg
{
    player.decodingSchemeHint = VMDecodingSchemeSoftware;
    player.autoSwitchDecodingScheme = NO;
}

- (void)mediaPlayer:(VMediaPlayer *)player setupPlayerPreference:(id)arg
{
    // Set buffer size, default is 1024KB(1*1024*1024).
    //	[player setBufferSize:256*1024];
    [player setBufferSize:512*1024];
    //	[player setAdaptiveStream:YES];
    
    [player setVideoQuality:VMVideoQualityMedium];
    
    //    player.useCache = YES;
    //    [player setCacheDirectory:[self getCacheRootDirectory]];
}

- (void)mediaPlayer:(VMediaPlayer *)player seekComplete:(id)arg
{
    NSLog(@"seekComplete");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopActivityLoading];
    });
}

- (void)mediaPlayer:(VMediaPlayer *)player notSeekable:(id)arg
{
    NSLog(@"notSeekable");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopActivityLoading];
    });
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg
{
    NSLog(@"开始缓冲");
    
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg
{
    NSLog(@"缓冲变化");
}

- (void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg
{
    NSLog(@"结束缓冲");
}

- (void)mediaPlayer:(VMediaPlayer *)player downloadRate:(id)arg
{
    
}

- (void)mediaPlayer:(VMediaPlayer *)player videoTrackLagging:(id)arg
{
    // TODO:提示暂停一下
}

#pragma mark VMediaPlayerDelegate Implement / Cache

- (void)mediaPlayer:(VMediaPlayer *)player cacheNotAvailable:(id)arg
{
    NSLog(@"不能缓存");
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheStart:(id)arg
{
    NSLog(@"开始缓存");
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheUpdate:(id)arg
{
    NSLog(@"缓冲变化");
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheSpeed:(id)arg
{
    //	NSLog(@"NAL .... media cacheSpeed: %dKB/s", [(NSNumber *)arg intValue]);
}

- (void)mediaPlayer:(VMediaPlayer *)player cacheComplete:(id)arg
{
    NSLog(@"NAL .... media cacheComplete");
}


#pragma mark - Override

// 是否在播放
- (BOOL)isPlaying
{
    return self.player.isPlaying;
}

- (void)preparePlayURL:(NSURL *)videoURL header:(NSString *)header immediatelyPlay:(BOOL)immediatelyPlay
{
    [self.player reset];
    _videoURL = videoURL;
    self.playAfterPrepared = immediatelyPlay;
    if (self.player) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetPlayControlView];
            [self startActivityLoading];
        });
        [self.player setDataSource:videoURL header:header];
        [self.player prepareAsync];
    }
}

- (void)play
{
    self.playAfterPrepared = YES;
    if (self.hasPreparedToPlay) {
        if (!self.player.isPlaying) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setPlayButttonPaused];
            });
            
            [[NSNotificationCenter defaultCenter]postNotificationName:VitamioVPVCDidPlayNotification
                                                               object:self];
            [self.player start];
        }
    }
}

- (void)pause
{
    self.playAfterPrepared = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setPlayButttonPlaying];
    });
    if (self.player.isPlaying) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:VitamioVPVCDidPauseNotification
                                                           object:self];
        
        [self.player pause];
    }
}

- (void)stop
{
    [self pause];
    [self.player reset];
}

- (void)clickPlayPauseButton
{
    if (!self.isPlaying) {
        [self play];
    } else {
        [self pause];
    }
}


- (void)clickPlayPreviousButton
{
    [self pause];
}


- (void)clickPlayNextButton
{
    [self pause];
}


- (void)seekToPosition:(CGFloat)position
{
    [self.player seekTo:position];
}


- (void)didSetFullScreenCanvas
{
    [self.player setVideoFillMode:VMVideoFillModeStretch];
}

- (void)didSet100PercentCanvas
{
    [self.player setVideoFillMode:VMVideoFillMode100];
}

- (CGFloat)currentVideoDuration
{
    return self.currentVideoItemDuration;
}

- (CGFloat)currentVideoPlayPosition
{
    return [self.player getCurrentPosition];
}

- (void)didVPVCReceiveApplicationDidEnterForegroundNotification
{
    [_player setVideoShown:YES];
    if (![_player isPlaying]) {
        [_player start];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setPlayButttonPaused];
        });
    }
}

- (void)didVPVCReceiveApplicationDidEnterBackgroundNotification
{
    if ([_player isPlaying]) {
        [_player pause];
        [_player setVideoShown:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setPlayButttonPlaying];
        });
    }
}

@end
