//
//  VPCommonIndicator.m
//  LvDemos
//
//  Created by guangbo on 15/3/23.
//
//

#import "VPCommonIndicator.h"

@interface VPCommonIndicator ()

@property (nonatomic) UIView *containner;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *strengthLabel;

@end

@implementation VPCommonIndicator

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupVPCommonIndicator];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupVPCommonIndicator];
    }
    return self;
}

- (void)setupVPCommonIndicator
{
    CGFloat labelMarginIcon = 8;
    CGFloat labelHeight = 18;
    CGFloat labelWidth = 50;
    CGFloat imageSize = 25;
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageSize, imageSize)];
    _imageView.contentMode = UIViewContentModeCenter;
    _imageView.clipsToBounds = NO;
    
    _strengthLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame) + labelMarginIcon,
                                                              0,
                                                              labelWidth,
                                                              labelHeight)];
    _strengthLabel.textColor = [UIColor whiteColor];
    _strengthLabel.font = [UIFont systemFontOfSize:14.f];
    _strengthLabel.textAlignment = NSTextAlignmentCenter;
    
    _containner = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                          0,
                                                          CGRectGetMaxX(_strengthLabel.frame),
                                                          MAX(imageSize, labelHeight))];
    _containner.clipsToBounds = NO;
    
    [_containner addSubview:_imageView];
    [_containner addSubview:_strengthLabel];
    [self addSubview:_containner];
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4.f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    _containner.center = CGPointMake(CGRectGetMidX(bounds),
                                     CGRectGetMidY(bounds));
    
    bounds = _containner.bounds;
    _imageView.center = CGPointMake(_imageView.center.x,
                                    CGRectGetMidY(bounds));
    _strengthLabel.center = CGPointMake(_strengthLabel.center.x,
                                        CGRectGetMidY(bounds));
}

- (void)setStrength:(CGFloat)strength
{
    _strength = strength;
    
    CGFloat mStrength = strength;
    if (mStrength > 1) {
        mStrength = 1;
    } else if (mStrength < 0) {
        mStrength = 0;
    }
    
    _strengthLabel.text = [NSString stringWithFormat:@"%d%%", (int)(100*mStrength)];
}

- (void)setIconImg:(UIImage *)iconImg
{
    _imageView.image = iconImg;
}

@end
