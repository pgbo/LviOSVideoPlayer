//
//  VPSettingPanelView.m
//  LvDemos
//
//  Created by guangbo on 15/3/18.
//
//

#import "VPSettingPanelView.h"

@implementation VPSettingPanelView

- (instancetype)initFromNib
{
    UINib *nib = [UINib nibWithNibName:@"VPSettingPanelView" bundle:nil];
    self = [nib instantiateWithOwner:nil options:nil][0];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.brightnessSettingSlider.backgroundColor = [UIColor clearColor];
    self.brightnessSettingSlider.handleSize = 12.f;
}

@end
