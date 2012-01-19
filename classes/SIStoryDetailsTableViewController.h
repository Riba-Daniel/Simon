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

@interface SIStoryDetailsTableViewController : UITableViewController

@property (nonatomic, retain) SIStorySource *source;
@property (nonatomic, retain) SIStory *story;


@end
