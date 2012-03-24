//
//  TestViewController.h
//  Simon
//
//  Created by Derek Clarkson on 7/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController<UITabBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> 

@property (retain, nonatomic) IBOutlet UIButton *button1;
@property (retain, nonatomic) IBOutlet UIButton *button2;
@property (retain, nonatomic) IBOutlet UIButton *waitForItButton;
@property (retain, nonatomic) IBOutlet UITabBar *tabBar;
@property (retain, nonatomic) IBOutlet UILabel *tapableLabel;
@property (retain, nonatomic) IBOutlet UILabel *displayLabel;
@property (retain, nonatomic) IBOutlet UITextField *textField;
@property (retain, nonatomic) IBOutlet UITextField *phoneNumberField;

@property (nonatomic) NSInteger tappedButton;
@property (nonatomic) NSInteger tappedTabBarItem;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic, retain) NSDate *startDragTime;
@property (nonatomic, retain) NSDate *endDragTime;

@property (retain, nonatomic) IBOutlet UISlider *slider;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL gestureRecognizerTapped;

- (IBAction)buttonTapped:(id)sender;
- (IBAction)waitForItTapped:(id)sender;

- (NSTimeInterval) dragDuration;

@end
