//
//  NSArray+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import "NSArray+Simon.h"
#import "SIStory.h"
#import "SIStorySource.h"
#import "NSString+Simon.h"

@implementation NSArray (Simon)

-(NSArray *) storiesFromSources {
	return [self valueForKeyPath:@"@unionOfArrays.stories"];
}

-(NSArray *) filter:(NSString *) filterText {
	
	DC_LOG(@"Filtering sources for search terms: %@", filterText);
	
	if ([NSString isEmpty:filterText]) {
		return nil;
	}
	
	NSMutableArray *filteredSources = [NSMutableArray array];

	for (SIStorySource *source in self) {
		
		// First test the file name in the source.
		NSString *fileName = [source.source lastPathComponent];
		SIStorySource *newSource = [source copy];
		
		// Accept the source and all it's stories if it passes based on the filter being a prefix.
		if ([fileName hasPrefix:filterText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]) {

			DC_LOG(@"Adding source: %@", fileName);
			[filteredSources addObject:newSource];
			
		} else {
			
			// Source file name is a no go so test each story name.
			NSArray *filteredStories = [source storiesWithPrefix:filterText];
			if ([filteredStories count] > 0) {
				newSource.stories = filteredStories;
				[filteredSources addObject:newSource];
			}
			
		}
		
		// Free
		[newSource release];
	}

	return filteredSources;
}

@end
