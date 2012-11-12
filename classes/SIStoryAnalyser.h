//
//  FileSystemStoryReader.h
//  Simon
//
//  Created by Derek Clarkson on 5/30/11.
//  Copyright 2011. All rights reserved.
//

#import <Simon/SIStoryGroupManager.h>
#import <Simon/SIStoryTextSource.h>
#import <Simon/SIStoryTextSourceDelegate.h>

/**
 This class is used to read story files from the application. Each file must has the extension *.stories*.
 */
@interface SIStoryAnalyser : NSObject<SIStoryTextSourceDelegate>

/// @name Initialisers

/**
 Default initaliser.
 
 @param storyTextSource the source which will generate story text.
 @return an instance of this class.
 */
-(id) initWithStoryTextSource:(id<SIStoryTextSource>) storyTextSource;

/// @name Properties

/// Storage for the SIStoryGroup objects.
@property (nonatomic, readonly) SIStoryGroupManager *storyGroupManager;

/// @name Tasks

/**
 Start the process of analysing story sources.
 
 @param error a reference to an error variable which will be populated if there is a problem starting.
 @return YES if the start was successful.
 */
-(BOOL) startWithError:(NSError **) error;

@end
