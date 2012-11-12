//
//  FileTests.m
//  Simon
//
//  Created by Derek Clarkson on 5/29/11.
//  Copyright 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStoryAnalyser.h>
#import <Simon/SIConstants.h>
#import <Simon/SIStory.h>
#import <Simon/SIStoryGroup.h>
#import <Simon/SIStoryTextFileSource.h>

@interface SIStoryAnalyserTests : GHTestCase {
@private
	SIStoryAnalyser *reader;
	NSError *error;
}
-(void) setReaderWithSingleFile:(NSString *) filename;
@end

@implementation SIStoryAnalyserTests

-(void) setUp {
	[super setUp];
	error = NULL;
}

-(void) tearDown {
	DC_DEALLOC(reader);
	[super tearDown];
}


-(void) testReturnsErrorWhenReadingUnknownKeywords {
	[self setReaderWithSingleFile:@"Non keyword steps.stories"];
	BOOL result = [reader startWithError:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidKeyword, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Line 1: Story syntax error, unknown keyword This", @"Incorrect error message");
}

-(void) testReturnsErrorWhenReadingNonWords {
	[self setReaderWithSingleFile:@"Non word steps.stories"];
	BOOL result = [reader startWithError:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidKeyword, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Line 3: Story syntax error, step does not begin with a word", @"Incorrect error message");
}

-(void) testReturnsErrorWhenAndOutOfOrder {
	[self setReaderWithSingleFile:@"Out of order steps1.stories"];
	BOOL result = [reader startWithError:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidStorySyntax, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Line 2: Invalid syntax", @"Incorrect error message");
}

-(void) testReturnsErrorWhenThenOutOfOrder {
	[self setReaderWithSingleFile:@"Out of order steps2.stories"];
	BOOL result = [reader startWithError:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidStorySyntax, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Line 2: Invalid syntax", @"Incorrect error message");
}

-(void) testReturnsErrorWhenMultipleThens {
	[self setReaderWithSingleFile:@"Out of order steps3.stories"];
	BOOL result = [reader startWithError:&error];
	GHAssertFalse(result, @"Should have returned false");
	GHAssertNotNil(error, @"Error not thrown");
	GHAssertEquals(error.code, SIErrorInvalidStorySyntax, @"Incorrect error thrown");
	GHAssertEqualStrings(error.localizedDescription, @"Line 5: Invalid syntax", @"Incorrect error message");
}

-(void) testReturnsValidStories {
	[self setReaderWithSingleFile:@"Story files.stories"];
	BOOL result = [reader startWithError:&error];
	GHAssertTrue(result, @"Should have returned true");
	NSArray * storyGroupManager = reader.storyGroupManager.storyGroups;
	
	GHAssertNil(error, @"Unexpected error thrown %@", error.localizedDescription);
	GHAssertEquals([storyGroupManager count], (NSUInteger) 1, @"incorrect number of story sources returned");
	GHAssertTrue([((SIStoryGroup *)[storyGroupManager objectAtIndex:0]).source hasSuffix:@"Story files.stories"], @"Title not correct");
	
	NSArray *stories = ((SIStoryGroup *)[storyGroupManager objectAtIndex:0]).stories;
	GHAssertEquals([stories count], (NSUInteger) 2, @"incorrect number of stories returned");
	GHAssertEqualStrings([(SIStory *)[stories objectAtIndex:0] title], @"Basic story", @"Title not correct");
	GHAssertEqualStrings([(SIStory *)[stories objectAtIndex:1] title], @"Meaningless story", @"Title not correct");
}

-(void) testReturnsValidStoriesFromUnformattedSource {
	[self setReaderWithSingleFile:@"Unformatted.stories"];
	BOOL result = [reader startWithError:&error];
	GHAssertTrue(result, @"Should have returned true");
	NSArray * storyGroupManager = reader.storyGroupManager.storyGroups;

	GHAssertNil(error, @"Unexpected error thrown %@", error.localizedDescription);
	GHAssertEquals([storyGroupManager count], (NSUInteger) 1, @"incorrect number of story sources returned");
	GHAssertTrue([((SIStoryGroup *)[storyGroupManager objectAtIndex:0]).source hasSuffix:@"Unformatted.stories"], @"Title not correct");
	
	NSArray *stories = ((SIStoryGroup *)[storyGroupManager objectAtIndex:0]).stories;
	GHAssertEquals([stories count], (NSUInteger) 1, @"incorrect number of stories returned");
	GHAssertEqualStrings([(SIStory *)[stories objectAtIndex:0] title], @"NoSpaceInStoryTitleAndUnformatted", @"Title not correct");
}

#pragma mark - Internal

-(void) setReaderWithSingleFile:(NSString *) filename {
	SIStoryTextFileSource *source = [[[SIStoryTextFileSource alloc] init] autorelease];
	source.singleFile = filename;
	reader = [[SIStoryAnalyser alloc] initWithStoryTextSource:source];
}


@end
