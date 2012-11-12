//
//  SIStoryTextSourceDelegate.h
//  Simon
//
//  Created by Derek Clarkson on 10/11/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

@protocol SIStoryTextSource; // Stops circular references from killing build.

/**
 Implementated by classes which willbe feed text by an instance of SIStoryTextSource.
 */
@protocol SIStoryTextSourceDelegate <NSObject>

/// @name Story text

/**
 Called before the text source starts reading from the source.
 
 @param textSource an instance of SIStoryTextSource that will be sending the story text lines.
 @param source Where the story text will be read from.
 @param error if an error occurs this will be populated.
 @return YES if everything is ok, NO if an error has occured.
 */
-(BOOL) storyTextSource:(id<SIStoryTextSource>) textSource willReadFromSource:(NSString *) source error:(NSError **) error;

/**
 Called when a line of text is read from the source.
 
 @param textSource an instance of SIStoryTextSource that will be sending the story text lines.
 @param line the line of text from the source.
 @param error if an error occurs this will be populated.
 @return YES if everything is ok, NO if an error has occured.
 */
-(BOOL) storyTextSource:(id<SIStoryTextSource>) textSource readLine:(NSString *) line error:(NSError **) error;

/**
 Called after the text source starts reading from the source.
 
 @param textSource an instance of SIStoryTextSource that will be sending the story text lines.
 @param source Where the story text will be read from.
 @param error if an error occurs this will be populated.
 @return YES if everything is ok, NO if an error has occured.
 */
-(BOOL) storyTextSource:(id<SIStoryTextSource>) textSource didReadFromSource:(NSString *) source error:(NSError **) error;

@end
