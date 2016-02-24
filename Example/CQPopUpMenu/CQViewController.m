//
//  CQViewController.m
//  PopUpMenu
//
//  Created by cunqi on 02/24/2016.
//  Copyright (c) 2016 cunqi. All rights reserved.
//

#import "CQViewController.h"
#import <PopUpMenu/PopUpMenu.h>

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
    self.menu.menuItemRadius = 15;
    self.menu.startAngle = MenuItemStartAngleUp;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfItemsInItem:(PopUpMenu *)menuView {
    return 3;
}

- (void)popUpMenuItem:(PopUpMenuItem *)item didSelectMenuItemAtIndex:(NSInteger)index {
    NSLog(@"@ button tapped %ld", (long)index);
}

@end
