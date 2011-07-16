//
//  NSObject+Utils.h
//  Simon
//
//  Created by Derek Clarkson on 6/8/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIEnums.h"

/**
 Extra methods applicable to all objects.
 */
@interface NSObject (NSObject_Utils)

/// @name Tasks

/**
 This creates NSError objects based on the passed information.
 
 @param errorCode
 */
-(NSError *) errorForCode:(SIError) errorCode shortDescription:(NSString *) shortDescription failureReason:(NSString *) failureReason; 

/**
 Examines a string and returns the matching SIKeyword.

 @param string an NSString instance containing a string which mapps to a SIKeyword.
 
 @return the matching SIkeyword.
 */
-(SIKeyword) keywordFromString:(NSString *) string;

/**
 Returns a string representation of the keyword.
 
 @param keyword the keyword we want the string for.
 @return an NSString instance.
 */
-(NSString *) stringFromKeyword:(SIKeyword) keyword;

@end
