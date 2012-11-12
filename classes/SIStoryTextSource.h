//
//  SIStoryTextSource.h
//  Simon
//
//  Created by Derek Clarkson on 9/11/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIStoryTextSourceDelegate.h>

/**
 Protocol for classes which can generate story text. These are passed to the SIStoryAnalyser and feed it the text to analyse.
 */
@protocol SIStoryTextSource <NSObject>

/// @name Properties

/// This delegate must be set or an error will be triggered. Weak reference.
@property (nonatomic, assign) id<SIStoryTextSourceDelegate> delegate;

/// @name Tasks

/**
 Start the source.
 
 @param error a reference to an error variable which will be populated if there is a problem starting.
 @return YES if the start was successful.
 */
-(BOOL) startWithError:(NSError **) error;

@end
