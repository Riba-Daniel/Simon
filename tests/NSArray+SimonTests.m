//
//  NSArray+SimonTests.m
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

#import <Simon/SIStorySource.h>
#import <Simon/SIStory.h>
#import <Simon/NSArray+Simon.h>

@interface NSArray_SimonTests : GHTestCase

@end

@implementation NSArray_SimonTests

-(void) testStoriesFromSource {
	
	SIStorySource *source1 = [[[SIStorySource alloc] init] autorelease];
	SIStorySource *source2 = [[[SIStorySource alloc] init] autorelease];
	
	SIStory * story1 = [[[SIStory alloc] init] autorelease];
	SIStory * story2 = [[[SIStory alloc] init] autorelease];
	SIStory * story3 = [[[SIStory alloc] init] autorelease];
	
	source1.stories = [NSArray arrayWithObjects:story1, nil];
	source2.stories = [NSArray arrayWithObjects:story2, story3, nil];
	
	NSArray *sources = [NSArray arrayWithObjects:source1, source2, nil];

	NSArray *allStories = [sources storiesFromSources];
	GHAssertEquals([allStories count], (NSUInteger) 3, nil);
	GHAssertTrue([allStories containsObject:story1], nil);
	GHAssertTrue([allStories containsObject:story2], nil);
	GHAssertTrue([allStories containsObject:story3], nil);
	
}

-(void) testFilteringSources {

	SIStorySource *source1 = [[[SIStorySource alloc] init] autorelease];
	source1.source = @"abc";
	SIStorySource *source2 = [[[SIStorySource alloc] init] autorelease];
	source1.source = @"def";
	
	NSArray *sources = [NSArray arrayWithObjects:source1, source2, nil];

	NSArray *filteredSources = [sources filter:@"abc"];
	GHAssertEquals([sources count], (NSUInteger) 1, nil);
	
}

@end
