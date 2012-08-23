//
//  SIInAppReporter.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <Simon/SIUIReportManager.h>
#import <Simon/SIStoryListController.h>
#import <UIKit/UIKit.h>
#import <dUsefulStuff/DCCommon.h>
#import "NSObject+Simon.h"

typedef void (^completion)();

@interface SIUIReportManager(_private)
-(UIView *) uiParentView;
-(void) closeSimon;
-(void) removeWindowAndRun:(NSNotification *) notification;
-(void) removeWindowWithCompletion:(completion) completion;
@end



@implementation SIUIReportManager

-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DC_DEALLOC(navController);
	DC_LOG(@"Deallocing");
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(removeWindowAndRun:)
																	name:SI_HIDE_WINDOW_RUN_STORIES_NOTIFICATION
																 object:nil];
	}
	return self;
}

-(void) displayUI {
	
	// Refire on the main thread.
	[self executeBlockOnMainThread: ^{
		
		SIStoryListController *reportController = [[SIStoryListController alloc] initWithStyle:UITableViewStylePlain];
		
		reportController.navigationItem.title = @"Simon's simple report";
		
		// Set a nav controller as the top controller and keep a reference to it.
		navController = [[UINavigationController alloc] initWithRootViewController:reportController];
		
		// Add buttons
		UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close Simon"
																							 style:UIBarButtonItemStylePlain
																							target:self
																							action:@selector(closeSimon)];
		UIBarButtonItem *rerunButton = [[UIBarButtonItem alloc] initWithTitle:@"Run"
																							 style:UIBarButtonItemStylePlain
																							target:self
																							action:@selector(removeWindowAndRun:)];
		reportController.navigationItem.leftBarButtonItem = closeButton;
		reportController.navigationItem.rightBarButtonItem = rerunButton;
		[closeButton release];
		[rerunButton release];
		[reportController release];
		
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

-(void) closeSimon {
	[self removeWindowWithCompletion:^(){
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_SHUTDOWN_NOTIFICATION object:nil]];
	}];
}

-(void) removeWindowAndRun:(NSNotification *) notification {
	[self removeWindowWithCompletion:^(){
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:self]];
	}];
}

-(void) removeWindowWithCompletion:(completion) completion {
	
	DC_LOG(@"Removing window");
	
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
							  completion();
						  }];
}

-(UIView *) uiParentView {
	return [[[[UIApplication sharedApplication].windows objectAtIndex:0] subviews] lastObject];
}


@end
