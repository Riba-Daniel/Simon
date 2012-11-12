//
//  SIStoryGroupManager.m
//  Simon
//
//  Created by Derek Clarkson on 11/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIStoryGroupManager.h>
#import <dUsefulStuff/DCCommon.h>


@interface SIStoryGroupManager() {
	@private
}

@end

@implementation SIStoryGroupManager

@synthesize storyGroups = _storyGroups;
@synthesize selectedStoryGroups = _selectedStoryGroups;
@synthesize selectionCriteria = _selectionCriteria;
@synthesize currentIndexPath = _currentIndexPath;

-(void) dealloc {
	self.currentIndexPath = nil;
	DC_DEALLOC(_storyGroups);
	DC_DEALLOC(_selectedStoryGroups);
	DC_DEALLOC(_selectionCriteria);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		_storyGroups = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) addStoryGroup:(SIStoryGroup *) storyGroup {
	[(NSMutableArray *)_storyGroups addObject:storyGroup];
	DC_DEALLOC(_selectedStoryGroups);
}

-(NSArray *) selectedStoryGroups {
	if (_selectedStoryGroups == nil) {
		[self selectAll];
	}
	return _selectedStoryGroups;
}

-(void) selectWithPrefix:(NSString *) prefix {
	
	// Select matching sources.
	NSMutableIndexSet *selectedSourceIndexes = [[NSMutableIndexSet alloc] init];

	// Query each source.
	[_storyGroups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		SIStoryGroup *storyGroup = (SIStoryGroup *) obj;
		[storyGroup selectWithPrefix:prefix];
		if ([storyGroup.selectedStories count] > 0) {
			[selectedSourceIndexes addIndex:idx];
		}
	}];
	
	DC_DEALLOC(_selectedStoryGroups);
	_selectedStoryGroups = [[_storyGroups objectsAtIndexes:selectedSourceIndexes] retain];
	DC_DEALLOC(selectedSourceIndexes);
	DC_DEALLOC(_selectionCriteria);
	_selectionCriteria = [prefix retain];
}

-(void) selectAll {
	DC_DEALLOC(_selectedStoryGroups);
	[_storyGroups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[(SIStoryGroup *) obj selectAll];
	}];
	_selectedStoryGroups = [[NSArray arrayWithArray:_storyGroups] retain];
	_selectionCriteria = nil;
}

@end
