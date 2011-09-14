//
//  SIActionFactory.m
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//

#import "SIUIHandlerFactory.h"
#import <dUsefulStuff/DCCommon.h>

@implementation SIUIHandlerFactory

// Static instance of the factory.
static SIUIHandlerFactory *factory;

+(void) setHandlerFactory:(SIUIHandlerFactory *) handlerFactory {
	DC_DEALLOC(factory);
	factory = [handlerFactory retain];
}

+(SIUIHandlerFactory *) handlerFactory {
	if (factory == nil) {
		factory = [[SIUIHandlerFactory alloc] init];
	}
	return factory;
}

-(id) init {
	self = [super init];
	if (self) {
		handlerCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(SIUIViewHandler *) createHandlerForView:(UIView<DNNode> *) view {
	
	// Get the handler from the cache if it exists, otherwise create one.
	Class viewClass = [view class];
	SIUIViewHandler *handler = [handlerCache objectForKey:viewClass];
	if (handler == nil) {
		handler = [[SIUIViewHandler alloc] init];
		[handlerCache setObject:handler forKey:viewClass];
		[handler release];
	}
	
	// Set the handler up and return it.
	handler.view = view;
	return handler;
}

-(void) dealloc {
	DC_DEALLOC(handlerCache);
	[super dealloc];
}

@end
