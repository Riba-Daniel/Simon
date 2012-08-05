//
//  FileSystemStoryReader.h
//  Simon
//
//  Created by Derek Clarkson on 5/30/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon-core/SIStory.h>
#import <Simon-core/SIStorySource.h>

/**
 This class is used to read story files from the application. Each file must has the extension *.stories*.
 */
@interface SIStoryFileReader : NSObject {
	@private
	NSCharacterSet *trimChars;
	SIKeyword priorKeyword;
	SIStorySource *currentSource;
	NSUInteger currentLineNumber;
}

/// @name Properties

/// List of the SIStorySource instances created from the files read in.
@property (retain, nonatomic) NSArray *storySources;

/// @name Stories

/**
 Reads the files and returns a list of SIStory objects.
 
 @param error a pointer to a reference where any errors will be stored.
 @return An NSArry containing SIStorySource instances.
 */
-(NSArray *) readStorySources:(NSError **) error;

@end
