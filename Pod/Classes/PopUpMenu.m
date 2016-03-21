//
//  PopUpMenu.m
//
//  Created by Cunqi.X on 2016/2/23.
//  Copyright © 2016年 Cunqi Xiao. All rights reserved.
//

#import "PopUpMenu.h"

@interface PopUpMenuItem()
@property(weak, nonatomic) PopUpMenu *parent;
@end

@implementation PopUpMenuItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultProperties];
        [self addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self defaultProperties];
        [self addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

/**
 *  configure default properties
 */
- (void) defaultProperties {
    self.menuItemBorderColor = [UIColor whiteColor];
    self.menuItemBorderWidth = 2;
    self.menuItemBackgroundColor = [UIColor colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0];
    self.menuItemRadius = 25;
    self.enableDropShadow = YES;
    self.closeMenuAfterItemTapped = YES;
}

- (void)itemTapped:(id)sender {
    if (self.itemDelegate) {
        [self.itemDelegate popUpMenuItem:self didSelectMenuItemAtIndex:(self.tag)];
    }
    if (self.parent && self.closeMenuAfterItemTapped) {
        [self.parent closePopUpMenu];
    }
}
@end

@interface PopUpMenu ()<PopUpMenuDataSource>
/**
 *  store menu items
 */
@property(strong, nonatomic) NSArray *items;

/**
 *  store menu item center (item.center)
 */
@property(strong, nonatomic) NSArray *itemPositions;
@end

@implementation PopUpMenu

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initPopUpMenu];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPopUpMenu];
    }
    return self;
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"center"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self configureMenuItemStyle:self];
}

- (void)configureMenuItemStyle:(PopUpMenuItem *)item {
    item.layer.masksToBounds = NO;
    item.layer.cornerRadius = item.bounds.size.height / 2;  //critical - convert the button to a circular shape
    item.layer.borderColor = self.menuItemBorderColor.CGColor;
    item.layer.borderWidth = self.menuItemBorderWidth;
    
    if (self.enableDropShadow) {
        item.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        item.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:item.bounds cornerRadius:item.bounds.size.height / 2].CGPath;   //critical - improve performance
        item.layer.shadowOffset = CGSizeMake(1.5, 1.5);
        item.layer.shadowRadius = 2;
        item.layer.shadowOpacity = 0.8;
    }
}

/**
 *  execute general configuration for popup menu
 */
- (void) initPopUpMenu {
    self.isMenuOpened = NO; //menu is closed by default
    self.animationDelay = 0;
    self.branchLength = 90;
    self.startAngle = MenuItemStartAngleLeft;
    self.intervalAngle = 45;
    
    self.menuDataSource = self;
    
    //disable [super itemTapped] for Menu View
    [self removeTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addTarget:self action:@selector(createAndPopMenu) forControlEvents:UIControlEventTouchUpInside];

    //set KVO for self.center changed
    [self addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"center"]) {
        CGPoint newMenuCenter = [change[NSKeyValueChangeNewKey] CGPointValue];
        if (self.itemPositions) {
            NSMutableArray *newCenters = [[NSMutableArray alloc] init];
            CGPoint newMenuItemCenter;
            for (int i = 0; i < self.itemPositions.count; ++i) {
                newMenuItemCenter = [self generateMenuItemOriginWithMenuCenter:newMenuCenter atIndex:i];
                [newCenters addObject:[NSValue valueWithCGPoint:newMenuItemCenter]];
            }
            self.itemPositions = [newCenters copy]; //update new menu item centers
        }
    }
}

/**
 *  when menu tapped, first thing is create all menu items, only once.
 *  then handle the button tapped event
 */
- (void)createAndPopMenu {
    //create menu item when menu first tapped
    if ((!self.items) && self.menuDataSource) {
        NSMutableArray *tItems = [[NSMutableArray alloc] init];
        NSMutableArray *tItemPositions = [[NSMutableArray alloc] init];
        NSInteger size = [self.menuDataSource numberOfItemsInItem:self];
        
        BOOL hasCreationMethod = [self.menuDataSource respondsToSelector:@selector(popUpMenu:itemForMenuAtIndex:)];
        for (int i = 0; i < size; ++i) {
            PopUpMenuItem *item = nil;
            if (hasCreationMethod) {
                item = [self.menuDataSource popUpMenu:self itemForMenuAtIndex:i];
            } else {
                item = [self popUpMenu:self itemForMenuAtIndex:i];
            }
            item.alpha = 0;
            [self.superview insertSubview:item belowSubview:self];
            [tItems addObject:item];
            [tItemPositions addObject:[NSValue valueWithCGPoint:item.center]];
            item.center = self.center;
            
            item.parent = self;
            item.itemDelegate = self.itemDelegate;
        }
        self.itemPositions = [tItemPositions copy];
        self.items = [tItems copy];
    }

    //handle menu tapped event
    if (self.isMenuOpened) {
        [self closePopUpMenu];
    } else {
        [self openPopUpMenu];
    }
    self.isMenuOpened = !self.isMenuOpened;
}

