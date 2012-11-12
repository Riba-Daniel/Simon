//
//  SIStorySyntaxParser.h
//  Simon
//
//  Created by Derek Clarkson on 1/11/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIStoryGroup.h>

/**
 Class which is used to syntax check the lines in a story to make sure they follow the correct seqeuence. Currently the sequence follows this:
 
     Story: ...
     as ...
     given ...
	  and  ...
     when ...
     and ...
     then ...
     and ...
 
 
 */
@interface SIStorySyntaxParser : NSObject

/// @name Tasks

/**
 Checks a line to see if it is valid and returns the keyword that was found.
 
 If no valid keyword was found or the syntax was wrong, this will return SIkeywordUnknown.
 
 @param line the line to test.
 @param error a pointer to an NSError variable.
 @return a value from the SIKeyword enum if valid, otherwise SIKeywordUnknown.
 */
-(SIKeyword) checkLine:(NSString *) line error:(NSError **) error;

@end
