//
//  VPFastSeekIndicator.h
//  LvDemos
//
//  Created by guangbo on 15/3/23.
//
//

#import <UIKit/UIKit.h>

/**
 *  视频播放快进/快退指示视图
 */
@interface VPFastSeekIndicator : UIView

@property (nonatomic) BOOL fastForward;
@property (nonatomic) NSString *seekTimeText;

@end
