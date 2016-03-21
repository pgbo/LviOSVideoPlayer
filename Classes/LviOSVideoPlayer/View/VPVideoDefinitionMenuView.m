//
//  VPVideoDefinitionMenuView.m
//  GalaToy
//
//  Created by guangbo on 15/7/27.
//
//

#import "VPVideoDefinitionMenuView.h"


static const CGFloat VPVideoDefinitionMenuButtonHeight = 28.f;
static const CGFloat VPVideoDefinitionMenuSeperatorHeight = 0.4f;

@interface VPVideoDefinitionMenuSeperator : UIView

@end

@implementation VPVideoDefinitionMenuSeperator

@end


@interface VPVideoDefinitionMenuButton : UIButton

@end

@implementation VPVideoDefinitionMenuButton

@end


@interface VPVideoDefinitionMenuView ()

@property (nonatomic) NSArray *menuButtons;
@property (nonatomic) NSArray *menuSeperators;

@end

@implementation VPVideoDefinitionMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupVideoDefinitionMenuView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupVideoDefinitionMenuView];
    }
    return self;
}

- (void)setupVideoDefinitionMenuView
{
    
}

- (void)setMenus:(NSArray *)menus
{
    NSArray *subViews = self.subviews;
    for (UIView *subView in subViews) {
        if ([subView isKindOfClass:[VPVideoDefinitionMenuSeperator class]] || [subView isKindOfClass:[VPVideoDefinitionMenuButton class]]) {
            [subView removeFromSuperview];
        }
    }
    
    NSInteger menuCount = menus.count;
    if (menuCount > 0) {
    
        NSMutableArray *menuButtons = [NSMutableArray array];
        NSMutableArray *menuSeperators = [NSMutableArray array];
        
        for (NSInteger i = 0; i < menuCount; i ++) {
            
            NSString *menu = menus[i];
            
            VPVideoDefinitionMenuButton *menuButton = [VPVideoDefinitionMenuButton buttonWithType:UIButtonTypeCustom];
            menuButton.tag = i;
            [menuButton setTitle:menu forState:UIControlStateNormal];
            [menuButton addTarget:self action:@selector(menuButtonCilck:) forControlEvents:UIControlEventTouchUpInside];
            [self styleMenuButton:menuButton];
            
            [menuButtons addObject:menuButton];
            [self addSubview:menuButton];
            
            if (i < menuCount - 1) {
                
                VPVideoDefinitionMenuSeperator *menuSeperator = [[VPVideoDefinitionMenuSeperator alloc]init];
                menuSeperator.backgroundColor = self.menuSeperatorColor;
                [menuSeperators addObject:menuSeperator];
                [self addSubview:menuSeperator];
            }
        }
        
        // 设置约束
        
        UIView *topAlignView = nil;
        NSInteger menuSeperotarCount = menuSeperators.count;
        for (NSInteger i = 0; i < menuSeperotarCount; i ++) {
            
            VPVideoDefinitionMenuButton *menuButton = menuButtons[i];
            VPVideoDefinitionMenuSeperator *menuSeperator = menuSeperators[i];
            
            menuButton.translatesAutoresizingMaskIntoConstraints = NO;
            menuSeperator.translatesAutoresizingMaskIntoConstraints = NO;
         
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[menuButton]-6-|" options:0 metrics:nil views:@{@"menuButton":menuButton}]];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[menuSeperator]-6-|" options:0 metrics:nil views:@{@"menuSeperator":menuSeperator}]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:menuButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topAlignView?topAlignView:self attribute:topAlignView?NSLayoutAttributeBottom:NSLayoutAttributeTop multiplier:1 constant:0]];
            
            [menuButton addConstraint:[NSLayoutConstraint constraintWithItem:menuButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:VPVideoDefinitionMenuButtonHeight]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:menuButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:menuSeperator attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            
            [menuSeperator addConstraint:[NSLayoutConstraint constraintWithItem:menuSeperator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:VPVideoDefinitionMenuSeperatorHeight]];
            
            topAlignView = menuSeperator;

        }
        
        // 设置最后一个 menu button 的约束
        
        VPVideoDefinitionMenuButton *lastMenuButton = menuButtons.lastObject;
        if (lastMenuButton) {
            lastMenuButton.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[lastMenuButton]-6-|" options:0 metrics:nil views:@{@"lastMenuButton":lastMenuButton}]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:lastMenuButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topAlignView?topAlignView:self attribute:topAlignView?NSLayoutAttributeBottom:NSLayoutAttributeTop multiplier:1 constant:0]];
            
            [lastMenuButton addConstraint:[NSLayoutConstraint constraintWithItem:lastMenuButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:VPVideoDefinitionMenuButtonHeight]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:lastMenuButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            
        }
        
        self.menuButtons = menuButtons;
        self.menuSeperators = menuSeperators;
        
    }
}


