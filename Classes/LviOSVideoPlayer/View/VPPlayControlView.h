//
//  VPPlayControlView.h
//  LvDemos
//
//  Created by guangbo on 15/3/18.
//
//

#import <UIKit/UIKit.h>
#import "LvNormalSlider.h"

@interface VPPlayControlView : UIView

- (instancetype)initFromNib;

// 前一个视频按钮
@property (nonatomic, weak) IBOutlet UIButton *previousButn;
// 前一个视频按钮宽度约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *previousButnWidthLayout;
// 前一个视频按钮右边间隔约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *previousButnTrailingSpacingLayout;
// 播放/暂停按钮
@property (nonatomic, weak) IBOutlet UIButton *playPauseButn;
// 下一个视频按钮
@property (nonatomic, weak) IBOutlet UIButton *nextButn;
// 下一个视频按钮宽度约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nextButnWidthLayout;
// 下一个视频按钮左边间隔约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nextButnLeadingSpacingLayout;
// 播放进度的文字视图
@property (nonatomic, weak) IBOutlet UILabel *playProgressLabel;
// 剩余时间的文字视图
@property (nonatomic, weak) IBOutlet UILabel *remainTimeLabel;

// 进度调节器
@property (nonatomic, weak) IBOutlet LvNormalSlider *progressSlider;

@end
