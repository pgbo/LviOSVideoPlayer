//
//  VPSettingPanelView.h
//  LvDemos
//
//  Created by guangbo on 15/3/18.
//
//

#import <UIKit/UIKit.h>
#import "LvNormalSlider.h"
#import "VideoPlayerConstants.h"

@interface VPSettingPanelView : UIView

- (instancetype)initFromNib;

// 亮度设置滑动条
@property (nonatomic, weak) IBOutlet LvNormalSlider *brightnessSettingSlider;

// 画布设置，100%和满屏
@property (nonatomic, weak) IBOutlet UIButton *canvas_100Percent_butn;
@property (nonatomic, weak) IBOutlet UIButton *canvas_fullScreen_butn;

// 按钮设置，快进10秒和20秒
@property (nonatomic, weak) IBOutlet UIButton *butnSetting_FF_10Secs_butn;
@property (nonatomic, weak) IBOutlet UIButton *butnSetting_FF_20Secs_butn;

// 确定/取消设置按钮
@property (nonatomic, weak) IBOutlet UIButton *certainButn;
@property (nonatomic, weak) IBOutlet UIButton *cancelButn;

@end
