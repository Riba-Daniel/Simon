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

@interface SIStorySource () {
	@private
}
@end

@implementation SIStorySource

@synthesize stories = _stories;
@synthesize selectedStories = _selectedStories;
@synthesize source = _source;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.source = nil;
	DC_DEALLOC(_stories);
	DC_DEALLOC(_selectedStories);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		_stories = [[NSMutableArray alloc] init];
	}
	return self;
}

-(NSArray *) selectedStories {
	if (_selectedStories == nil) {
		[self selectAll];
	}
	return _selectedStories;
}

-(void) addStory:(SIStory *) story {
	[(NSMutableArray *)self.stories addObject:story];
	// Clear so next request for selected gets everything.
	DC_DEALLOC(_selectedStories);
}

-(void) selectWithPrefix:(NSString *) prefix {
	
	// First see if the source name matches.
	NSString *filename = [_source lastPathComponent];
	if ([filename hasPrefix:prefix options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]) {
		[self selectAll];
		return;
	}
	
	// Now check each story title.
	DC_DEALLOC(_selectedStories);
	NSMutableIndexSet *selectedIndexes = [[NSMutableIndexSet alloc] init];
	[self.stories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([((SIStory *) obj).title hasPrefix:prefix options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]) {
			[selectedIndexes addIndex:idx];
		}
	}];
	_selectedStories = [[_stories objectsAtIndexes:selectedIndexes] retain];
	DC_DEALLOC(selectedIndexes);
}

-(void) selectAll {
	DC_DEALLOC(_selectedStories);
	_selectedStories = [[NSArray arrayWithArray:_stories] retain];
}

-(void) selectNone {
	DC_DEALLOC(_selectedStories);
	_selectedStories = [[NSArray alloc] init];
}

@end
