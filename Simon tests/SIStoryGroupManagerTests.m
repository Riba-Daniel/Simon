//
//  SIStoryGroupManagerTests.m
//  Simon
//
//  Created by Derek Clarkson on 11/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStoryGroupManager.h>
#import <Simon/SIStoryGroup.h>

@interface SIStoryGroupManagerTests : GHTestCase {
	@private
	SIStoryGroupManager *storyGroupManager;
	SIStoryGroup *storyGroup1;
	SIStoryGroup *storyGroup2;
}

@end

@implementation SIStoryGroupManagerTests

-(void) setUp {
	storyGroupManager = [[SIStoryGroupManager alloc] init];

	storyGroup1 = [[SIStoryGroup alloc] init];
	storyGroup1.source = @"abc";
	SIStory *story1 = [[[SIStory alloc] init] autorelease];
	[storyGroup1 addStory:story1];
	[storyGroupManager addStoryGroup:storyGroup1];

	storyGroup2 = [[SIStoryGroup alloc] init];
	storyGroup2.source = @"abc";
	SIStory *story2 = [[[SIStory alloc] init] autorelease];
	[storyGroup1 addStory:story2];
	[storyGroupManager addStoryGroup:storyGroup2];
}

-(void) tearDown {
	DC_DEALLOC(storyGroupManager);
	DC_DEALLOC(storyGroup1);
	DC_DEALLOC(storyGroup2);
}

-(void) testSources {
	NSArray *sourcesList = storyGroupManager.storyGroups;
	GHAssertEquals([sourcesList count], (NSUInteger) 2, nil);
	GHAssertEquals([sourcesList objectAtIndex:0], storyGroup1, nil);
	GHAssertEquals([sourcesList objectAtIndex:1], storyGroup2, nil);
}

-(void) testselectedStoryGroups {
	[storyGroupManager selectWithPrefix:@"ab"];
	NSArray *sourcesList = storyGroupManager.selectedStoryGroups;
	GHAssertEquals([sourcesList count], (NSUInteger) 1, nil);
	GHAssertEquals([sourcesList objectAtIndex:0], storyGroup1, nil);
}

-(void) testselectedStoryGroupsCached {
	[storyGroupManager selectWithPrefix:@"ab"];
	NSArray *sourcesList1 = storyGroupManager.selectedStoryGroups;
	NSArray *sourcesList2 = storyGroupManager.selectedStoryGroups;
	GHAssertEquals(sourcesList1, sourcesList2, nil);
}

-(void) testSelectAll {
	[storyGroupManager selectAll];
	NSArray *sourcesList = storyGroupManager.selectedStoryGroups;
	GHAssertEquals([sourcesList count], (NSUInteger) 2, nil);
}

-(void) testSelectAllClearsCriteria {
	[storyGroupManager selectWithPrefix:@"ab"];
	[storyGroupManager selectAll];
	GHAssertNil(storyGroupManager.selectionCriteria, nil);
}

-(void) testSelectingStoriesReturnsSelectionCriteria {
	[storyGroupManager selectWithPrefix:@"ab"];
	GHAssertEquals(storyGroupManager.selectionCriteria, @"ab", nil);
}

@end
