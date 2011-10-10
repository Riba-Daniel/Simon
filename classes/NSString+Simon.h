//
//  NSString+Utils.h
//  Simon
//
//  Created by Derek Clarkson on 6/18/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIConstants.h"
#import "SIStory.h"

@interface NSString (Utils)

/**
 * Returns the string with any leading and trail quotes removed. Works with both
 * single and double quotes.
 */
-(NSString *) stringByRemovingQuotes;

/**
 Returns the string description of a story's status.
 */
+(NSString *) stringStatusWithStory:(SIStory *) story;

/**
 Examines a string and returns the matching SIKeyword.
 
 @param string an NSString instance containing a string which mapps to a SIKeyword.
 
 @return the matching SIkeyword.
 */
-(SIKeyword) keywordFromString;

/**
 Returns a string representation of the keyword.
 
 @param keyword the keyword we want the string for.
 @return an NSString instance.
 */
+(NSString *) stringFromKeyword:(SIKeyword) keyword;

@end
