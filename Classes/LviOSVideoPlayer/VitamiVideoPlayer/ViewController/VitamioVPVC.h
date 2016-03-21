//
//  VitamioVPVC.h
//  LvDemos
//
//  Created by guangbo on 15/4/2.
//
//

#import "BaseVPVC.h"
#import "Vitamio.h"

/**
 *  播放器播放通知
 */
extern NSString *const VitamioVPVCDidPlayNotification;
/**
 *  播放器暂停通知
 */
extern NSString *const VitamioVPVCDidPauseNotification;

/**
 *  使用第三方Vitamio播放器的VC
 */
@interface VitamioVPVC : BaseVPVC

@property (nonatomic, readonly) NSURL *videoURL;

#pragma mark - Override

// 是否在播放
- (BOOL)isPlaying;

- (void)preparePlayURL:(NSURL *)videoURL header:(NSString *)header immediatelyPlay:(BOOL)immediatelyPlay;
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
