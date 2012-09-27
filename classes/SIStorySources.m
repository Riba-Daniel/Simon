//
//  SIStorySources.m
//  Simon
//
//  Created by Derek Clarkson on 11/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIStorySources.h>
#import <dUsefulStuff/DCCommon.h>


@interface SIStorySources() {
	@private
}

@end

@implementation SIStorySources

@synthesize sources = _sources;
@synthesize selectedSources = _selectedSources;
@synthesize selectionCriteria = _selectionCriteria;
@synthesize currentIndexPath = _currentIndexPath;

-(void) dealloc {
	self.currentIndexPath = nil;
	DC_DEALLOC(_sources);
	DC_DEALLOC(_selectedSources);
	DC_DEALLOC(_selectionCriteria);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		_sources = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) addSource:(SIStorySource *) source {
	[(NSMutableArray *)_sources addObject:source];
	DC_DEALLOC(_selectedSources);
}

-(NSArray *) selectedSources {
	if (_selectedSources == nil) {
		[self selectAll];
	}
	return _selectedSources;
}

-(void) selectWithPrefix:(NSString *) prefix {
	
	// Select matching sources.
	NSMutableIndexSet *selectedSourceIndexes = [[NSMutableIndexSet alloc] init];

	// Query each source.
	[_sources enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		SIStorySource *source = (SIStorySource *) obj;
		[source selectWithPrefix:prefix];
		if ([source.selectedStories count] > 0) {
			[selectedSourceIndexes addIndex:idx];
		}
	}];
	
	DC_DEALLOC(_selectedSources);
	_selectedSources = [[_sources objectsAtIndexes:selectedSourceIndexes] retain];
	DC_DEALLOC(selectedSourceIndexes);
	DC_DEALLOC(_selectionCriteria);
	_selectionCriteria = [prefix retain];
}

-(void) selectAll {
	DC_DEALLOC(_selectedSources);
	[_sources enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[(SIStorySource *) obj selectAll];
	}];
	_selectedSources = [[NSArray arrayWithArray:_sources] retain];
	_selectionCriteria = nil;
}

@end
