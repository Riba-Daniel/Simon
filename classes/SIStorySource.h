//
//  SIStorySource.h
//  Simon
//
//  Created by Derek Clarkson on 11/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStory.h"

/**
 Represents a source of stories. Mainly used for reporting purposes.
 */
@interface SIStorySource : NSObject<NSCopying>

/**
 The source file which the story was read from.
 */
@property (nonatomic, retain) NSString *source;

/**
 A list of the stories read from the file. These are SIStory implementations.
 */
@property (nonatomic, retain) NSArray *stories;

/**
 Adds a story to the array of stories.
 */
-(void) addStory:(SIStory *) story;

/**
 Returns a new array containing all the stories with the matching prefix based on their title.
 
 @param prefix the text which a story's title must start with.
 */
-(NSArray *) storiesWithPrefix:(NSString *) prefix;

@end
