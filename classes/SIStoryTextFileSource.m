//
//  SIStoryFileSource.m
//  Simon
//
//  Created by Derek Clarkson on 9/11/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIStoryTextFileSource.h"
#import <Simon/SIConstants.h>
#import <dUsefulStuff/DCCommon.h>
#import <dUsefuLStuff/NSObject+dUsefuLStuff.h>
#import <Simon/SIStoryTextSourceDelegate.h>

@interface SIStoryTextFileSource () {
	@private
	NSArray *_files;
}
-(BOOL) readFile:(NSString *) filename error:(NSError **) error;
@end

@implementation SIStoryTextFileSource

@synthesize delegate = _delegate;
@synthesize singleFile = _singleFile;

-(void) dealloc {
	self.delegate = nil;
	self.singleFile = nil;
	DC_DEALLOC(_files);
	[super dealloc];
}

-(BOOL) startWithError:(NSError **) error {

	// Must have delegate.
	assert(self.delegate != nil);
	
	if (self.singleFile == nil) {
		_files = [[[NSBundle mainBundle] pathsForResourcesOfType:STORY_EXTENSION inDirectory:nil] retain];
	} else {
		_files = [@[[[NSBundle mainBundle] pathForResource:[self.singleFile stringByDeletingPathExtension] ofType:STORY_EXTENSION]] retain];
	}
	DC_LOG(@"Number of source files read: %i", (int)[_files count]);
	
	for (NSString *filename in _files) {
		if (![self readFile:filename error:error]) {
			DC_LOG(@"Error reading story file: %@", [*error localizedFailureReason]);
			return NO;
		}
	}
	return YES;
}

-(BOOL) readFile:(NSString *) filename error:(NSError **) error {

	// Read the file.
	DC_LOG(@"Reading file: %@", filename);
	NSString *contents = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:error];
	if (contents == nil) {
		DC_LOG(@"Failed to read file %@", filename);
		return NO;
	}
	
	// Tell the analyser.
	if (![_delegate storyTextSource:self willReadFromSource:filename error:error]) {
		DC_LOG(@"Error reading file %@: %@", filename, [*error localizedFailureReason]);
		return NO;
	}
	
	// Break it up and process the lines.
	NSArray *lines = [contents componentsSeparatedByString:@"\n"];
	int lineNumber = 0;
	NSError *lineError = NULL;
	for (NSString *line in lines) {
		lineNumber++;
		if (![_delegate storyTextSource:self readLine:line error:&lineError]) {
			DC_LOG(@"Error reading file %@: %@", filename, [lineError localizedFailureReason]);
			// Create a new error with the line number.
			[self setError: error
						 code:lineError.code
				errorDomain:SIMON_ERROR_DOMAIN
		 shortDescription:[NSString stringWithFormat:@"Line %i: %@", lineNumber, [lineError localizedDescription]]
			 failureReason:[NSString stringWithFormat:@"File: %@[%i] %@", [filename lastPathComponent], lineNumber, [lineError localizedFailureReason]]];
			return NO;
		}
	}

	// Tell the analyser.
	return [_delegate storyTextSource:self didReadFromSource:filename error:error];
	
}

@end
