//
//  SecondViewController.h
//  ARC App with tests
//
//  Created by Derek Clarkson on 5/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController
- (IBAction)helloButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;

@end
