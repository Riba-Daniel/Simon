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
	// Get the size from the window.
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	
	CGRect frame = window.frame;
	NSUInteger heightAdjust = [UIApplication sharedApplication].statusBarHidden ? 0 : 20;
	CGRect offScreen = CGRectMake(0, frame.size.height, frame.size.width, frame.size.height - heightAdjust);
	CGRect onScreen = CGRectMake(0, heightAdjust, frame.size.width, frame.size.height - heightAdjust);
	
	SIStoryReportTableViewController *reportController = [[[SIStoryReportTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	reportController.storySources = sources;
	reportController.mappings = mappings;
	reportController.navigationItem.title = @"Simon's simple report";
	
	// Add a navigation bar at the top.
	navController = [[UINavigationController alloc] initWithRootViewController:reportController];
	navController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
	navController.view.frame = offScreen;
	
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:@"Close Simon" 
																						  style:UIBarButtonItemStylePlain 
																						 target:self 
																						 action:@selector(closeSimon)] autorelease];
	reportController.navigationItem.rightBarButtonItem = closeButton;
	
	[window addSubview:navController.view];
	
	// Animate on.
	[UIView animateWithDuration:1.0 animations:^{
		navController.view.frame = onScreen;
	}];
	
}

-(void) closeSimon {
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	CGRect windowFrame = window.frame;
	CGRect viewFrame = navController.view.frame;
	CGRect offScreen = CGRectMake(0, windowFrame.size.height, viewFrame.size.width, viewFrame.size.height);
	[UIView animateWithDuration:1.0f  
						  animations:^{
							  navController.view.frame = offScreen;
						  }
						  completion:^(BOOL finished){
							  [navController.view removeFromSuperview];
							  DC_DEALLOC(navController);
						  } ];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Simon shutdown" object:nil]];
}

@end
