//
//  PieMan.h
//  Simon
//
//  Created by Derek Clarkson on 28/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PIHeartbeatDelegate.h"

/**
 This is the main class of Pieman.
 */
@interface PIPieman : NSObject<PIHeartbeatDelegate>

/// Set to YES when the tests are finished.
@property (nonatomic, readonly) BOOL finished;

/// The full path to the app to be tested.
@property (nonatomic, retain) NSString *appPath;

-(void) start;

@end
