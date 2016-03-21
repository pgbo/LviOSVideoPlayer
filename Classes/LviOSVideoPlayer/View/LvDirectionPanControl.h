//
//  LvDirectionPanControl.h
//  LvDemos
//
//  Created by guangbo on 15/3/20.
//
//

#import <UIKit/UIKit.h>

// 拖拽方向
typedef NS_ENUM(NSUInteger, LvPanDirection) {
    LvPanDirectionUnkown = 0,
    LvPanDirectionHorizon,
    LvPanDirectionVertical
};

/**
 *  方向拖拽control
 */
@interface LvDirectionPanControl : UIControl

// 拖拽方向
@property (nonatomic, readonly) LvPanDirection panDirection;

// 开始track事件的点
@property (nonatomic, readonly) CGPoint beiginTrackPoint;
// 结束track事件的点
@property (nonatomic, readonly) CGPoint currentTrackPoint;

@end
