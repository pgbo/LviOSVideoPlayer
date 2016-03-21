//
//  AVPlayerVPVC.h
//  LvDemos
//
//  Created by guangbo on 15/4/2.
//
//

#import "BaseVPVC.h"
#import <AVFoundation/AVFoundation.h>

extern NSString *const AVPlayerVPVCDidPlayNotification;
extern NSString *const AVPlayerVPVCDidPauseNotification;

/**
 *  用AVPlayer实现的
 */
@interface AVPlayerVPVC : BaseVPVC

@property (nonatomic, readonly) NSURL *videoURL;
// 现在播放的视频
@property (nonatomic, readonly) AVPlayerItem *currentPlayerItem;

#pragma mark - Override

// 是否在播放
- (BOOL)isPlaying;

- (void)preparePlayURL:(NSURL *)videoURL immediatelyPlay:(BOOL)immediatelyPlay;
- (void)play;
- (void)pause;
- (void)stop;

// 点击播放/暂停按钮
- (void)clickPlayPauseButton;
// 点击播放上一个按钮
- (void)clickPlayPreviousButton;
// 点击播放下一个按钮
- (void)clickPlayNextButton;

// 播放到某个进度, 单位为秒
- (void)seekToPosition:(CGFloat)position;

/**
 *  设置屏幕模式
 */
- (void)didSetFullScreenCanvas;
- (void)didSet100PercentCanvas;


// 当前视频的时长，单位是毫秒
- (CGFloat)currentVideoDuration;
// 当前视频播放位置，单位是毫秒
- (CGFloat)currentVideoPlayPosition;

- (void)didVPVCReceiveApplicationDidEnterForegroundNotification;
- (void)didVPVCReceiveApplicationDidEnterBackgroundNotification;

@end
