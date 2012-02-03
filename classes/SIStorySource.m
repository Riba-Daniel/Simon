//
//  SIStorySource.m
//  Simon
//
//  Created by Derek Clarkson on 11/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStorySource.h"
#import <dUsefulStuff/DCCommon.h>

@implementation SIStorySource

@synthesize stories = stories_;
@synthesize source = source_;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.stories = nil;
	self.source = nil;
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		self.stories = [NSMutableArray array];
	}
	return self;
}

@end
