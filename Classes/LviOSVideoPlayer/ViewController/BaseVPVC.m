//
//  BaseVPVC.m
//  LvDemos
//
//  Created by guangbo on 15/4/2.
//
//

#import "BaseVPVC.h"
#import "VPNavigationBar.h"
#import "VPPlayControlView.h"
#import "VPSettingPanelView.h"
#import "DurationFormat.h"
#import "LvDirectionPanControl.h"
#import "VPCommonIndicator.h"
#import "VPFastSeekIndicator.h"
#import "VPVideoDefinitionMenuView.h"

#import <LvModelWindow/LvModelWindow.h>

NSString *const VPVCPlayerItemDidPlayToEndTimeNotification = @"VPVCPlayerItemDidPlayToEndTimeNotification";

NSString *const VPVCPlayerItemReadyToPlayNotification = @"VPVCPlayerItemReadyToPlayNotification";

NSString *const VPVCPlayPreviousVideoItemNotifiction = @"VPVCPlayPreviousVideoItemNotifiction";

NSString *const VPVCPlayNextVideoItemNotification = @"VPVCPlayNextVideoItemNotification";

NSString *const VPVCDismissNotification = @"VPVCDismissNotification";

NSString *const VPVCUpdateVibrationStrengthNotification = @"VPVCUpdateVibrationStrengthNotification";
NSString *const VPVCVibrationStrengthKey = @"VPVCVibrationStrength";

NSString *const VPVCBluetoothButtonClickNotification = @"VPVCBluetoothButtonClickNotification";

NSString *const VPVCVideoDefinitionChangedNoficiation = @"VPVCVideoDefinitionChangedNoficiation";

NSString *const VPVCVideoDefinitionChangedTypeKey = @"VPVCVideoDefinitionChangedType";

// 每个点快进货后退的秒数
static CGFloat const FastForwardSecondsPerPoint = 0.5f;
// 每个点变化的震动幅度
static CGFloat const BrightnessChangePerPoint = 1.f/200.f;


@interface BaseVPVC () <LvModelWindowDelegate, VPVideoDefinitionMenuViewDelegate>
{
    BOOL originalStatusBarHidden;
}

@property (nonatomic) UIActivityIndicatorView *loadPlayIndicator;

@property (nonatomic) VPNavigationBar *vpNavBar;
@property (nonatomic) VPPlayControlView *playControlV;

@property (nonatomic) VPSettingPanelView *settingPanel;
@property (nonatomic) LvModelWindow *settingWindow;

@property (nonatomic) VPVideoDefinitionMenuView *videoDefinitionMenuView;
@property (nonatomic) LvModelWindow *videoDefinitionMenuWindow;

// 临时画布设置值
@property (nonatomic) NSString *tempCanvasSettingValue;
// 临时按钮快进设置值
@property (nonatomic) NSString *tempButnFFSettingValue;

// 响应手势操作的view
@property (nonatomic) LvDirectionPanControl *gestureOperateView;
@property (nonatomic) VPFastSeekIndicator *seekIndicator;
@property (nonatomic) VPCommonIndicator *brightnessIndicator;
@property (nonatomic) CGFloat touchDownVideoPlayTime;
@property (nonatomic) CGFloat waitingFastSeekToTime;

// 视频进度条是否在触碰
@property (nonatomic) BOOL videoProgressSliderOnTouched;

// 触摸屏幕开始时屏幕亮度
@property (nonatomic) CGFloat touchDownBrightness;

@end

@implementation BaseVPVC

- (instancetype)init
{
    return [self initWithThemeStyle:VideoPlayerGreenButtonTheme controlBarMode:VideoPlayerControlBarModeDefault];
}

- (instancetype)initWithThemeStyle:(VideoPlayerThemeStyle)themeStyle controlBarMode:(VideoPlayerControlBarMode)controlBarMode
{
    if (self = [super init]) {
        _themeStyle = themeStyle;
        _controlBarMode = controlBarMode;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

#pragma mark - Override methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _vibrationStrength = [self loadVibrationStrength];
    
    [self setupPlayerContainnerView];
    
    [self setupGestureOperateView];
    
    [self setupVPNavBar];
    
    [self setupPlayerControlView];
    
    [self setupLoadPlayIndicator];
    
    [self setupBrightnessIndicator];
    
    [self setupSeekIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    originalStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    if (!originalStatusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:animated?UIStatusBarAnimationFade:UIStatusBarAnimationNone];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    [def addObserver:self
            selector:@selector(didVPVCReceiveApplicationDidEnterForegroundNotification)
                name:UIApplicationDidBecomeActiveNotification
              object:nil];
    [def addObserver:self
            selector:@selector(didVPVCReceiveApplicationDidEnterBackgroundNotification)
                name:UIApplicationWillResignActiveNotification
              object:nil];
    
    [self resetPlayControlView];
    [self showPlayerNavAndControlPanelWithDismissDelay: -1.f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!originalStatusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:animated?UIStatusBarAnimationFade:UIStatusBarAnimationNone];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    [def removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [def removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (CGFloat)loadVibrationStrength
{
    NSNumber *strength = [[NSUserDefaults standardUserDefaults]objectForKey:VPVCVibrationStrengthKey];
    if (strength) {
        return strength.floatValue;
    }
    // 默认
    return 0.5f;
}

#pragma mark - Respond to the Remote Control Events

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            if ([self isPlaying]) {
                [self pause];
            } else {
                [self play];
            }
            break;
        case UIEventSubtypeRemoteControlPlay:
            [self play];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self clickPlayPauseButton];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self clickPlayNextButton];
            break;
        default:
            break;
    }
}


#pragma mark - 屏幕方向控制

#ifdef __IPHONE_6_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
#endif

#ifndef __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}
#endif

#ifdef __IPHONE_7_0
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#endif

- (void)setupPlayerContainnerView
{
    if (!_playerContainnerView) {
        UIView *containnerV = [[UIView alloc]initWithFrame:self.view.bounds];
        containnerV.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:containnerV];
        _playerContainnerView = containnerV;
    }
}

