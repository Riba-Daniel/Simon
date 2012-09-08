//
//  DtiPhoneSimulatorSession+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 5/09/12.
//  Copyright (c) 2012. All rights reserved.
//

/**
 Category which gives us access to the internals of the Simulator sessions.
 */

#import "DTiPhoneSimulatorSession.h"

/// Returns the ProcessSerialNumber assigned to the simulator when it starts.
@interface DTiPhoneSimulatorSession (Pieman)
@property (nonatomic, readonly) ProcessSerialNumber processSerialNumber;
@end
