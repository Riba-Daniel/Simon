//
//  SIActionFactory.m
//  Simon
//
//  Created by Derek Clarkson on 8/08/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import "SIUIActionFactory.h"
#import <dUsefulStuff/DCCommon.h>

@implementation SIUIActionFactory

// Static instance of the factory.
static SIUIActionFactory *factory;

+(void) setActionFactory:(SIUIActionFactory *) actionFactory {
	DC_DEALLOC(factory);
	factory = [actionFactory retain];
}

+(SIUIActionFactory *) actionFactory {
	if (factory == nil) {
		factory = [[SIUIActionFactory alloc] init];
	}
	return factory;
}

-(SIUIAction *) createActionForView:(UIView *) view {
	return [[[SIUIAction alloc] initWithView:view] autorelease];	
}

@end
