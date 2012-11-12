//
//  SIStoryDetailsTableViewController.h
//  Simon
//
//  Created by Derek Clarkson on 24/10/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Simon/SIStoryGroup.h>
#import <Simon/SIStory.h>

/**
 Table view controller for the details window.
 */
@interface SIStoryDetailsController : UITableViewController {
}

/// @name Properties

/// The source file of the story.
@property (nonatomic, retain) SIStoryGroup *storyGroup;

/// The story being displayed.
@property (nonatomic, retain) SIStory *story;

@end
