//
//  CQViewController.m
//  PopUpMenu
//
//  Created by cunqi on 02/24/2016.
//  Copyright (c) 2016 cunqi. All rights reserved.
//

#import "CQViewController.h"
#import "PopUpMenu.h"

@interface CQViewController ()<PopUpMenuDataSource, PopUpMenuItemDelegate>
@property (weak, nonatomic) IBOutlet PopUpMenu *menu;

@end

@implementation CQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setting for menu
    self.menu.backgroundColor = [UIColor greenColor];
    self.menu.branchLength = 70;
    self.menu.menuDataSource = self;
    self.menu.itemDelegate = self;
    self.menu.intervalAngle = 45;
    self.menu.menuItemRadius = 20;
    self.menu.menuItemBackgroundColor = [UIColor redColor];
    self.menu.menuItemBorderWidth = 2.0f;
    self.menu.menuItemBorderColor = [UIColor whiteColor];
    self.menu.startAngle = MenuItemStartAngleUp;
    
    NSArray *icons = @[[UIImage imageNamed:@"User"], [UIImage imageNamed:@"User"], [UIImage imageNamed:@"User"]];
    self.menu.menuItemIcons = icons;
    
    UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToCancelMenu)];
    
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PopUpMenuDataSource

- (NSInteger)numberOfItemsInItem:(PopUpMenu *)menuView {
    return 3;
}

#pragma mark - PopUpMenuItemDelegate
- (void)popUpMenuItem:(PopUpMenuItem *)item didSelectMenuItemAtIndex:(NSInteger)index {
    NSLog(@"@ button tapped %ld", (long)index);
}

#pragma mark - helper methods
- (void) tapToCancelMenu {
    [self.menu closePopUpMenu];
}
@end
