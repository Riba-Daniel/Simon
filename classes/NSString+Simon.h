//
//  NSString+Utils.h
//  Simon
//
//  Created by Derek Clarkson on 6/18/11.
//  Copyright 2011. All rights reserved.
//

#import <Simon/SIConstants.h>
#import <Simon/SIStory.h>

/**
 Utility methods for strings.
 */
@interface NSString (Simon)

/// @name Class methods

/**
 Returns the string description of a story's status.
 
 @param story the story we want the status of.
 */
+(NSString *) stringStatusWithStory:(SIStory *) story;

/**
 Returns a string representation of the keyword.
 
 @param keyword the keyword we want the string for.
 @return an NSString instance.
 */
+(NSString *) stringFromSIKeyword:(SIKeyword) keyword;

/**
 Returns YES if the value is nil or contains no actual textural data. All whitespace is ignored.
 
 @return YES if the value is nil, empty or contains only whitespace characters.
 */
+ (BOOL) isEmpty:(NSString *) value;


/// @name Instance methods

/**
 * Returns the string with any leading and trail quotes removed. Works with both
 * single and double quotes.
 */
-(NSString *) stringByRemovingQuotes;

/**
 Examines a string and returns the matching SIKeyword.
 
 @return the matching SIkeyword.
 */
-(SIKeyword) siKeyword;

/**
 A more complex prefix check which applies the passed options. Typically these specify such things as case sensitivity.
 
 @param prefix the string to test for a prefix match.
 @param options the options to use in the match. See NSString:compare:options:range: for details on the options.
 @see NSString:compare:options:range:
 @return YES if there is a match.
 */
-(BOOL) hasPrefix:(NSString *) prefix options:(int) options;

/**
 Returns the string converted to a SIHttpMethod value.
 
 @return the matching SIHttpMethod.
 */
-(SIHttpMethod) siHttpMethod;

@end
