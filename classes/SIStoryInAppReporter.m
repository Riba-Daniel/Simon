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
	SI_LOG(@"Deallocing");
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
	
	SIStoryReportTableViewController *reportController = [[[SIStoryReportTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
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
	
	// Get the root view controller.
	UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
   DC_LOG(@"%@", rootController.view);

	// Position the new view offscreen.
   CGFloat width = rootController.view.bounds.size.width;
   CGFloat height = rootController.view.bounds.size.height;
   navController.view.frame = CGRectMake(0,height, width, height);
	[rootController.view addSubview:navController.view];
   
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
