//
//  PieMan.h
//  Simon
//
//  Created by Derek Clarkson on 28/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PIHeartbeatDelegate.h"

/**
 This is the main class of Pieman.
 */
@interface PIPieMan : NSObject<PIHeartbeatDelegate>

@property (nonatomic, readonly) BOOL finished;

-(void) start;

@end
