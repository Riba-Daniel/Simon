//
//  SIActionFactory.m
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011. All rights reserved.
//

#import "SIUIViewHandlerFactory.h"
#import <dUsefulStuff/DCCommon.h>
#import "SIUIButtonHandler.h"
#import "SIUILabelHandler.h"

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
		//DC_LOG(@"Creating view handler for class %@", NSStringFromClass(viewClass));
		[handlerCache setObject:handler forKey:viewClass];
	}
	
   handler.view = view;
	return handler;
}

-(SIUIViewHandler *) createHandlerForView:(UIView<DNNode> *) view {
	if ([view isKindOfClass:[UIButton class]]) {
		//DC_LOG(@"Creating new Button handler");
		return [[[SIUIButtonHandler alloc] init] autorelease];
	}
	if ([view isKindOfClass:[UILabel class]]) {
		//DC_LOG(@"Creating new label handler");
		return [[[SIUILabelHandler alloc] init] autorelease];
	}
	//DC_LOG(@"Creating new view handler");
   return [[[SIUIViewHandler alloc] init] autorelease];
}

-(void) dealloc {
	DC_DEALLOC(handlerCache);
	[super dealloc];
}

@end
