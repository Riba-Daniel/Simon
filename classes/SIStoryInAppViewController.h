//
//  SIStoryInAppViewController.h
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SIStoryInAppViewController : UITableViewController {
@private
	CGSize initSize;
}

@property (nonatomic, retain) NSArray *stories;
@property (nonatomic, retain) NSArray *mappings;

-(id) initWithSize:(CGSize) size;



@end
