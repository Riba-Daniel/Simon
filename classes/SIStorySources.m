//
//  SIStorySources.m
//  Simon
//
//  Created by Derek Clarkson on 11/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
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
	
	NSMutableIndexSet *selectedIndexes = [[NSMutableIndexSet alloc] init];
	[_sources enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		SIStorySource *source = (SIStorySource *) obj;
		[source selectWithPrefix:prefix];
		if ([source.selectedStories count] > 0) {
			[selectedIndexes addIndex:idx];
		}
	}];
	
	DC_DEALLOC(_selectedSources);
	_selectedSources = [[_sources objectsAtIndexes:selectedIndexes] retain];
	DC_DEALLOC(selectedIndexes);
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
