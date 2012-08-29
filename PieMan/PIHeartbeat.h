//
//  PIHeartbeat.h
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "PIHeartbeatDelegate.h"

@interface PIHeartbeat : NSObject

@property (nonatomic, assign) NSObject<PIHeartbeatDelegate> *delegate;

-(void) start;

@end
