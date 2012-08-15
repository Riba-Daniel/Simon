//
//  SIStorySourcesTests.m
//  Simon
//
//  Created by Derek Clarkson on 11/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStorySources.h>
#import <Simon/SIStorySource.h>
#import <Simon/SIStory.h>

@interface SIStorySourcesTests : GHTestCase {
	@private
	SIStorySources *sources;
	SIStorySource *source1;
	SIStorySource *source2;
}

@end

@implementation SIStorySourcesTests

-(void) setUp {
	sources = [[SIStorySources alloc] init];

	source1 = [[SIStorySource alloc] init];
	source1.source = @"abc";
	SIStory *story1 = [[[SIStory alloc] init] autorelease];
	[source1 addStory:story1];
	[sources addSource:source1];

	source2 = [[SIStorySource alloc] init];
	source2.source = @"abc";
	SIStory *story2 = [[[SIStory alloc] init] autorelease];
	[source1 addStory:story2];
	[sources addSource:source2];
}

-(void) tearDown {
	DC_DEALLOC(sources);
	DC_DEALLOC(source1);
	DC_DEALLOC(source2);
}

-(void) testSources {
	NSArray *sourcesList = sources.sources;
	GHAssertEquals([sourcesList count], (NSUInteger) 2, nil);
	GHAssertEquals([sourcesList objectAtIndex:0], source1, nil);
	GHAssertEquals([sourcesList objectAtIndex:1], source2, nil);
}

-(void) testSelectedSources {
	[sources selectWithPrefix:@"ab"];
	NSArray *sourcesList = sources.selectedSources;
	GHAssertEquals([sourcesList count], (NSUInteger) 1, nil);
	GHAssertEquals([sourcesList objectAtIndex:0], source1, nil);
}

-(void) testSelectedSourcesCached {
	[sources selectWithPrefix:@"ab"];
	NSArray *sourcesList1 = sources.selectedSources;
	NSArray *sourcesList2 = sources.selectedSources;
	GHAssertEquals(sourcesList1, sourcesList2, nil);
}

-(void) testSelectAll {
	[sources selectAll];
	NSArray *sourcesList = sources.selectedSources;
	GHAssertEquals([sourcesList count], (NSUInteger) 2, nil);
}

-(void) testSelectAllClearsCriteria {
	[sources selectWithPrefix:@"ab"];
	[sources selectAll];
	GHAssertNil(sources.selectionCriteria, nil);
}

-(void) testSelectingStoriesReturnsSelectionCriteria {
	[sources selectWithPrefix:@"ab"];
	GHAssertEquals(sources.selectionCriteria, @"ab", nil);
}

@end
