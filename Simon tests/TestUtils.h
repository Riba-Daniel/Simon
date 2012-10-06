//
//  TEstUtils.h
//  Simon
//
//  Created by Derek Clarkson on 6/10/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <objc/runtime.h>

/**
 Utilitiy methods for helping with tests.
 */
 
@interface TestUtils : NSObject

+(void) swizzleNSURLConnectionSendSyncWithImp:(IMP) impl;

+(void) restoreNSURLConnectionSendSync;


@end
