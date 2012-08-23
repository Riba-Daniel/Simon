//
//  SIStorySource.h
//  Simon
//
//  Created by Derek Clarkson on 11/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <Simon/SIStory.h>

/**
 Represents a source of stories. Mainly used for reporting purposes.
 */
@interface SIStorySource : NSObject

/**
 The source file which the story was read from.
 */
@property (nonatomic, retain) NSString *source;

/**
 A list of the stories read from the file. These are SIStory implementations.
 */
@property (nonatomic, readonly) NSArray *stories;

/// THe stories that have been selected.
@property (nonatomic, readonly) NSArray *selectedStories;

/**
 Adds a story to the array of stories.
 */
-(void) addStory:(SIStory *) story;

/**
 Selects all stories whose titles start with the prefix or if the prefix matches the filename, selects all stories.
 
 @param prefix the prefix to look for.
 */
-(void) selectWithPrefix:(NSString *) prefix;

/**
 Selects all stories.
 */
-(void) selectAll;

/// Deselects all stories.
-(void) selectNone;

@end
