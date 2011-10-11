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
@property (nonatomic, retain) NSString *source;
@property (nonatomic, retain) NSMutableArray *stories;

@end
