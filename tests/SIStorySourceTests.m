//
//  SIStorySourceTests.m
//  Simon
//
//  Created by Sensis on 6/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIStorySource.h>
#import <Simon/SIStory.h>

@interface SIStorySourceTests : GHTestCase

@end

@implementation SIStorySourceTests

-(void) testCopy {
	SIStorySource *source = [[[SIStorySource alloc] init] autorelease];
	SIStory *story = [[[SIStory alloc] init] autorelease];
	source.stories = [NSArray arrayWithObject:story];
	source.source = @"abc";
	
	SIStorySource *newSource = [source copy];
	GHAssertNotEquals(source, newSource, nil);
	GHAssertEquals(source.stories, newSource.stories, nil);
	GHAssertEquals(source.source, newSource.source, nil);
	
}

-(void) testStoriesWithPrefix {
	SIStorySource *source = [[[SIStorySource alloc] init] autorelease];
	SIStory *story1 = [[[SIStory alloc] init] autorelease];
	story1.title = @"Abc";
	SIStory *story2 = [[[SIStory alloc] init] autorelease];
	story2.title = @"def";
	source.stories = [NSArray arrayWithObjects:story1, story2, nil];
	
	NSArray *stories = [source storiesWithPrefix:@"ab"];
	GHAssertEquals([stories count], (NSUInteger) 1, nil);
	GHAssertEquals([stories lastObject], story1, nil);
}

@end
