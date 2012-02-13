//
//  AbstractSIException.m
//  Simon
//
//  Created by Derek Clarkson on 13/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIAbstractException.h"

@implementation SIAbstractException

+(NSException *) exceptionWithReason:(NSString *) reason {
   NSString *className = NSStringFromClass(self);
   return [[[self alloc] initWithName:className reason:reason userInfo:nil] autorelease];
}

@end
