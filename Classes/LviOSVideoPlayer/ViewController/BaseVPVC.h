//
//  BaseVPVC.h
//  LvDemos
//
//  Created by guangbo on 15/4/2.
//
//

#import <UIKit/UIKit.h>
#import "VideoPlayerConstants.h"

/**
 *  VPVC里播放的节目播放结束的通知
 */
extern NSString *const VPVCPlayerItemDidPlayToEndTimeNotification;

/**
 *  准备好播放的通知
 */
extern NSString *const VPVCPlayerItemReadyToPlayNotification;

/**
 *  VPVC播放上一个视频的通知
 */
extern NSString *const VPVCPlayPreviousVideoItemNotifiction;

/**
 *  VPVC播放下一个视频的通知
 */
extern NSString *const VPVCPlayNextVideoItemNotification;

/**
 *  VPVC页面关闭的通知
 */
extern NSString *const VPVCDismissNotification;

/**
 *  变化了震动强度的通知，在通知的userInfo中使用VPVCVibrationStrengthKey获取类型为NSNumber的强度值, 介于0-1之间
 */
extern NSString *const VPVCUpdateVibrationStrengthNotification;
extern NSString *const VPVCVibrationStrengthKey;

/**
 *  蓝牙按钮点击事件
 */
extern NSString *const VPVCBluetoothButtonClickNotification;

/**
 视频清晰度变化按钮点击事件，在通知的 userInfo 中使用 VPVCVideoDefinitionChangedTypeKey 获取类型为NSNumber的清晰度值，它们都是由
 */
extern NSString *const VPVCVideoDefinitionChangedNoficiation;

/**
 变化的视频清晰度类型值
 */
extern NSString *const VPVCVideoDefinitionChangedTypeKey;


/**
 *  视频播放VC基类
 */
@interface BaseVPVC : UIViewController

// 播放器承载视图, 自定义的播放器可以放到它里面
@property (nonatomic, readonly) UIView *playerContainnerView;

// 震动强度, 介于0-1之间
@property (nonatomic, readonly) CGFloat vibrationStrength;

@property (nonatomic) NSArray *supportVideoDefinitions;     /** 支持的视频清晰度, 类型为NSNumber的VideoPlayerVideoDefinition类型 */
@property (nonatomic) VideoPlayerVideoDefinition videoDefinition; /** 当前视频清晰度 */

@property (nonatomic, readonly) VideoPlayerThemeStyle themeStyle;
@property (nonatomic, readonly) VideoPlayerControlBarMode controlBarMode;

#pragma mark - Implements on self

- (instancetype)initWithThemeStyle:(VideoPlayerThemeStyle)themeStyle controlBarMode:(VideoPlayerControlBarMode)controlBarMode;

// 设置播放按钮为暂停
- (void)setPlayButttonPaused;
// 设置播放按钮为播放
- (void)setPlayButttonPlaying;

// 刷新进度呈现，会设置播放时间、进度条河剩余时间
- (void)refreshCurrentPlayProgress;

/**
 *  设备开机按钮快进值，单位秒
 */
- (NSTimeInterval)deviceBootButtonFastForwardSeekValue;

/**
 *  启动/结束加载视图
 */
- (void)startActivityLoading;
- (void)stopActivityLoading;

/**
 *  重置播放控件到初始状态
 */
- (void)resetPlayControlView;

/**
 *  显示控件，过段时间隐藏
 *  @param dismissDelay 隐藏时间间隔，>0 时才有效
 */
- (void)showPlayerNavAndControlPanelWithDismissDelay:(NSTimeInterval)dismissDelay;

/**
 *  隐藏播放控件导航栏
 */
- (void)dismissPlayerNavAndControlPanel;

#pragma mark - Override in sub classes

// 是否在播放
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;

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

// 收到进入前台的通知
- (void)didVPVCReceiveApplicationDidEnterForegroundNotification;

// 收到进入后台的通知
- (void)didVPVCReceiveApplicationDidEnterBackgroundNotification;

@end
