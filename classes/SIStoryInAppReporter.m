//
//  SIInAppReporter.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryInAppReporter.h"
#import "SIStoryReportTableViewController.h"
#import <UIKit/UIKit.h>
#import <dUsefulStuff/DCCommon.h>

@interface SIStoryInAppReporter()
-(void) displayReportOnStorySources:(NSArray *) sources andMappings:(NSArray *) mappings;
-(void) closeSimon;
@end


@implementation SIStoryInAppReporter

-(void) dealloc {
	DC_LOG(@"Deallocing");
	[super dealloc];
}

-(void) reportOnStorySources:(NSArray *) sources andMappings:(NSArray *) mappings {
	// Refire on the main thread.
	dispatch_queue_t mainQ = dispatch_get_main_queue();
	dispatch_async(mainQ, ^{
		[self displayReportOnStorySources:sources andMappings:mappings];
	});
	
}

-(void) displayReportOnStorySources:(NSArray *) sources andMappings:(NSArray *) mappings {
	
	SIStoryReportTableViewController *reportController = [[[SIStoryReportTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
	reportController.storySources = sources;
	reportController.mappings = mappings;
	reportController.navigationItem.title = @"Simon's simple report";
	
	// Set a nav controller as the top controller.
	navController = [[UINavigationController alloc] initWithRootViewController:reportController];
	navController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
	
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:@"Close Simon" 
																						  style:UIBarButtonItemStylePlain 
																						 target:self 
																						 action:@selector(closeSimon)] autorelease];
	reportController.navigationItem.rightBarButtonItem = closeButton;

	// Resign the keyboard
	[[UIApplication sharedApplication].keyWindow endEditing:YES];
	
	// Get the front most view and add our report to it, dont use the window due to rotation.
	UIView *rootView = [[[[UIApplication sharedApplication].windows objectAtIndex:0] subviews] lastObject];
   DC_LOG(@"Root View: %@", rootView);
   
	// Position the new view offscreen.
   CGFloat width = rootView.bounds.size.width;
   CGFloat height = rootView.bounds.size.height;
   navController.view.frame = CGRectMake(0,height, width, height);
	[rootView addSubview:navController.view];
   
	// Animate to the center of the view.
   [UIView animateWithDuration:1.0 animations:^{
		navController.view.frame = CGRectMake(0,0, width, height);
	}];
    
}

-(void) closeSimon {
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	CGRect windowFrame = window.frame;
	CGRect viewFrame = navController.view.frame;
	[UIView animateWithDuration:1.0f  
						  animations:^{
                       CGRect offScreen = CGRectMake(0, windowFrame.size.height, viewFrame.size.width, viewFrame.size.height);
							  navController.view.frame = offScreen;
						  }
						  completion:^(BOOL finished){
							  [navController.view removeFromSuperview];
							  DC_DEALLOC(navController);
						  } ];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Simon shutdown" object:nil]];
}

@end
