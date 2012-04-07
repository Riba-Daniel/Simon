//
//  SIStoryDetailsTableViewController.h
//  Simon
//
//  Created by Derek Clarkson on 24/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIStorySource.h"
#import "SIStory.h"

/**
 Table view controller for the details window.
 */
@interface SIStoryDetailsTableViewController : UITableViewController {
}

/// The source file of the story.
@property (nonatomic, retain) SIStorySource *source;

/// The story being displayed.
@property (nonatomic, retain) SIStory *story;

@end
