//
//  NSArray+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "NSArray+Simon.h"
#import "SIStory.h"
#import "SIStorySource.h"

@implementation NSArray (Simon)

-(NSArray *) storiesFromSources {
	return [self valueForKeyPath:@"@unionOfArrays.stories"];
}

-(NSArray *) filter:(NSString *) filterText {
	return nil;
	
	DC_LOG(@"Filtering sources for search terms: %@", filterText);
	NSMutableArray *filteredSources = [NSMutableArray array];
	/*
	for (SIStorySource *source in [SIAppBackpack backpack].storySources) {
		
		// First test the file name.
		NSString *fileName = [source.source lastPathComponent];
		// Check length first to avoid exceptions.
		if ([fileName hasPrefix:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]) {
			DC_LOG(@"Adding source: %@", [source.source lastPathComponent]);
			
		} else {
			
			// File name is a no go so test each story name.
			for (SIStory *story in source.stories) {
				
				// Check length first to avoid exceptions.
				if ([story.title hasPrefix:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)]) {
					
					DC_LOG(@"Adding story: %@", story.title);
					
					// Add a source if there is not one.
					if (tmpSource == nil) {
						tmpSource = [[SIStorySource alloc] init];
						tmpSource.source = source.source;
					}
					[tmpSource.stories addObject:story];
				}
			}
			
			// Now add the source if there are matching stories.
			if (tmpSource != nil) {
				[filteredSources addObject:tmpSource];
				DC_DEALLOC(tmpSource);
			}
		}
	}
	*/
	return filteredSources;
}


@end
