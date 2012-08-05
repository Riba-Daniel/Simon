//
//  NSArray+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Additional methods for arrays.
 */
@interface NSArray (Simon)

/// Returns a single array of all stories from the sources stored in this array. This assumes that the current array stores SIStorySource instances.
-(NSArray *) storiesFromSources;

-(NSArray *) filter:(NSString *) filter;

@end
