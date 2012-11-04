//
//  SIStorySyntaxParser.h
//  Simon
//
//  Created by Derek Clarkson on 1/11/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIStorySource.h>

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

/// @name Initialisers

/**
 Default initialiser.
 
 @param source the story source that the story comes from.
 @return an instance of this class.
 */
-(id) initWithSource:(SIStorySource *) source;

/// @name Tasks

/**
 Checks a line to see if it is valid.
 
 @param line the line to test.
 @param lineNumber the line number of the line. Used for reporting errors.
 @param error a pointer to an NSError variable.
 @return YES if the line is valid.
 */
-(BOOL) checkLine:(NSString *) line lineNumber:(NSInteger) lineNumber error:(NSError **) error;

@end
