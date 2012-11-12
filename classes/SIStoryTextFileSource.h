//
//  SIStoryFileSource.h
//  Simon
//
//  Created by Derek Clarkson on 9/11/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIStoryTextSource.h>

/**
 This class reads story files from the file system and feeds the lines of text to the SIStoryAnalyser.
 */
@interface SIStoryTextFileSource : NSObject<SIStoryTextSource>

/// @name Properties

/// If set before starting, the source will only read this file. Mainly used for testing.
@property (nonatomic, retain) NSString *singleFile;

@end
