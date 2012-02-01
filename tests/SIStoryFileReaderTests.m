//
//  FileTests.m
//  Simon
//
//  Created by Derek Clarkson on 5/29/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import "SIStoryFileReader.h"
#import "SIConstants.h"
#import "SIStory.h"
#import "SIStorySource.h"

@interface SIStoryFileReaderTests : GHTestCase {}

@end

@implementation SIStoryFileReaderTests

-(void) testInitReturnsAllStoryFiles {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] init] autorelease];
	GHAssertEquals([fileSystemStoryReader.files count], (NSUInteger) 8, @"Incorrect number of files returned");
	GHAssertEqualStrings(STORY_EXTENSION, [(NSString *)[fileSystemStoryReader.files objectAtIndex:0] pathExtension], @"Incorrect extension");
}

-(void) testInitWithFileNameReturnsStoryFile {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] initWithFileName:@"Story files"] autorelease];
	GHAssertEquals([fileSystemStoryReader.files count], (NSUInteger)1, @"Incorrect number of files returned");
	GHAssertEqualStrings(@"Story files." STORY_EXTENSION, [[fileSystemStoryReader.files objectAtIndex:0] lastPathComponent], @"Wrong file returned");
}

-(void) testInitWithFileNameAndExtensionReturnsStoryFile {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] initWithFileName:@"Story files." STORY_EXTENSION] autorelease];
	GHAssertEquals([fileSystemStoryReader.files count], (NSUInteger)1, @"Incorrect number of files returned");
	GHAssertEqualStrings(@"Story files." STORY_EXTENSION, [[fileSystemStoryReader.files objectAtIndex:0] lastPathComponent], @"Wrong file returned");
}

-(void) testThrowsErrorWhenCannotFindAFile {
	@try {
		[[[SIStoryFileReader alloc] initWithFileName:@"xxxxx"] autorelease];
		GHFail(@"Exception not thrown");
	}
	@catch (NSException *exception) {
		// Everything ok.
	}
}

-(void) testReturnsErrorWhenReadingUnknownKeywords {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] initWithFileName:@"Non keyword steps"] autorelease];
	NSError * error = nil;
	GHAssertNil([fileSystemStoryReader readStorySources:&error], @"Should not have returned an object.");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidKeyword, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Story syntax error, unknown keyword", @"Incorrect error message");
}

-(void) testReturnsErrorWhenReadingNonWords {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] initWithFileName:@"Non word steps"] autorelease];
	NSError * error = nil;
	GHAssertNil([fileSystemStoryReader readStorySources:&error], @"Should not have returned an object.");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidKeyword, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Story syntax error, unknown keyword", @"Incorrect error message");
}

-(void) testReturnsErrorWhenAndOutOfOrder {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] initWithFileName:@"Out of order steps1"] autorelease];
	NSError * error = nil;
	NSArray *stories = [fileSystemStoryReader readStorySources:&error];
	GHAssertNil(stories, @"Should not have returned an object.");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidStorySyntax, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Incorrect keyword order", @"Incorrect error message");
}

-(void) testReturnsErrorWhenThenOutOfOrder {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] initWithFileName:@"Out of order steps2"] autorelease];
	NSError * error = nil;
	GHAssertNil([fileSystemStoryReader readStorySources:&error], @"Should not have returned an object.");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidStorySyntax, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Incorrect keyword order", @"Incorrect error message");
}

-(void) testReturnsErrorWhenMultipleThens {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] initWithFileName:@"Out of order steps3"] autorelease];
	NSError * error = nil;
	GHAssertNil([fileSystemStoryReader readStorySources:&error], @"Shuld not have returned an object.");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidStorySyntax, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Incorrect keyword order", @"Incorrect error message");
}

-(void) testReturnsValidStories {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] initWithFileName:@"Story files"] autorelease];
	NSError * error = nil;
	NSArray * storySources = [fileSystemStoryReader readStorySources:&error];
	
	GHAssertNil(error, @"Unexpected error thrown %@", error.localizedDescription);
	GHAssertEquals([storySources count], (NSUInteger) 1, @"incorrect number of story sources returned");
	GHAssertTrue([((SIStorySource *)[storySources objectAtIndex:0]).source hasSuffix:@"Story files.stories"], @"Title not correct");
	
	NSArray *stories = ((SIStorySource *)[storySources objectAtIndex:0]).stories;
	GHAssertEquals([stories count], (NSUInteger) 2, @"incorrect number of stories returned");
	GHAssertEqualStrings([(SIStory *)[stories objectAtIndex:0] title], @"Basic story", @"Title not correct");
	GHAssertEqualStrings([(SIStory *)[stories objectAtIndex:1] title], @"Meaningless story", @"Title not correct");
}

-(void) testReturnsValidStoriesFromUnformattedSource {
	SIStoryFileReader * fileSystemStoryReader = [[[SIStoryFileReader alloc] initWithFileName:@"Unformatted"] autorelease];
	NSError * error = nil;
	NSArray * storySources = [fileSystemStoryReader readStorySources:&error];
	
	GHAssertNil(error, @"Unexpected error thrown %@", error.localizedDescription);
	GHAssertEquals([storySources count], (NSUInteger) 1, @"incorrect number of story sources returned");
	GHAssertTrue([((SIStorySource *)[storySources objectAtIndex:0]).source hasSuffix:@"Unformatted.stories"], @"Title not correct");
	
	NSArray *stories = ((SIStorySource *)[storySources objectAtIndex:0]).stories;
	GHAssertEquals([stories count], (NSUInteger) 1, @"incorrect number of stories returned");
	GHAssertEqualStrings([(SIStory *)[stories objectAtIndex:0] title], @"NoSpaceInStoryTitleAndUnformatted", @"Title not correct");
}

@end
