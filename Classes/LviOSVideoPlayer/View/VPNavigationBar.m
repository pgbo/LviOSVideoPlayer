//
//  VPNavigationBar.m
//  LvDemos
//
//  Created by guangbo on 15/3/18.
//
//

#import "VPNavigationBar.h"

@implementation VPNavigationBar

- (instancetype)initFromNib
{
    UINib *nib = [UINib nibWithNibName:@"VPNavigationBar" bundle:nil];
    return [nib instantiateWithOwner:self options:nil][0];
}

- (void)awakeFromNib
{
    // 设置
    [self setupVPNavigationBar];
}

- (void)setupVPNavigationBar
{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.definitionSwitchButton.layer.cornerRadius = 4;
    self.definitionSwitchButton.layer.masksToBounds = YES;
}


@end
