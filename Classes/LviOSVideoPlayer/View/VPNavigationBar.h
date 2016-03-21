//
//  VPNavigationBar.h
//  LvDemos
//
//  Created by guangbo on 15/3/18.
//
//

#import <UIKit/UIKit.h>

/**
 *  视频播放器导航栏
 */
@interface VPNavigationBar : UIView

- (instancetype)initFromNib;

@property (nonatomic, weak) IBOutlet UIButton *backButn;
@property (nonatomic, weak) IBOutlet UIButton *definitionSwitchButton;
@property (nonatomic, weak) IBOutlet UIButton *videoSettingButn;

@end
