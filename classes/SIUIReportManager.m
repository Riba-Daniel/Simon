//
//  SIInAppReporter.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIUIReportManager.h"
#import "SIStoryReportTableViewController.h"
#import <UIKit/UIKit.h>
#import <dUsefulStuff/DCCommon.h>
#import "NSObject+Simon.h"

@interface SIUIReportManager(_private)
-(void) closeSimon;
-(void) runStories;
-(void) removeWindow;
-(UIView *) uiParentView;
@end


@implementation SIUIReportManager

-(void) dealloc {
	DC_DEALLOC(navController);
	DC_LOG(@"Deallocing");
	[super dealloc];
}

-(void) reportOnStorySources:(NSArray *) sources andMappings:(NSArray *) mappings {
	
	// Refire on the main thread.
	[self executeBlockOnMainThread: ^{
		
		SIStoryReportTableViewController *reportController = [[SIStoryReportTableViewController alloc] initWithStyle:UITableViewStylePlain];
		reportController.storySources = sources;
		reportController.mappings = mappings;
		reportController.navigationItem.title = @"Simon's simple report";
		
		// Set a nav controller as the top controller and keep a reference to it.
		navController = [[UINavigationController alloc] initWithRootViewController:reportController];
		[reportController release];
		
		// Add buttons
		UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close Simon" 
																							 style:UIBarButtonItemStylePlain 
																							target:self 
																							action:@selector(closeSimon)];
		UIBarButtonItem *rerunButton = [[UIBarButtonItem alloc] initWithTitle:@"Run" 
																							 style:UIBarButtonItemStylePlain 
																							target:self 
																							action:@selector(runStories)];
		reportController.navigationItem.leftBarButtonItem = closeButton;
		reportController.navigationItem.rightBarButtonItem = rerunButton;
		[closeButton release];
		[rerunButton release];
		
		// Resign the keyboard in case it is visible.
		[[UIApplication sharedApplication].keyWindow endEditing:YES];
		
		// Get the front most view and add our report to it, dont use the window due to rotation.
		UIView *parentView = [self uiParentView];
		DC_LOG(@"Parent View: %@", parentView);
		
		// Position the new view offscreen.
		CGFloat width = parentView.bounds.size.width;
		CGFloat height = parentView.bounds.size.height;
		navController.view.frame = CGRectMake(0,height, width, height);
		[parentView addSubview:navController.view];
		
		// Animate to the center of the view.
		[UIView animateWithDuration:1.0 animations:^{
			navController.view.frame = CGRectMake(0,0, width, height);
		}];
	}];
	
}

-(void) runStories {
	triggerRerun = YES;
	[self removeWindow];
}

-(void) closeSimon {
	[self removeWindow];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_SHUTDOWN_NOTIFICATION object:nil]];
}

-(void) removeWindow {
	
	UIView *parentView = [self uiParentView];
	CGRect windowFrame = parentView.frame;
	CGRect viewFrame = navController.view.frame;
	
	[UIView animateWithDuration:1.0f  
						  animations:^{
							  
							  CGRect offScreen = CGRectMake(0, windowFrame.size.height, viewFrame.size.width, viewFrame.size.height);
							  navController.view.frame = offScreen;
							  
						  }
	 
						  completion:^(BOOL finished){
							  
							  [navController.view removeFromSuperview];
							  DC_DEALLOC(navController);
							  
							  // Let the runner know it can run stories.
							  if (triggerRerun) {
								  triggerRerun = NO;
								  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RERUN_GROUP_NOTIFICATION object:nil]];
							  }
						  }];
}

-(UIView *) uiParentView {
	return [[[[UIApplication sharedApplication].windows objectAtIndex:0] subviews] lastObject];
}


@end
