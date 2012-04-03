//
//  SIStoryInAppViewController.h
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Table view controller for the report on all the stories which where run.
 */
@interface SIStoryReportTableViewController : UITableViewController<UISearchDisplayDelegate, UISearchBarDelegate> {
@private
	NSMutableArray *filteredSources;
	UISearchDisplayController *searchController;
}

/// A list of the story source files.
@property (nonatomic, retain) NSArray *storySources;

-(void) rerunStories;

@end
