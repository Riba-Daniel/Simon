//
//  FileTests.m
//  Simon
//
//  Created by Derek Clarkson on 5/29/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStoryFileReader.h>
#import <Simon/SIConstants.h>
#import <Simon/SIStory.h>
#import <Simon/SIStorySource.h>

@interface SIStoryFileReader ()
-(BOOL) readFile:(NSString *) filename error:(NSError **) error;
@end

@interface SIStoryFileReaderTests : GHTestCase {
@private
	SIStoryFileReader *reader;
	NSError *error;
}
@end

@implementation SIStoryFileReaderTests

-(void) setUp {
	[super setUp];
	reader = [[SIStoryFileReader alloc] init];
	error = nil;
}

-(void) tearDown {
	DC_DEALLOC(reader);
	[super tearDown];
}

-(void) testReturnsErrorWhenReadingUnknownKeywords {
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Non keyword steps" ofType:STORY_EXTENSION inDirectory:nil];
	BOOL result = [reader readFile:fileName error:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidKeyword, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Story syntax error, unknown keyword", @"Incorrect error message");
}

-(void) testReturnsErrorWhenReadingNonWords {
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Non word steps" ofType:STORY_EXTENSION inDirectory:nil];
	BOOL result = [reader readFile:fileName error:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidKeyword, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Story syntax error, unknown keyword", @"Incorrect error message");
}

-(void) testReturnsErrorWhenAndOutOfOrder {
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Out of order steps1" ofType:STORY_EXTENSION inDirectory:nil];
	BOOL result = [reader readFile:fileName error:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidStorySyntax, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Incorrect keyword order", @"Incorrect error message");
}

-(void) testReturnsErrorWhenThenOutOfOrder {
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Out of order steps2" ofType:STORY_EXTENSION inDirectory:nil];
	BOOL result = [reader readFile:fileName error:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidStorySyntax, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Incorrect keyword order", @"Incorrect error message");
}

-(void) testReturnsErrorWhenMultipleThens {
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Out of order steps3" ofType:STORY_EXTENSION inDirectory:nil];
	BOOL result = [reader readFile:fileName error:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidStorySyntax, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Incorrect keyword order", @"Incorrect error message");
}

-(void) testReturnsValidStories {
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Story files" ofType:STORY_EXTENSION inDirectory:nil];
	BOOL result = [reader readFile:fileName error:&error];
	GHAssertTrue(result, @"Should have returned true");
	NSArray * storySources = reader.storySources.sources;
	
	GHAssertNil(error, @"Unexpected error thrown %@", error.localizedDescription);
	GHAssertEquals([storySources count], (NSUInteger) 1, @"incorrect number of story sources returned");
	GHAssertTrue([((SIStorySource *)[storySources objectAtIndex:0]).source hasSuffix:@"Story files.stories"], @"Title not correct");
	
	NSArray *stories = ((SIStorySource *)[storySources objectAtIndex:0]).stories;
	GHAssertEquals([stories count], (NSUInteger) 2, @"incorrect number of stories returned");
	GHAssertEqualStrings([(SIStory *)[stories objectAtIndex:0] title], @"Basic story", @"Title not correct");
	GHAssertEqualStrings([(SIStory *)[stories objectAtIndex:1] title], @"Meaningless story", @"Title not correct");
}

-(void) testReturnsValidStoriesFromUnformattedSource {
	NSString *fileName = [[NSBundle mainBundle] pathForResource:@"Unformatted" ofType:STORY_EXTENSION inDirectory:nil];
	BOOL result = [reader readFile:fileName error:&error];
	GHAssertTrue(result, @"Should have returned true");
	NSArray * storySources = reader.storySources.sources;

	GHAssertNil(error, @"Unexpected error thrown %@", error.localizedDescription);
	GHAssertEquals([storySources count], (NSUInteger) 1, @"incorrect number of story sources returned");
	GHAssertTrue([((SIStorySource *)[storySources objectAtIndex:0]).source hasSuffix:@"Unformatted.stories"], @"Title not correct");
	
	NSArray *stories = ((SIStorySource *)[storySources objectAtIndex:0]).stories;
	GHAssertEquals([stories count], (NSUInteger) 1, @"incorrect number of stories returned");
	GHAssertEqualStrings([(SIStory *)[stories objectAtIndex:0] title], @"NoSpaceInStoryTitleAndUnformatted", @"Title not correct");
}

-(void) testReadStories {
	GHAssertFalse([reader readStorySources:&error], nil);
	GHAssertEquals(error.code, SIErrorInvalidKeyword, nil);
}

@end
