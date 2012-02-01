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
@interface SIStoryReportTableViewController : UITableViewController {
@private
}

/// A list of the story source files.
@property (nonatomic, retain) NSArray *storySources;

/// A list of all the SIStepMapping objects that where created.
@property (nonatomic, retain) NSArray *mappings;

@end
