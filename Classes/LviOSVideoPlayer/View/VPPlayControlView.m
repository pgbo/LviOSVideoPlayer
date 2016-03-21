//
//  VPPlayControlView.m
//  LvDemos
//
//  Created by guangbo on 15/3/18.
//
//

#import "VPPlayControlView.h"

@implementation VPPlayControlView

- (instancetype)initFromNib
{
    UINib *nib = [UINib nibWithNibName:@"VPPlayControlView" bundle:nil];
    return [nib instantiateWithOwner:nil options:nil][0];
}

- (void)awakeFromNib
{
    [self setupVPPlayControlView];
}

- (void)setupVPPlayControlView
{
    self.progressSlider.backgroundColor = [UIColor clearColor];
    self.progressSlider.handleSize = 12.f;
}

@end
