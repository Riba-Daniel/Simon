//
//  SIActionFactory.m
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//

#import "SIUIViewHandlerFactory.h"
#import <dUsefulStuff/DCCommon.h>

@implementation SIUIViewHandlerFactory

-(id) init {
	self = [super init];
	if (self) {
		handlerCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(SIUIViewHandler *) handlerForView:(UIView<DNNode> *) view {
	
	// Get the handler from the cache if it exists, otherwise create one.
	Class viewClass = [view class];
	SIUIViewHandler *handler = [handlerCache objectForKey:viewClass];
	if (handler == nil) {
		handler = [self createHandlerForView:view];
		[handlerCache setObject:handler forKey:viewClass];
	}
	
	return handler;
}

-(SIUIViewHandler *) createHandlerForView:(UIView<DNNode> *) view {
   return [[[SIUIViewHandler alloc] init] autorelease];
}

-(void) dealloc {
	DC_DEALLOC(handlerCache);
	[super dealloc];
}

@end
