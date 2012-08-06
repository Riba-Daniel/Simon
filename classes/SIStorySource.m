//
//  SIStorySource.m
//  Simon
//
//  Created by Derek Clarkson on 11/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStorySource.h"
#import <dUsefulStuff/DCCommon.h>
#import "NSString+Simon.h"

@implementation SIStorySource

@synthesize stories = _stories;
@synthesize source = _source;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.stories = nil;
	self.source = nil;
	[super dealloc];
}

-(void) addStory:(SIStory *) story {
	self.stories = [self.stories arrayByAddingObject:story];
}

-(id) copyWithZone:(NSZone *)zone {
	
	SIStorySource *newSource = [[SIStorySource alloc] init];
	
	newSource.stories = self.stories;
	newSource.source = self.source;
	
	return newSource;
}

-(NSArray *) storiesWithPrefix:(NSString *) prefix {
	NSArray *filteredStories = [self.stories objectsAtIndexes:[self.stories indexesOfObjectsPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
		return [((SIStory *) obj).title hasPrefix:prefix options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
	}]];
	return filteredStories;
}

@end
