//
//  VPFastSeekIndicator.m
//  LvDemos
//
//  Created by guangbo on 15/3/23.
//
//

#import "VPFastSeekIndicator.h"

@interface VPFastSeekIndicator ()
@property (nonatomic) UIView *containner;
@property (nonatomic) UIImageView *seekIconView;
@property (nonatomic) UILabel *seekTimeLabel;
@end

@implementation VPFastSeekIndicator

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupVPFastSeekIndicator];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupVPFastSeekIndicator];
    }
    return self;
}

- (void)setupVPFastSeekIndicator
{
    _seekIconView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 21)];
    
    _seekTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                              CGRectGetMaxY(_seekIconView.frame) + 8.f,
                                                              CGRectGetWidth(self.frame),
                                                              18.f)];
    _seekTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _seekTimeLabel.backgroundColor = [UIColor clearColor];
    _seekTimeLabel.font = [UIFont systemFontOfSize:14.f];
    _seekTimeLabel.textColor = [UIColor whiteColor];
    _seekTimeLabel.textAlignment = NSTextAlignmentCenter;
    
    _containner = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetMaxY(_seekTimeLabel.frame))];
    _containner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [_containner addSubview:_seekIconView];
    [_containner addSubview:_seekTimeLabel];
    [self addSubview:_containner];
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4.f;
    
    [self setFastForward:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    _containner.center = CGPointMake(CGRectGetMidX(bounds),
                                     CGRectGetMidY(bounds));
    _seekIconView.center = CGPointMake(CGRectGetMidX(_containner.bounds),
                                       _seekIconView.center.y);
}

- (void)setFastForward:(BOOL)fastForward
{
    if (_fastForward == fastForward)
        return;
    
    _fastForward = fastForward;
    
    UIImage *fastIconImg = nil;
    if (fastForward) {
        fastIconImg = [self fastForwardImage];
    } else {
        fastIconImg = [self fastReverseImage];
    }
    self.seekIconView.image = fastIconImg;
}

- (void)setSeekTimeText:(NSString *)seekTimeText
{
    _seekTimeText = seekTimeText;
    self.seekTimeLabel.text = seekTimeText;
}

- (UIImage *)fastForwardImage
{
    static UIImage *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [UIImage imageNamed:@"vp_fastforward"];
    });
    return instance;
}

- (UIImage *)fastReverseImage
{
    static UIImage *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [UIImage imageNamed:@"vp_fastreverse"];
    });
    return instance;
}

@end
