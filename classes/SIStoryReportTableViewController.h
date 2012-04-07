//
//  SIStoryInAppViewController.h
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIStoryDetailsTableViewController.h"

/**
 Table view controller for the report on all the stories which where run.
 */
@interface SIStoryReportTableViewController : UITableViewController<UISearchDisplayDelegate, UISearchBarDelegate> {
@private
	NSMutableArray *filteredSources;
	UISearchDisplayController *searchController;
	SIStoryDetailsTableViewController *detailsController;
}

/// @name Properties

/// A list of the story source files.
@property (nonatomic, retain) NSArray *storySources;

/// Search terms currently being used.
@property (nonatomic, retain) NSString *searchTerms;

/// If populated the details screen will be loaded with this story showing in it.
@property (nonatomic, retain) SIStorySource *showDetailsForStory;

/// @name Running stories

/// Re-runs all the currently visible stories.
-(void) rerunStories;

/// Called from the details screen to rr-run a single story.
-(void) rerunStory;

@end