- (void)setMenuColor:(UIColor *)menuColor
{
    _menuColor = menuColor;
    
    for (UIButton *menuButton in self.menuButtons) {
        [menuButton setTitleColor:menuColor forState:UIControlStateNormal];
    }
    
}

- (void)setMenuSelectedColor:(UIColor *)menuSelectedColor
{
    _menuSelectedColor = menuSelectedColor;
    
    [[self menuButtonAtIndex:self.selectedMenuIndexNumber.integerValue] setTitleColor:menuSelectedColor forState:UIControlStateNormal];
}

- (void)setSelectedMenuIndexNumber:(NSNumber *)selectedMenuIndexNumber
{
    if ([_selectedMenuIndexNumber isEqual:selectedMenuIndexNumber])
        return;
    
    VPVideoDefinitionMenuButton *originSelectedButn = _selectedMenuIndexNumber?[self menuButtonAtIndex:_selectedMenuIndexNumber.integerValue]:nil;
    
    if (selectedMenuIndexNumber && selectedMenuIndexNumber.integerValue >= 0) {
        NSInteger selectedMenuIndex = selectedMenuIndexNumber.integerValue;
        
        if (self.menuButtons.count > selectedMenuIndex) {
            
            // 恢复当前选中按钮到原颜色
            [originSelectedButn setTitleColor:self.menuColor forState:UIControlStateNormal];

            // 重新设置选中按钮
            [[self menuButtonAtIndex:selectedMenuIndex] setTitleColor:self.menuSelectedColor forState:UIControlStateNormal];
        }
        _selectedMenuIndexNumber = selectedMenuIndexNumber;
        
    } else {
        
        // 恢复当前选中按钮到原颜色
        [originSelectedButn setTitleColor:self.menuColor forState:UIControlStateNormal];
        _selectedMenuIndexNumber = nil;
    }
}

- (void)setMenuSeperatorColor:(UIColor *)menuSeperatorColor
{
    _menuSeperatorColor = menuSeperatorColor;
    
    for (UIView *seperator in self.menuSeperators) {
        [seperator setBackgroundColor:menuSeperatorColor];
    }
}


- (void)styleMenuButton:(VPVideoDefinitionMenuButton *)menuButton
{
    if (self.selectedMenuIndexNumber && menuButton.tag == self.selectedMenuIndexNumber.integerValue) {
        [menuButton setTitleColor:self.menuSelectedColor forState:UIControlStateNormal];
    } else {
        [menuButton setTitleColor:self.menuColor forState:UIControlStateNormal];
    }
    
    [menuButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    menuButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
}

- (void)menuButtonCilck:(UIButton *)menuButn
{
    NSInteger menuIndex = menuButn.tag;
    if ([self.delegate respondsToSelector:@selector(videoDefinitionMenuView:didSelectedMenuAtIndex:)]) {
        [self.delegate videoDefinitionMenuView:self didSelectedMenuAtIndex:menuIndex];
    }
}

- (VPVideoDefinitionMenuButton *)menuButtonAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.menuButtons.count) {
        return self.menuButtons[index];
    }
    
    return nil;
}

#pragma mark - Override

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat height = 0;
    
    NSInteger menuCount = self.menuButtons.count;
    if (menuCount > 0) {
        height = menuCount * VPVideoDefinitionMenuButtonHeight + (menuCount - 1)*VPVideoDefinitionMenuSeperatorHeight;
    }
    
    return CGSizeMake(size.width, height);
}

- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits:self.frame.size];
}

@end

