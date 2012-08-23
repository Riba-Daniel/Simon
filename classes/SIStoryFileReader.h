//
//  FileSystemStoryReader.h
//  Simon
//
//  Created by Derek Clarkson on 5/30/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon/SIStorySources.h>

/**
 This class is used to read story files from the application. Each file must has the extension *.stories*.
 */
@interface SIStoryFileReader : NSObject

/// @name Properties

/// Storage for the SIStorySource objects.
@property (nonatomic, readonly) SIStorySources *storySources;

/// @name Stories

/**
 Reads the files and load them into the storySources storage.
 
 @param error a pointer to a reference where any errors will be stored.
 @return YES if the reading of stories was successful. If NO there will be an NSError in the error variable.
 */
-(BOOL) readStorySources:(NSError **) error;

@end
