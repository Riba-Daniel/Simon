//
//  SIStorySource.h
//  Simon
//
//  Created by Derek Clarkson on 11/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Represents a source of stories. Mainly used for reporting purposes.
 */
@interface SIStorySource : NSObject

/**
 The source file which the story was read from.
 */
@property (nonatomic, retain) NSString *source;

/**
 A list of the stories read from the file. These are SIStory implementations.
 */
@property (nonatomic, retain) NSMutableArray *stories;

@end
