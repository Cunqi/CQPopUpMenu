//
//  PopUpMenu.h
//
//  Created by Cunqi.X on 2016/2/23.
//  Copyright © 2016 Cunqi Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopUpMenu;
@class PopUpMenuItem;

/**
 *  Menu Item start angle, assuming there is a coordinate, So:
 *  Left    - negative X axis   (0°)
 *  Up      - positive Y axis   (90°)
 *  Right   - positive X axis   (180°)
 *  Down    - negative Y axis   (270°)
 */
typedef NS_ENUM(NSUInteger, MenuItemStartAngle) {
    MenuItemStartAngleLeft = 0,
    MenuItemStartAngleUp = 90,
    MenuItemStartAngleRight = 180,
    MenuItemStartAngleDown = 270
};

/**
 *  PopUp Menu Datasource, it decides how many items that menu has, and how these item created
 */
@protocol PopUpMenuDataSource <NSObject>
/**
 *  decide how many items that menu has
 *
 *  @param menuView PopUpMenu instance
 *
 *  @return number of items
 */
- (NSInteger) numberOfItemsInItem:(PopUpMenu * _Nonnull) menuView;

/**
 *  decide how to create a PopUpMenuItem
 *
 *  @param menuView menuView PopUpMenu instance
 *  @param index    index of item
 *
 *  @return PopUpItem instance
 */
@optional
- (PopUpMenuItem * _Nonnull)popUpMenu:(PopUpMenu * _Nonnull) menu itemForMenuAtIndex:(NSInteger) index;
@end

/**
 *  PopUp Menu Item Delegate, it decides the behavior when menu item tapped
 */
@protocol PopUpMenuItemDelegate <NSObject>

/**
 *  decide the behavior when menu item tapped
 *
 *  @param item  tapped menu item
 *  @param index index of tapped menu item
 */
- (void)popUpMenuItem:(PopUpMenuItem * _Nonnull)item didSelectMenuItemAtIndex:(NSInteger) index;

@end

/**
 *  the behaviors when menu tapped
 */
@protocol PopUpMenuDelegate <NSObject>

/**
 *  the behavior before the menu closing execute
 *
 *  @param menu PopUpMenu Instance
 */
- (void)popUpMenuWillMenuClose:(PopUpMenu * _Nonnull)menu;

/**
 *  the behavior after the menu closing execute
 *
 *  @param menu PopUpMenu Instance
 */
- (void)popUpMenuDidMenuClose:(PopUpMenu * _Nonnull)menu;

/**
 *  the behavior before the menu opening execute
 *
 *  @param menu PopUpMenu Instance
 */
- (void)popUpMenuWillMenuOpen:(PopUpMenu * _Nonnull)menu;

/**
 *  the behavior before the menu opening execute
 *
 *  @param menu PopUpMenu Instance
 */
- (void)popUpMenuDidMenuOpen:(PopUpMenu * _Nonnull)menu;

@end




/**
 *  PopUp Menu Item
 */
@interface PopUpMenuItem : UIButton
/**
 *  menu item radius, decides the size of menu item
 *  width/height = menuItemRadius * 2
 */
@property (nonatomic) CGFloat menuItemRadius;

/**
 *  menu item border width
 */
@property (nonatomic) CGFloat menuItemBorderWidth;

/**
 *  menu item border color
 */
@property (strong, nonatomic, nonnull) UIColor *menuItemBorderColor;

/**
 *  enable to draw the drop shadow of menu item
 */
@property (nonatomic) BOOL enableDropShadow;


/**
 *  menu item background color
 */
@property (strong, nonatomic, nonnull) UIColor *menuItemBackgroundColor;

/**
 *  close menu after item tapped
 */
@property (nonatomic) BOOL closeMenuAfterItemTapped;
/**
 *  PopUp Menu Item Delegate
 */
@property (nonatomic, weak, nullable) id <PopUpMenuItemDelegate> itemDelegate;
@end




/**
 *  PopUp Menu is a PopUpMenuItem, but it has its own methods to manipulate menu items
 */
@interface PopUpMenu : PopUpMenuItem

@property (strong, nonatomic, nullable) NSArray *menuItemIcons;
/**
 *  distance between menu center and menu item center,
 *  in correct situation, this property must large than
 *  the sum of menuItemRadius + (self.bounds.size.width / 2) .
 */
@property (nonatomic) CGFloat branchLength;

/**
 *  animation delay when tap popup menu
 */
@property (nonatomic) CGFloat animationDelay;

/**
 *  start angle of first menu item
 */
@property (nonatomic) CGFloat startAngle;

/**
 *  interval angle between each menu item
 */
@property (nonatomic) CGFloat intervalAngle;

/**
 *  state of menu opened or not
 */
@property (nonatomic) BOOL isMenuOpened;

/**
 *  PopUp Menu Datasource
 */
@property (nonatomic, weak, nullable) id <PopUpMenuDataSource> menuDataSource;

/**
 *  PopUp Menu Delegate
 */
@property (nonatomic, weak, nullable) id <PopUpMenuDelegate> menuDelegate;

/**
 *  invoke this method to open menu
 */
- (void)openPopUpMenu;

/**
 *  invoke this method to close menu
 */
- (void)closePopUpMenu;
@end


