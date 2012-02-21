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

// Static instance of the factory.
static SIUIViewHandlerFactory *factory;

+(void) setHandlerFactory:(SIUIViewHandlerFactory *) handlerFactory {
	DC_DEALLOC(factory);
	factory = [handlerFactory retain];
}

+(SIUIViewHandlerFactory *) handlerFactory {
	if (factory == nil) {
		factory = [[SIUIViewHandlerFactory alloc] init];
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

+(void) shutDown {
	DC_LOG(@"Shutting down handler factory");
	DC_DEALLOC(factory);
}

-(SIUIViewHandler *) handlerForView:(UIView<DNNode> *) view {
	
	// Get the handler from the cache if it exists, otherwise create one.
	Class viewClass = [view class];
	SIUIViewHandler *handler = [handlerCache objectForKey:viewClass];
	if (handler == nil) {
		handler = [self createHandlerForView:view];
		[handlerCache setObject:handler forKey:viewClass];
	}
	
	// Set the handler up and return it.
   [self initHandler:handler withView:view];
	return handler;
}

-(SIUIViewHandler *) createHandlerForView:(UIView<DNNode> *) view {
   return [[[SIUIViewHandler alloc] init] autorelease];
}

-(void) initHandler:(SIUIViewHandler *) handler withView:(UIView *) view {
	handler.view = view;
}


-(void) dealloc {
	DC_DEALLOC(handlerCache);
	[super dealloc];
}

@end
