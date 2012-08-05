//
//  SIInAppReporter.h
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIStoryReportTableViewController.h"

/**
 An implementation of SIStoryReporter which produces a log of the run on console.
 */
@interface SIUIReportManager : NSObject {
	@private 
	UINavigationController *navController;
}

/**
 Displays the UI over the top of the app.
 */
-(void) displayUI;

/**
 Called to remove the window from the screen.
 */
-(void) removeWindow;

@end
