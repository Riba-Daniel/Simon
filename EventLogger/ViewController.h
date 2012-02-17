//
//  ViewController.h
//  EventLogger
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton * buttonA;
@property (nonatomic, strong) IBOutlet UIButton * buttonB;

-(IBAction) buttonATapped:(id) sender;
-(IBAction) buttonBTapped:(id) sender;

+(void) logEvent:(UIEvent *) event source:(NSString *) source;

@end
