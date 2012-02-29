//
//  UIEvent+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This category opens the UIEvent class so that events can be created programmatically. It is based on the excellant work done by Matt Gallagher.
 */
@interface UIEvent (Simon)

/**
 Default constructor.
 
 @param touch the UITouch to init with.
 */
- (id)initWithTouch:(UITouch *)touch;

/**
 Tells the event to update it's timestamp to now. This is important for the UI.
 */
-(void) updateTimeStamp;

@end
