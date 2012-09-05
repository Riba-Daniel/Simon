//
//  PISdkNotFoundException.h
//  Simon
//
//  Created by Derek Clarkson on 3/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SIAbstractException.h"

/**
 Exception thrown when an SDK version has been passed to the simulator, but there is no such version on the machine.
 */
@interface PISDKNotFoundException : SIAbstractException

@end
