//
//  TEstUtils.m
//  Simon
//
//  Created by Derek Clarkson on 6/10/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "TestUtils.h"


static Method originalMethod;
static IMP originalImp;

@implementation TestUtils

+(void) swizzleNSURLConnectionSendSyncWithImp:(IMP) impl {
	
	if (originalMethod == nil) {
#pragma GCC diagnostic ignored "-Wselector"
		originalMethod = class_getClassMethod([NSURLConnection class], @selector(sendSynchronousRequest:returningResponse:error:));
#pragma GCC diagnostic warning "-Wselector"
		originalImp = method_getImplementation(originalMethod);
	}
	
	// Swizzle
	method_setImplementation(originalMethod, impl);
	
}

+(void) restoreNSURLConnectionSendSync {
	if (originalMethod != nil) {
		method_setImplementation(originalMethod, originalImp);
	}
}

@end
