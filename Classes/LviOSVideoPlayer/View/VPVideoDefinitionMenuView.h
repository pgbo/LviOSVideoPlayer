//
//  VPVideoDefinitionMenuView.h
//  GalaToy
//
//  Created by guangbo on 15/7/27.
//
//

#import <UIKit/UIKit.h>

@protocol VPVideoDefinitionMenuViewDelegate;

/**
 视频清晰度菜单视图
 */
@interface VPVideoDefinitionMenuView : UIView

@property (nonatomic, weak) id<VPVideoDefinitionMenuViewDelegate> delegate;

@property (nonatomic) UIColor *menuColor;
@property (nonatomic) UIColor *menuSelectedColor;
@property (nonatomic) NSNumber *selectedMenuIndexNumber;
@property (nonatomic) UIColor *menuSeperatorColor;


- (void)setMenus:(NSArray *)menus;

#pragma mark - Override

- (CGSize)sizeThatFits:(CGSize)size;

- (CGSize)intrinsicContentSize;

@end

@protocol VPVideoDefinitionMenuViewDelegate <NSObject>

@optional

- (void)videoDefinitionMenuView:(VPVideoDefinitionMenuView *)menuView didSelectedMenuAtIndex:(NSInteger)selectedMenuIndex;

@end
