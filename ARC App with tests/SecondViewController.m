//
//  SecondViewController.m
//  ARC App with tests
//
//  Created by Derek Clarkson on 5/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController
@synthesize outputLabel = _outputLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setOutputLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)helloButton:(id)sender {
	self.outputLabel.text = @"hello";
}
@end
