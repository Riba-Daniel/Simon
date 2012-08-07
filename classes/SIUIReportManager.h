//
//  SIInAppReporter.h
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryListController.h"

/**
 Manages the UI display of the results of a run of stories.
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
