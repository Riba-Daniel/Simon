//
//  AbstractSIException.h
//  Simon
//
//  Created by Derek Clarkson on 13/02/12.
//  Copyright (c) 2012. All rights reserved.
//

/**
 Parent of all SI Exceptions. This contains code to shorten the act of creating an exception and to standardize the name field.
 */
@interface SIAbstractException : NSException
/**
 Quick method for creating exceptions where the exception defines the name and userInfo field values.
 
 @param reason the text reason for creating the exception.
 */
+(NSException *) exceptionWithReason:(NSString *) reason;

@end
