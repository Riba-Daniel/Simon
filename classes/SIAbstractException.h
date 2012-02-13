//
//  AbstractSIException.h
//  Simon
//
//  Created by Derek Clarkson on 13/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Parent of all SI Exceptions.
 */
@interface SIAbstractException : NSException
/**
 Quick method for creating exceptions where the exception defines the name and userInfo field values.
 */
+(NSException *) exceptionWithReason:(NSString *) reason;

@end
