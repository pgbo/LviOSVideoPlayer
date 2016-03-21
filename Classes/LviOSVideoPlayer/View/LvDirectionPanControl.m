//
//  LvDirectionPanControl.m
//  LvDemos
//
//  Created by guangbo on 15/3/20.
//
//

#import "LvDirectionPanControl.h"

@implementation LvDirectionPanControl

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupDirectionPanControl];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupDirectionPanControl];
    }
    return self;
}

- (void)setupDirectionPanControl
{
    _beiginTrackPoint = CGPointZero;
    _panDirection = LvPanDirectionUnkown;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _panDirection = LvPanDirectionUnkown;
    _beiginTrackPoint = [touch locationInView:self];
    
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    
    if (CGPointEqualToPoint(_beiginTrackPoint, CGPointZero)) {
        _beiginTrackPoint = point;
    }
    
    // 在此判定方向，判定后不修改
    if (_panDirection == LvPanDirectionUnkown) {
        CGFloat diff = fabsf(point.x - _beiginTrackPoint.x) - fabsf(point.y - _beiginTrackPoint.y);
        if (diff > 0) {
            _panDirection = LvPanDirectionHorizon;
        } else if (diff < 0) {
            _panDirection = LvPanDirectionVertical;
        }
    }
    
    _currentTrackPoint = point;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
}

@end