/**
 *   设置响应手势操作view，手势包括：1.single tap 显示导航栏河操作栏 2.double tap 切换视频画布模式 3.左拽回看 4.右拽向前 5.上拽增强振动强度 6.下拽减少震动强度
 */
- (void)setupGestureOperateView
{
    if (!_gestureOperateView) {
        _gestureOperateView = [[LvDirectionPanControl alloc]initWithFrame:self.view.bounds];
        _gestureOperateView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_gestureOperateView];
        
        _gestureOperateView.userInteractionEnabled = YES;
        
        // 添加单击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [_gestureOperateView addGestureRecognizer:singleTap];
        
        // 添加双击
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [_gestureOperateView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        // 添加其他手势
        
        [_gestureOperateView addTarget:self action:@selector(directionPanTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_gestureOperateView addTarget:self action:@selector(directionPanTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [_gestureOperateView addTarget:self action:@selector(directionPanTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [_gestureOperateView addTarget:self action:@selector(directionPanValChanged:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)setupVPNavBar
{
    if (!_vpNavBar) {
        // 设置nav
        _vpNavBar = [[VPNavigationBar alloc]initFromNib];
        _vpNavBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        _vpNavBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44);
        [self.view addSubview:_vpNavBar];
        
        [_vpNavBar.backButn addTarget:self
                               action:@selector(dismissPlayer)
                     forControlEvents:UIControlEventTouchUpInside];
        
        [_vpNavBar.videoSettingButn addTarget:self
                                       action:@selector(videoSettingButnClick:)
                             forControlEvents:UIControlEventTouchUpInside];
        
        [_vpNavBar.definitionSwitchButton addTarget:self action:@selector(videoDefinitionSwitchButnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateVideoDefinitionButnByDefinition:self.videoDefinition];
    }
}

- (void)setupPlayerControlView
{
    if (!_playControlV) {
        // 设置play control
        _playControlV = [[VPPlayControlView alloc]initFromNib];
        _playControlV.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        CGFloat playCtrlHeight = 44;
        _playControlV.frame = CGRectMake(0,
                                         CGRectGetHeight(self.view.frame) - playCtrlHeight,
                                         CGRectGetWidth(self.view.frame),
                                         playCtrlHeight);
        [self.view addSubview:_playControlV];
        
        if (self.controlBarMode == VideoPlayerControlBarWithoutPreviousAndNextOperate) {
            _playControlV.previousButn.hidden = YES;
            _playControlV.nextButn.hidden = YES;
            _playControlV.previousButnWidthLayout.constant = 0;
            _playControlV.previousButnTrailingSpacingLayout.constant = 0;
            _playControlV.nextButnWidthLayout.constant = 0;
            _playControlV.nextButnLeadingSpacingLayout.constant = 0;
            
        } else {
            
            [_playControlV.previousButn addTarget:self
                                           action:@selector(previousButnClick:)
                                 forControlEvents:UIControlEventTouchUpInside];
            [_playControlV.nextButn addTarget:self
                                       action:@selector(nextButnClick:)
                             forControlEvents:UIControlEventTouchUpInside];
        }
        
        // 设置播放货暂停按钮事件
        [_playControlV.playPauseButn addTarget:self
                                        action:@selector(playPauseButnClick:)
                              forControlEvents:UIControlEventTouchUpInside];
        
        // 设置滑动条事件
        [_playControlV.progressSlider addTarget:self
                                         action:@selector(videoProgressChanged:)
                               forControlEvents:UIControlEventValueChanged];
        [_playControlV.progressSlider addTarget:self
                                         action:@selector(videoProgressDownTouched:)
                               forControlEvents:UIControlEventTouchDown];
        [_playControlV.progressSlider addTarget:self
                                         action:@selector(videoProgressUpTouched:)
                               forControlEvents:UIControlEventTouchUpInside];
        [_playControlV.progressSlider addTarget:self
                                         action:@selector(videoProgressUpTouched:)
                               forControlEvents:UIControlEventTouchUpOutside];
        [_playControlV.progressSlider addTarget:self
                                         action:@selector(videoProgressUpTouched:)
                               forControlEvents:UIControlEventTouchCancel];
    }
}

- (void)setupLoadPlayIndicator
{
    if (!_loadPlayIndicator) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.hidesWhenStopped = YES;
        indicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        indicator.center = self.view.center;
        
        [self.view addSubview:indicator];
        [indicator stopAnimating];
        _loadPlayIndicator = indicator;
    }
}

- (void)setupBrightnessIndicator
{
    if (!_brightnessIndicator) {
        VPCommonIndicator *indicator = [[VPCommonIndicator alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
        indicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        indicator.center = self.view.center;
        indicator.hidden = YES;
        indicator.iconImg = [UIImage imageNamed:@"vp_brightness"];
        [self.view addSubview:indicator];
        _brightnessIndicator = indicator;
    }
}

- (void)setupSeekIndicator
{
    if (!_seekIndicator) {
        VPFastSeekIndicator *indicator = [[VPFastSeekIndicator alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
        indicator.seekTimeText = @"--/--";
        indicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        indicator.center = self.view.center;
        indicator.hidden = YES;
        [self.view addSubview:indicator];
        _seekIndicator = indicator;
    }
}

- (void)setupSettingWindow
{
    if (!_settingWindow) {
        _settingWindow = [[LvModelWindow alloc]initWithPreferStatusBarHidden:YES
                                                        preferStatusBarStyle:UIStatusBarStyleDefault
                                                supportedOrientationPortrait:NO
                                      supportedOrientationPortraitUpsideDown:NO
                                           supportedOrientationLandscapeLeft:YES
                                          supportedOrientationLandscapeRight:YES];
        _settingWindow.modelWindowDelegate = self;
        
        if (!_settingPanel) {
            _settingPanel = [[VPSettingPanelView alloc]initFromNib];
            
            [self settingPanel:self.settingPanel setActionButtonBackgroundImageWithThemeStyle:self.themeStyle];
            
            CGFloat panelWidth = 360.f;
            CGFloat panelHeight = 240.f;
            CGFloat panelOriginX = (CGRectGetWidth(_settingWindow.windowRootView.bounds) - panelWidth)/2.f;
            CGFloat panelOriginY = (CGRectGetHeight(_settingWindow.windowRootView.bounds) - panelHeight)/2.f;
            _settingPanel.frame = CGRectMake(panelOriginX, panelOriginY, panelWidth, panelHeight);
            _settingPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            [_settingWindow.windowRootView addSubview:_settingPanel];
            
            _settingPanel.layer.masksToBounds = YES;
            _settingPanel.layer.cornerRadius = 4.f;
            
            // 设置其他
            [_settingPanel.certainButn addTarget:self
                                          action:@selector(settingCertainButnClick:)
                                forControlEvents:UIControlEventTouchUpInside];
            [_settingPanel.cancelButn addTarget:self
                                         action:@selector(settingCancelButnClick:)
                               forControlEvents:UIControlEventTouchUpInside];
            
            
            // 设置亮度valueChange监听
            [_settingPanel.brightnessSettingSlider addTarget:self
                                                      action:@selector(brightSettingChanged:)
                                            forControlEvents:UIControlEventValueChanged];
            
            // 设置屏幕模式按钮事件监听
            [_settingPanel.canvas_100Percent_butn addTarget:self
                                                     action:@selector(canvasSettingButnClick:)
                                           forControlEvents:UIControlEventTouchUpInside];
            [_settingPanel.canvas_fullScreen_butn addTarget:self
                                                     action:@selector(canvasSettingButnClick:)
                                           forControlEvents:UIControlEventTouchUpInside];
            
            
            // 设置飞机按键快进按钮事件监听
            [_settingPanel.butnSetting_FF_10Secs_butn addTarget:self
                                                         action:@selector(ffSettingButnClick:)
                                               forControlEvents:UIControlEventTouchUpInside];
            [_settingPanel.butnSetting_FF_20Secs_butn addTarget:self
                                                         action:@selector(ffSettingButnClick:)
                                               forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
}

- (void)settingPanel:(VPSettingPanelView *)settingPanel setActionButtonBackgroundImageWithThemeStyle:(VideoPlayerThemeStyle)themeStyle
{
    if (!settingPanel)
        return;
    
    UIImage *certainButnBgImg, *certainButnBgHlImg;
    
    switch (themeStyle) {
        case VideoPlayerGreenButtonTheme: {
            
            certainButnBgImg = [[UIImage imageNamed:@"vp_setting_green_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
            
            certainButnBgHlImg = [[UIImage imageNamed:@"vp_setting_green_btn_hl"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
            
            break;
        }
        case VideoPlayerYellowButtonTheme: {
            certainButnBgImg = [[UIImage imageNamed:@"vp_setting_yellow_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
            
            certainButnBgHlImg = [[UIImage imageNamed:@"vp_setting_yellow_btn_hl"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
            
            break;
        }
    }
    
    // 设置确定按钮背景
    settingPanel.certainButn.backgroundColor = [UIColor clearColor];
    [settingPanel.certainButn setBackgroundImage:certainButnBgImg forState:UIControlStateNormal];
    [settingPanel.certainButn setBackgroundImage:certainButnBgHlImg forState:UIControlStateHighlighted];
    
    // s何止取消按钮背景
    settingPanel.cancelButn.backgroundColor = [UIColor clearColor];
    [settingPanel.cancelButn setBackgroundImage:[[UIImage imageNamed:@"vp_setting_red_btn"]resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)] forState:UIControlStateNormal];
    [settingPanel.cancelButn setBackgroundImage:[[UIImage imageNamed:@"vp_setting_red_btn_hl"]resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)] forState:UIControlStateHighlighted];
}


- (NSString *)currentCanvasSettingValue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *canvasSettingVal = [userDefaults objectForKey:VP_SETTING_CANVAS_KEY];
    if (!canvasSettingVal) {
        canvasSettingVal = VP_SETTING_CANVAS_100_PERCENT_VALUE;
    }
    return canvasSettingVal;
}

- (void)updateToChecked:(BOOL)checked forCanvasSettingButn:(UIButton *)canvasSettingButn
{
    if (!canvasSettingButn)
        return;
    if (checked) {
        [canvasSettingButn setImage:[UIImage imageNamed:@"vp_setting_checkbox_selected"]
                           forState:UIControlStateNormal];
    } else {
        [canvasSettingButn setImage:[UIImage imageNamed:@"vp_setting_checkbox"]
                           forState:UIControlStateNormal];
    }
}

- (NSString *)currentButnFFSettingValue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *settingVal = [userDefaults objectForKey:VP_SETTING_BUTN_FF_KEY];
    if (!settingVal) {
        settingVal = VP_SETTING_BUTN_FF_10_SECS_VALUE;
    }
    return settingVal;
}

- (void)updateToChecked:(BOOL)checked forButnFFSettingButn:(UIButton *)butnFFSettingButn
{
    if (!butnFFSettingButn)
        return;
    if (checked) {
        [butnFFSettingButn setImage:[UIImage imageNamed:@"vp_setting_checkbox_selected"]
                           forState:UIControlStateNormal];
    } else {
        [butnFFSettingButn setImage:[UIImage imageNamed:@"vp_setting_checkbox"]
                           forState:UIControlStateNormal];
    }
}

// 画布设置值
static NSString *const VP_SETTING_CANVAS_KEY = @"VP_SETTING_CANVAS_KEY";
static NSString *const VP_SETTING_CANVAS_100_PERCENT_VALUE = @"100%";
static NSString *const VP_SETTING_CANVAS_FULL_SCREEN_VALUE = @"FULL_SCREEN";

// 按钮快进设置值
static NSString *const VP_SETTING_BUTN_FF_KEY = @"VP_SETTING_BUTN_FF_KEY";
static NSString *const VP_SETTING_BUTN_FF_10_SECS_VALUE = @"10";
static NSString *const VP_SETTING_BUTN_FF_20_SECS_VALUE = @"20";



- (LvModelWindow *)videoDefinitionMenuWindow
{
    if (!_videoDefinitionMenuWindow) {
        _videoDefinitionMenuWindow = [[LvModelWindow alloc]initWithPreferStatusBarHidden:YES
                                                                    preferStatusBarStyle:UIStatusBarStyleDefault
                                                            supportedOrientationPortrait:NO
                                                  supportedOrientationPortraitUpsideDown:NO
                                                       supportedOrientationLandscapeLeft:YES
                                                      supportedOrientationLandscapeRight:YES];
        
        _videoDefinitionMenuWindow.modelWindowDelegate = self;
        [_videoDefinitionMenuWindow.windowRootView addSubview:self.videoDefinitionMenuView];
        
        [_videoDefinitionMenuWindow.windowRootView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissVideoDefinitionMenuWindow)]];
        
    }
    return _videoDefinitionMenuWindow;
}

- (VPVideoDefinitionMenuView *)videoDefinitionMenuView
{
    if (!_videoDefinitionMenuView) {
        _videoDefinitionMenuView = [[VPVideoDefinitionMenuView alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
        
        _videoDefinitionMenuView.backgroundColor = [UIColor colorWithRed:0x8D/255.0 green:0x8C/255.0 blue:0x8C/255.0 alpha:0.54];
        _videoDefinitionMenuView.menuColor = [UIColor whiteColor];
        _videoDefinitionMenuView.menuSelectedColor = [UIColor colorWithRed:0xFF/255.0 green:0xCF/255.0 blue:0x17/255.0 alpha:0xFF/255.0]; /* FFCF17FF */
        _videoDefinitionMenuView.selectedMenuIndexNumber = [self currentVideoDefinitionIndexAtSupportDefinitions];
        _videoDefinitionMenuView.menuSeperatorColor = [UIColor colorWithWhite:1 alpha:0.2];
        
        _videoDefinitionMenuView.delegate = self;
        
        [_videoDefinitionMenuView setMenus:[self videoDefinitionMenusWithSupportVideoDefinitions:self.supportVideoDefinitions]];
    }
    return _videoDefinitionMenuView;
}

- (void)dismissVideoDefinitionMenuWindow
{
    [_videoDefinitionMenuWindow dismissWithAnimated:YES];
}

#pragma mark - VPVideoDefinitionMenuViewDelegate

- (void)videoDefinitionMenuView:(VPVideoDefinitionMenuView *)menuView didSelectedMenuAtIndex:(NSInteger)selectedMenuIndex
{
    if (selectedMenuIndex < self.supportVideoDefinitions.count) {
        
        NSNumber *currentVideoDefinitionIndexAtSupportDefinitions = [self currentVideoDefinitionIndexAtSupportDefinitions];
        if (currentVideoDefinitionIndexAtSupportDefinitions) {
            if (currentVideoDefinitionIndexAtSupportDefinitions.integerValue != selectedMenuIndex) {
                [[NSNotificationCenter defaultCenter]postNotificationName:VPVCVideoDefinitionChangedNoficiation object:self userInfo:@{VPVCVideoDefinitionChangedTypeKey:@(selectedMenuIndex)}];
            }
        }
    }
    
    [_videoDefinitionMenuWindow dismissWithAnimated:YES];
}


#pragma mark - Button actions

- (void)dismissPlayer
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:VPVCDismissNotification
                                                            object:self];
    }];
}

- (void)bluetoothButnClick:(UIButton *)butn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VPVCBluetoothButtonClickNotification object:self];
}

- (void)videoSettingButnClick:(UIButton *)butn
{
    [self setupSettingWindow];
    [_settingWindow showWithAnimated:YES];
    
    // 设置明亮度
    _settingPanel.brightnessSettingSlider.value = [UIScreen mainScreen].brightness/1.f;
    
    // 设置屏幕模式按钮事件监听
    if ([[self currentCanvasSettingValue] isEqualToString:VP_SETTING_CANVAS_FULL_SCREEN_VALUE]) {
        [self updateToChecked:YES forCanvasSettingButn:_settingPanel.canvas_fullScreen_butn];
        [self updateToChecked:NO forCanvasSettingButn:_settingPanel.canvas_100Percent_butn];
    } else {
        [self updateToChecked:NO forCanvasSettingButn:_settingPanel.canvas_fullScreen_butn];
        [self updateToChecked:YES forCanvasSettingButn:_settingPanel.canvas_100Percent_butn];
    }
    
    
    // 设置飞机按键快进按钮事件监听
    if ([[self currentButnFFSettingValue] isEqualToString:VP_SETTING_BUTN_FF_20_SECS_VALUE]) {
        [self updateToChecked:YES forButnFFSettingButn:_settingPanel.butnSetting_FF_20Secs_butn];
        [self updateToChecked:NO forButnFFSettingButn:_settingPanel.butnSetting_FF_10Secs_butn];
    } else {
        [self updateToChecked:NO forButnFFSettingButn:_settingPanel.butnSetting_FF_20Secs_butn];
        [self updateToChecked:YES forButnFFSettingButn:_settingPanel.butnSetting_FF_10Secs_butn];
    }
}

- (void)settingCertainButnClick:(UIButton *)butn
{
    // 改变设置
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.tempCanvasSettingValue) {
        [userDefaults setObject:self.tempCanvasSettingValue
                         forKey:VP_SETTING_CANVAS_KEY];
        if ([self.tempCanvasSettingValue isEqualToString:VP_SETTING_CANVAS_FULL_SCREEN_VALUE]) {
            [self didSetFullScreenCanvas];
        } else {
            [self didSet100PercentCanvas];
        }
    }
    
    if (self.tempButnFFSettingValue) {
        [userDefaults setObject:self.tempButnFFSettingValue
                         forKey:VP_SETTING_BUTN_FF_KEY];
    }
    
    [_settingWindow dismissWithAnimated:YES];
}

- (void)settingCancelButnClick:(UIButton *)butn
{
    [_settingWindow dismissWithAnimated:YES];
    self.tempCanvasSettingValue = nil;
    self.tempButnFFSettingValue = nil;
}

// 快进按钮的单击事件
- (void)ffSettingButnClick:(UIButton *)butn
{
    NSString *vp_butn_ff_value = nil;
    
    if ([butn isEqual:_settingPanel.butnSetting_FF_10Secs_butn]) {
        // 快进10秒设置
        vp_butn_ff_value = VP_SETTING_BUTN_FF_10_SECS_VALUE;
        [self updateToChecked:YES forButnFFSettingButn:butn];
        [self updateToChecked:NO forButnFFSettingButn:_settingPanel.butnSetting_FF_20Secs_butn];
    } else if ([butn isEqual:_settingPanel.butnSetting_FF_20Secs_butn]){
        // 快进20秒设置
        vp_butn_ff_value = VP_SETTING_BUTN_FF_20_SECS_VALUE;
        [self updateToChecked:YES forButnFFSettingButn:butn];
        [self updateToChecked:NO forButnFFSettingButn:_settingPanel.butnSetting_FF_10Secs_butn];
    }
    
    self.tempButnFFSettingValue = vp_butn_ff_value;
}

// 画布设置的按钮单击事件
- (void)canvasSettingButnClick:(UIButton *)butn
{
    NSString *vp_canvas_setting_value = nil;
    
    if ([butn isEqual:_settingPanel.canvas_100Percent_butn]) {
        // 100%屏
        vp_canvas_setting_value = VP_SETTING_CANVAS_100_PERCENT_VALUE;
        [self updateToChecked:YES forCanvasSettingButn:butn];
        [self updateToChecked:NO forCanvasSettingButn:_settingPanel.canvas_fullScreen_butn];
    } else if ([butn isEqual:_settingPanel.canvas_fullScreen_butn]){
        // 满屏
        vp_canvas_setting_value = VP_SETTING_CANVAS_FULL_SCREEN_VALUE;
        [self updateToChecked:YES forCanvasSettingButn:butn];
        [self updateToChecked:NO forCanvasSettingButn:_settingPanel.canvas_100Percent_butn];
    }
    
    self.tempCanvasSettingValue = vp_canvas_setting_value;
}

// 屏幕亮度slider的值改变事件
- (void)brightSettingChanged:(LvNormalSlider *)brightnessSilider
{
    [UIScreen mainScreen].brightness = brightnessSilider.value;
}


- (void)videoDefinitionSwitchButnClick:(UIButton *)butn
{
    if (self.supportVideoDefinitions.count > 1) {
        CGRect butnFrameAtWindow = [self.view.window convertRect:butn.bounds fromView:butn];
        
        CGSize menuViewFitSize = [self.videoDefinitionMenuView sizeThatFits:CGSizeMake(CGRectGetWidth(butnFrameAtWindow), MAXFLOAT)];
        self.videoDefinitionMenuView.frame = CGRectMake(CGRectGetMinX(butnFrameAtWindow), CGRectGetMinY(butnFrameAtWindow), menuViewFitSize.width, menuViewFitSize.height);
        
        self.videoDefinitionMenuView.layer.cornerRadius = 4;
        self.videoDefinitionMenuView.layer.masksToBounds = YES;
        
        [self.videoDefinitionMenuWindow showWithAnimated:YES];
    }
}

- (UIImage *)videoPauseImage
{
    static UIImage *pauseImg = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pauseImg = [UIImage imageNamed:@"vp_pause"];
    });
    return pauseImg;
}

- (UIImage *)videoPlayImage
{
    static UIImage *playImg = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playImg = [UIImage imageNamed:@"vp_play"];
    });
    return playImg;
}

- (void)playPauseButnClick:(UIButton *)butn
{
    [self clickPlayPauseButton];
}

// 上一个视频点击事件
- (void)previousButnClick:(UIButton *)butn
{
    [self clickPlayPreviousButton];
    [[NSNotificationCenter defaultCenter]postNotificationName:VPVCPlayPreviousVideoItemNotifiction object:self];
}

// 下一个视频按钮点击事件
- (void)nextButnClick:(UIButton *)butn
{
    [self clickPlayNextButton];
    [[NSNotificationCenter defaultCenter]postNotificationName:VPVCPlayNextVideoItemNotification object:self];
}

// 拖动视频进度变化事件
- (void)videoProgressChanged:(LvNormalSlider *)progressSlider
{
    
}

- (void)videoProgressDownTouched:(LvNormalSlider *)progressSlider
{
    self.videoProgressSliderOnTouched = YES;
}

- (void)videoProgressUpTouched:(LvNormalSlider *)progressSlider
{
    self.videoProgressSliderOnTouched = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startActivityLoading];
    });
    [self seekToPosition:(progressSlider.value * [self currentVideoDuration])];
}




#pragma mark - Gestures

- (void)singleTap:(UITapGestureRecognizer *)tap
{
    NSLog(@"single tap");
    // 显示或隐藏导航栏和操作栏
    if (self.vpNavBar.alpha == 0) {
        [self showPlayerNavAndControlPanelWithDismissDelay:5.f];
    } else {
        [self dismissPlayerNavAndControlPanel];
    }
    
    self.seekIndicator.hidden = YES;
    self.brightnessIndicator.hidden = YES;
}

- (void)doubleTap:(UITapGestureRecognizer *)tap
{
    // 切换画布模式
    NSLog(@"double tap");
    
    // 改变设置
    NSString *currentCanvas = [self currentCanvasSettingValue];
    if ([currentCanvas isEqualToString:VP_SETTING_CANVAS_FULL_SCREEN_VALUE]) {
        currentCanvas = VP_SETTING_CANVAS_100_PERCENT_VALUE;
        [self didSet100PercentCanvas];
    } else {
        currentCanvas = VP_SETTING_CANVAS_FULL_SCREEN_VALUE;
        [self didSetFullScreenCanvas];
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:currentCanvas forKey:VP_SETTING_CANVAS_KEY];
    
    self.seekIndicator.hidden = YES;
    self.brightnessIndicator.hidden = YES;
}

- (void)directionPanTouchDown:(LvDirectionPanControl *)panControl
{
    self.touchDownVideoPlayTime = [self currentVideoPlayPosition];
    self.touchDownBrightness = [UIScreen mainScreen].brightness;
}

- (void)directionPanTouchUp:(LvDirectionPanControl *)panControl
{
    self.seekIndicator.hidden = YES;
    self.brightnessIndicator.hidden = YES;
    
    self.touchDownVideoPlayTime = 0;
    
    if (panControl.panDirection == LvPanDirectionHorizon) {
        if (self.waitingFastSeekToTime >= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadPlayIndicator startAnimating];
            });
            [self seekToPosition:self.waitingFastSeekToTime];
        }
    } else if (panControl.panDirection == LvPanDirectionVertical) {
        
        if (panControl.beiginTrackPoint.x >= CGRectGetMidX(panControl.bounds)) {
            
            // 保存起来
            [[NSUserDefaults standardUserDefaults]setObject:@(self.vibrationStrength)
                                                     forKey:VPVCVibrationStrengthKey];
            // 发布通知
            [[NSNotificationCenter defaultCenter]postNotificationName:VPVCUpdateVibrationStrengthNotification
                                                               object:self
                                                             userInfo:@{VPVCVibrationStrengthKey:@(self.vibrationStrength)}];
        }
    }
}

- (void)directionPanValChanged:(LvDirectionPanControl *)panControl
{
    if (panControl.panDirection == LvPanDirectionHorizon) {
        // horizon方向：前进或后退
        
        VPFastSeekIndicator *seekIndicator = self.seekIndicator;
        if (seekIndicator.hidden) {
            seekIndicator.hidden = NO;
        }
        
        // 拖拽距离
        CGFloat panDistance = panControl.currentTrackPoint.x - panControl.beiginTrackPoint.x;
        seekIndicator.fastForward = (panDistance >= 0);
        
        long videoDuration = self.currentVideoDuration;
        if (videoDuration > 0) {
            CGFloat seekTime = (panDistance * FastForwardSecondsPerPoint * 1000.f) + self.touchDownVideoPlayTime;
            if (seekTime > videoDuration) {
                seekTime = videoDuration;
            } else if (seekTime < 0) {
                seekTime = 0;
            }
            seekIndicator.seekTimeText = [NSString stringWithFormat:@"%@/%@",
                                          [DurationFormat durationTextForDuration:seekTime/1000.f],
                                          [DurationFormat durationTextForDuration:videoDuration/1000.f]];
            self.waitingFastSeekToTime = seekTime;
        } else {
            self.waitingFastSeekToTime = -1;
        }
        return;
    }
    
    if (panControl.panDirection == LvPanDirectionVertical) {
        
        // vertical方向
        // 判断手势滑动的初始位置
        if (panControl.beiginTrackPoint.x < CGRectGetMidX(panControl.bounds)) {
            // 变亮度
            VPCommonIndicator *brightnessIndicator = [self brightnessIndicator];
            if (brightnessIndicator.hidden) {
                brightnessIndicator.hidden = NO;
            }
            
            // 拖拽距离
            CGFloat panDistance = panControl.beiginTrackPoint.y - panControl.currentTrackPoint.y;
            CGFloat strength = panDistance * BrightnessChangePerPoint + self.touchDownBrightness;
            if (strength > 1) {
                strength = 1;
            } else if (strength < 0) {
                strength = 0;
            }
            
            brightnessIndicator.strength = strength;
            [UIScreen mainScreen].brightness = strength;
            
        }
        
        return;
    }
}


#pragma mark - LvModelWindowDelegate methods

- (void)modelWindowDidShow:(LvModelWindow *)modelWindow
{
    if ([modelWindow isEqual:_videoDefinitionMenuWindow]) {
        
        self.vpNavBar.definitionSwitchButton.hidden = YES;
        
        [self showPlayerNavAndControlPanelWithDismissDelay:-1.f];
        
        return;
    
    }
}

- (void)modelWindowDidDismiss:(LvModelWindow *)modelWindow
{
    if ([modelWindow isEqual:_videoDefinitionMenuWindow]) {
        
        self.vpNavBar.definitionSwitchButton.hidden = NO;
        
        [self showPlayerNavAndControlPanelWithDismissDelay:1.f];
        
        return;
        
    }
}

- (void(^)())showAnimations:(LvModelWindow *)modelWindow
{
    if ([modelWindow isEqual:_settingPanel]) {
        
        __weak BaseVPVC *weakSelf = self;
        return ^{
            if (weakSelf.settingPanel) {
                weakSelf.settingPanel.alpha = 1.f;
            }
        };
        
    }
    return nil;
}

- (void(^)())showCompletion:(LvModelWindow *)modelWindow
{
    return nil;
}

- (void(^)())dismissAnimations:(LvModelWindow *)modelWindow
{
    if ([modelWindow isEqual:_settingPanel]) {
    
        __weak BaseVPVC *weakSelf = self;
        return ^{
            if (weakSelf.settingPanel) {
                weakSelf.settingPanel.alpha = .5f;
            }
        };
    
    }
    return nil;
}

- (void(^)())dismissCompletion:(LvModelWindow *)modelWindow
{
    if ([modelWindow isEqual:_settingPanel]) {
    
        __weak BaseVPVC *weakSelf = self;
        return ^{
            if (weakSelf.settingPanel) {
                weakSelf.settingPanel.alpha = 1.f;
            }
        };
        
    }
    
    return nil;
}

- (void)updateVideoDefinitionButnByDefinition:(VideoPlayerVideoDefinition)definition
{
    NSString *definitionButonText = nil;
    switch (definition) {
        case VideoDefinitionFluent: {
            definitionButonText = NSLocalizedStringFromTable(@"Fluent", @"VideoPlayer", nil);
            break;
        }
        case VideoDefinitionStandard: {
            definitionButonText = NSLocalizedStringFromTable(@"SD", @"VideoPlayer", nil);
            break;
        }
        case VideoDefinitionHigh: {
            definitionButonText = NSLocalizedStringFromTable(@"HD", @"VideoPlayer", nil);
            break;
        }
        case VideoDefinitionSuper: {
            definitionButonText = NSLocalizedStringFromTable(@"Super D", @"VideoPlayer", nil);
            break;
        }
    }
    
    [self.vpNavBar.definitionSwitchButton setTitle:definitionButonText forState:UIControlStateNormal];
}

#pragma mark - notification handler

- (void)recvToyBootButtonUpEventNote:(NSNotification *)note
{
    // 设备安检按下，快进
    CGFloat seekToTime = [self currentVideoPlayPosition] + [self deviceBootButtonFastForwardSeekValue]*1000;
    [self seekToPosition:seekToTime];
}

- (void)setSupportVideoDefinitions:(NSArray *)supportVideoDefinitions
{
    _supportVideoDefinitions = supportVideoDefinitions;
    
    if (_videoDefinitionMenuView) {
        _videoDefinitionMenuView.selectedMenuIndexNumber = [self currentVideoDefinitionIndexAtSupportDefinitions];
        [_videoDefinitionMenuView setMenus:[self videoDefinitionMenusWithSupportVideoDefinitions:supportVideoDefinitions]];
    }
}

- (NSMutableArray *)videoDefinitionMenusWithSupportVideoDefinitions:(NSArray *)supportVideoDefinitions
{
    NSMutableArray *definitionMenus = [NSMutableArray array];
    for (NSNumber *supportVideoDefinition in supportVideoDefinitions) {
        VideoPlayerVideoDefinition videoDefinition = supportVideoDefinition.unsignedIntegerValue;
        switch (videoDefinition) {
            case VideoDefinitionFluent:
                [definitionMenus addObject:NSLocalizedStringFromTable(@"Fluent", @"VideoPlayer", nil)];
                break;
            case VideoDefinitionStandard:
                [definitionMenus addObject:NSLocalizedStringFromTable(@"SD", @"VideoPlayer", nil)];
                break;
            case VideoDefinitionHigh:
                [definitionMenus addObject:NSLocalizedStringFromTable(@"HD", @"VideoPlayer", nil)];
                break;
            case VideoDefinitionSuper:
                [definitionMenus addObject:NSLocalizedStringFromTable(@"Super D", @"VideoPlayer", nil)];
                break;
        }
    }
    
    return definitionMenus;
}


- (void)setVideoDefinition:(VideoPlayerVideoDefinition)videoDefinition
{
    _videoDefinition = videoDefinition;
    [self updateVideoDefinitionButnByDefinition:videoDefinition];
    
    _videoDefinitionMenuView.selectedMenuIndexNumber = [self currentVideoDefinitionIndexAtSupportDefinitions];
}

- (NSNumber *)currentVideoDefinitionIndexAtSupportDefinitions
{
    if (self.supportVideoDefinitions.count > 0) {
        NSUInteger index = [self.supportVideoDefinitions indexOfObject:@(self.videoDefinition)];
        if (index != NSNotFound) {
            return @(index);
        }
    }
    return nil;
}

#pragma mark - Implements on self

- (void)setPlayButttonPaused
{
    [self.playControlV.playPauseButn setImage:[self videoPauseImage]
                                     forState:UIControlStateNormal];
}

- (void)setPlayButttonPlaying
{
    [self.playControlV.playPauseButn setImage:[self videoPlayImage]
                                     forState:UIControlStateNormal];
}

- (void)refreshCurrentPlayProgress
{
    CGFloat currentTime = [self currentVideoPlayPosition]/1000.f;
    CGFloat videoDur = [self currentVideoDuration]/1000.f;
    self.playControlV.playProgressLabel.text = [DurationFormat durationTextForDuration:currentTime];
    self.playControlV.remainTimeLabel.text = [DurationFormat durationTextForDuration:(videoDur - currentTime)];

    if (!self.videoProgressSliderOnTouched) {
        if (videoDur > 0) {
            self.playControlV.progressSlider.value = currentTime/videoDur;
        } else {
            self.playControlV.progressSlider.value = 0;
        }
    }
}

/**
 *  设备开机按钮快进值
 */
- (NSTimeInterval)deviceBootButtonFastForwardSeekValue
{
    NSString *currentFFVal = [self currentButnFFSettingValue];
    if ([currentFFVal isEqual:VP_SETTING_BUTN_FF_20_SECS_VALUE]) {
        return 20.f;
    }
    return 10.f;
}

/**
 *  启动/结束加载视图
 */
- (void)startActivityLoading
{
    [self.loadPlayIndicator startAnimating];
}

- (void)stopActivityLoading
{
    [self.loadPlayIndicator stopAnimating];
}


- (void)resetPlayControlView
{
    [_playControlV.playPauseButn setImage:[self videoPlayImage] forState:UIControlStateNormal];
    [_playControlV.progressSlider setValue:0.f];
    [_playControlV.playProgressLabel setText:[DurationFormat durationTextForDuration:0]];
    [_playControlV.remainTimeLabel setText:[DurationFormat durationTextForDuration:0]];
}

/**
 *  显示控件，过段时间隐藏
 *  @param dismissDelay 隐藏时间间隔，>0 时才有效
 */
- (void)showPlayerNavAndControlPanelWithDismissDelay:(NSTimeInterval)dismissDelay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(dismissPlayerNavAndControlPanel)
                                                   object:nil];
        __weak BaseVPVC *weakSelf = self;
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.vpNavBar.alpha = 1;
            weakSelf.playControlV.alpha = 1;
        } completion:^(BOOL finished){
            [[UIApplication sharedApplication]endIgnoringInteractionEvents];
            if (dismissDelay > 0) {
                // 定时隐藏导航栏河操作栏
                [self performSelector:@selector(dismissPlayerNavAndControlPanel)
                           withObject:nil
                           afterDelay:dismissDelay];
            }
        }];
    });
}

