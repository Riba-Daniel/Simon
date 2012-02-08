//
//  TestViewController.h
//  Simon
//
//  Created by Derek Clarkson on 7/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController<UITabBarDelegate>

@property (retain, nonatomic) IBOutlet UIButton *button1;
@property (retain, nonatomic) IBOutlet UIButton *button2;
@property (retain, nonatomic) IBOutlet UITabBar *tabBar;

@property (nonatomic) NSInteger tappedButton;
@property (nonatomic) NSInteger tappedTabBarItem;

- (IBAction)buttonTapped:(id)sender;

@end