- (void)openPopUpMenu {
    if (self.menuDelegate) {
        [self.menuDelegate popUpMenuWillMenuOpen:self];
    }
    [UIView animateWithDuration:0.6 delay:self.animationDelay usingSpringWithDamping:0.7 initialSpringVelocity:12 options:UIViewAnimationOptionCurveLinear animations:^{
        for (NSUInteger i = 0; i < self.itemPositions.count; ++i) {
            PopUpMenuItem *item = (PopUpMenuItem *)self.items[i];
            NSValue *value = self.itemPositions[i];
            item.center = [value CGPointValue];
            item.alpha = 1;
        }
    } completion:^(BOOL finished) {
        self.isMenuOpened = YES;
        if (self.menuDelegate) {
            [self.menuDelegate popUpMenuDidMenuOpen:self];
        }
    }];
}

- (void)closePopUpMenu {
    if (self.menuDelegate) {
        [self.menuDelegate popUpMenuWillMenuClose:self];
    }
    [UIView animateWithDuration:0.6 delay:self.animationDelay usingSpringWithDamping:0.7 initialSpringVelocity:12 options:UIViewAnimationOptionCurveLinear animations:^{
        for (NSUInteger i = 0; i < self.itemPositions.count; ++i) {
            PopUpMenuItem *item = (PopUpMenuItem *)self.items[i];
            item.center = self.center;
            item.alpha = 0;
        }
    } completion:^(BOOL finished) {
        self.isMenuOpened = NO;
        if (self.menuDelegate) {
            [self.menuDelegate popUpMenuDidMenuClose:self];
        }
    }];
}

#pragma mark - PopUpMenuDataSource

- (NSInteger)numberOfItemsInItem:(PopUpMenu *)menuView {
    return 3;   //default number of items
}

- (PopUpMenuItem *)popUpMenu:(PopUpMenu *)menu itemForMenuAtIndex:(NSInteger)index {
    //default logic of creating menu item
    PopUpMenuItem *button = [self generatePopUpMenuItemAtIndex: index];
    return button;
}

#pragma mark - help methods

/**
 *  generate menu item at index
 *
 *  @param index index of menu item
 *
 *  @return menu item instance
 */
- (PopUpMenuItem *)generatePopUpMenuItemAtIndex:(NSInteger)index {
    PopUpMenuItem *item = [[PopUpMenuItem alloc] initWithFrame:[self generateFrameForItemAtIndex:index]];
    item.tag = index;
    item.backgroundColor = self.menuItemBackgroundColor;
    item.clipsToBounds = YES;
    if (self.menuItemIcons && index < self.menuItemIcons.count) {
        UIImage *icon = self.menuItemIcons[index];
        [item setImage:icon forState:UIControlStateNormal];
    }
    
    [self configureMenuItemStyle:item];
    return item;
}

/**
 *  generate menu item frame of given index
 *
 *  @param index index of menu item
 *
 *  @return item frame
 */
- (CGRect)generateFrameForItemAtIndex:(NSInteger)index {
    CGFloat degree = self.startAngle + index * self.intervalAngle;
    CGPoint center = [self calculateMenuItemCenterWithMenuCenter:self.center andLength:self.branchLength inDegree:degree];
    CGPoint origin = [self convertMenuItemOriginWithMenuItemCenter:center];
    return CGRectMake(origin.x, origin.y, self.menuItemRadius * 2, self.menuItemRadius * 2);
}

/**
 *  generate menu item origin with menu center
 *
 *  @param menuCenter menu center
 *  @param index      index of menu item
 *
 *  @return menu item center for specific index
 */
- (CGPoint)generateMenuItemOriginWithMenuCenter:(CGPoint)menuCenter atIndex:(NSInteger)index {
    CGFloat degree = self.startAngle + index * self.intervalAngle;
    CGPoint center = [self calculateMenuItemCenterWithMenuCenter:menuCenter andLength:self.branchLength inDegree:degree];
    return center;
}


/**
 *  convert menu item origin point based on menu item center
 *
 *  @param center menu item center
 *
 *  @return menu item origin
 */
- (CGPoint)convertMenuItemOriginWithMenuItemCenter:(CGPoint)itemCenter {
    CGFloat x = itemCenter.x - self.menuItemRadius;
    CGFloat y = itemCenter.y - self.menuItemRadius;
    return CGPointMake(x, y);
}

/**
 *  calculate menu item center based on the menu center, branch length and angle
 *
 *  @param menuCenter menu center
 *  @param length     branch length
 *  @param degree     angle in degree
 *
 *  @return menu item center point
 */
- (CGPoint)calculateMenuItemCenterWithMenuCenter:(CGPoint) menuCenter andLength:(CGFloat)length inDegree:(CGFloat) degree {
    CGFloat x = menuCenter.x - (CGFloat)(cos(degree * M_PI / 180) * length);
    CGFloat y = menuCenter.y - (CGFloat)(sin(degree * M_PI / 180) * length);
    return CGPointMake(x, y);
}

@end
