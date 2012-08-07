//
//  SIStoryInAppViewController.h
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIStoryDetailsController.h"

/**
 Table view controller for the report on all the stories which where run.
 */
@interface SIStoryListController : UITableViewController<UISearchDisplayDelegate, UISearchBarDelegate> {
@private
	UISearchDisplayController *searchController;
	SIStoryDetailsController *detailsController;
}

/// @name Running stories

/// Re-runs all the currently visible stories.
-(void) rerunStories;

/// Called from the details screen to re-run all the currently display stories.
-(void) rerunStory;

@end
