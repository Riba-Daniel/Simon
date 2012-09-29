//
//  SIStorySourceTests.m
//  Simon
//
//  Created by on 6/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import <Simon/SIStorySource.h>
#import <Simon/SIStory.h>
#import <dUsefulStuff/DCCommon.h>

@interface SIStorySourceTests : GHTestCase {
	@private
	SIStorySource *source;
	SIStory *story1;
	SIStory *story2;
	SIStory *story3;
}

@end

@implementation SIStorySourceTests

-(void) setUp {
	source = [[SIStorySource alloc] init];
	story1 = [[SIStory alloc] init];
	story1.title = @"Abc";
	[source addStory:story1];
	story2 = [[SIStory alloc] init];
	story2.title = @"def";
	[source addStory:story2];
	story3 = [[SIStory alloc] init];
	story3.title = @"abc";
	[source addStory:story3];
}

-(void) tearDown {
	DC_DEALLOC(source);
	DC_DEALLOC(story1);
	DC_DEALLOC(story2);
	DC_DEALLOC(story3);
}

-(void) testStories {
	NSArray *stories = source.stories;
	GHAssertEquals([stories count], (NSUInteger) 3, nil);
	GHAssertEquals([stories objectAtIndex:0], story1, nil);
	GHAssertEquals([stories objectAtIndex:1], story2, nil);
	GHAssertEquals([stories objectAtIndex:2], story3, nil);
}

-(void) testSelectingStories {
	[source selectWithPrefix:@"ab"];
	NSArray *stories = source.selectedStories;
	GHAssertEquals([stories count], (NSUInteger) 2, nil);
	GHAssertEquals([stories objectAtIndex:0], story1, nil);
	GHAssertEquals([stories objectAtIndex:1], story3, nil);
}

-(void) testSelectStoriesCachesTheArray {
	[source selectWithPrefix:@"ab"];
	GHAssertEquals([source selectedStories], [source selectedStories], nil);
}

-(void) testSelectStoriesSelectsAllWhenMatchingSourceName {
	source.source = @"/a/b/c/mno.stories";
	[source selectWithPrefix:@"mn"];
	GHAssertEquals([[source selectedStories] count], (NSUInteger) 3, nil);
}

-(void) testSelectAll {
	[source selectAll];
	GHAssertEquals([[source selectedStories] count], (NSUInteger) 3, nil);
}

-(void) testSelectNone {
	[source selectNone];
	GHAssertEquals([[source selectedStories] count], (NSUInteger) 0, nil);
}

-(void) testInitWithJsonDictionary {
	NSDictionary *storyData = @{@"title":@"story title"};
	NSArray *storyArray = @[storyData];
	NSDictionary *dic = @{@"stories":storyArray, @"source":@"source-file-name"};
	
	SIStorySource *jsonSource = [[SIStorySource alloc] initWithJsonDictionary:dic];
	
	GHAssertNotNil(jsonSource, nil);
	GHAssertEqualObjects(jsonSource.source, @"source-file-name", nil);
	
	NSArray *storedStories = jsonSource.stories;
	GHAssertNotNil(storedStories, nil);
	GHAssertEquals([storedStories count], (NSUInteger) 1, nil);
	GHAssertTrue([storedStories[0] isKindOfClass:[SIStory class]], nil);
	GHAssertEquals(((SIStory *)storedStories[0]).title, @"story title", nil);
}

-(void) testJsonDictionary {
	
	source.source = @"abc";
	
	NSDictionary *data = [source jsonDictionary];

	GHAssertNotNil(data[@"source"], nil);
	GHAssertNotNil(data[@"stories"], nil);
	GHAssertEqualStrings(data[@"source"], @"abc", nil);
	
	NSArray *storyList = [data objectForKey:@"stories"];
	GHAssertEquals([storyList count], (NSUInteger) 3, nil);
	GHAssertEqualObjects(storyList[0][@"title"], @"Abc", nil);
	GHAssertEqualObjects(storyList[1][@"title"], @"def", nil);
	GHAssertEqualObjects(storyList[2][@"title"], @"abc", nil);
}


@end
