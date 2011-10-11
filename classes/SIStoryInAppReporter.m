//
//  SIInAppReporter.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryInAppReporter.h"
#import "SIStoryInAppViewController.h"
#import <UIKit/UIKit.h>
#import <dUsefulStuff/DCCommon.h>

@interface SIStoryInAppReporter()
-(void) displayReportOnStorySources:(NSArray *) sources andMappings:(NSArray *) mappings;
-(void) handleTap:(UITapGestureRecognizer *)sender;    
@end


@implementation SIStoryInAppReporter

@synthesize reportController;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.reportController = nil;
	[backgroundView removeFromSuperview];
	DC_DEALLOC(backgroundView);
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
	
	// Add a background view.
	backgroundView = [[UIView alloc] initWithFrame:offScreen];
	backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
	[window addSubview:backgroundView];
	
	// Add a button to close the view.
	UIButton *close = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[close setTitle:@"Shutdown Simon" forState:UIControlStateNormal];
	[close sizeToFit];
	CGRect buttonFrame = CGRectMake(frame.size.width - close.frame.size.width - 40, onScreen.size.height - close.frame.size.height - 40, close.frame.size.width, close.frame.size.height);
	close.frame = buttonFrame;
	UIGestureRecognizer *tapRecogniser = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]autorelease];
	[close addGestureRecognizer:tapRecogniser];
	[backgroundView addSubview:close];
	
	// Add the report table view to the background.
	CGRect reportFrame = CGRectMake(0, 0, onScreen.size.width, close.frame.origin.y - 40);
	self.reportController = [[[SIStoryInAppViewController alloc] initWithSize:reportFrame.size] autorelease];
	self.reportController.stories = [sources valueForKeyPath:@"@unionOfArrays.stories"];
	self.reportController.mappings = mappings;
	[backgroundView addSubview:self.reportController.tableView];
	
	// Animate on.
	[UIView animateWithDuration:1.0 animations:^{
		backgroundView.frame = onScreen;
	}];
	
}

- (void)handleTap:(UITapGestureRecognizer *)sender {     
	if (sender.state == UIGestureRecognizerStateEnded) {       
		DC_LOG(@"tap triggered, shutting down Simon");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Simon shutdown" object:nil]];
	}
}

@end
