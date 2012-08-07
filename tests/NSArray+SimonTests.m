//
//  NSArray+SimonTests.m
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStorySource.h>
#import <Simon/SIStory.h>
#import <Simon/NSArray+Simon.h>

@interface NSArray_SimonTests : GHTestCase {
	@private
	SIStorySource *source1;
	SIStorySource *source2;
	
	SIStory * story1;
	SIStory * story2;
	SIStory * story3;
	
	NSArray *sources;
}

@end

@implementation NSArray_SimonTests

-(void) setUp {
	source1 = [[SIStorySource alloc] init];
	source2 = [[SIStorySource alloc] init];
	
	story1 = [[SIStory alloc] init];
	story2 = [[SIStory alloc] init];
	story3 = [[SIStory alloc] init];
	
	source1.stories = [NSArray arrayWithObjects:story1, nil];
	source2.stories = [NSArray arrayWithObjects:story2, story3, nil];
	
	sources = [[NSArray arrayWithObjects:source1, source2, nil] retain];
	
}

-(void) tearDown {
	DC_DEALLOC(story1);
	DC_DEALLOC(story2);
	DC_DEALLOC(story3);
	DC_DEALLOC(source1);
	DC_DEALLOC(source2);
	DC_DEALLOC(sources);
}

-(void) testStoriesFromSource {
	NSArray *allStories = [sources storiesFromSources];
	GHAssertEquals([allStories count], (NSUInteger) 3, nil);
	GHAssertTrue([allStories containsObject:story1], nil);
	GHAssertTrue([allStories containsObject:story2], nil);
	GHAssertTrue([allStories containsObject:story3], nil);
}

-(void) testFilteringSourcesFindsSourcesWithName {
	source1.source = @"abc";
	source2.source = @"def";

	NSArray *filteredSources = [sources filter:@"abc"];
	GHAssertEquals([filteredSources count], (NSUInteger) 1, nil);
	GHAssertEquals(((SIStorySource *)[filteredSources lastObject]).source, source1.source, nil);
}

@end