- (void)dismissPlayerNavAndControlPanel
{
    __weak BaseVPVC *weakSelf = self;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.vpNavBar.alpha = 0;
        weakSelf.playControlV.alpha = 0;
    } completion:^(BOOL finished){
        [[UIApplication sharedApplication]endIgnoringInteractionEvents];
    }];
}

#pragma mark - Override in sub classes

- (BOOL)isPlaying
{
    return NO;
}

- (void)preparePlayURL:(NSURL *)videoURL immediatelyPlay:(BOOL)immediatelyPlay
{
    
}


- (void)play
{
    
}

- (void)pause
{
    
}

- (void)stop
{
    
}


- (void)clickPlayPauseButton
{
    
}


- (void)clickPlayPreviousButton
{
    
}


- (void)clickPlayNextButton
{
    
}


- (void)seekToPosition:(CGFloat)position
{
    
}


- (void)didSetFullScreenCanvas
{
    
}

- (void)didSet100PercentCanvas
{
    
}

- (CGFloat)currentVideoDuration
{
    return 0.f;
}

- (CGFloat)currentVideoPlayPosition
{
    return 0.f;
}

- (void)didVPVCReceiveApplicationDidEnterForegroundNotification
{

}

- (void)didVPVCReceiveApplicationDidEnterBackgroundNotification
{

}

@end
