//
//  NSInvocations.m
//  Simon
//
//  Created by Derek Clarkson on 20/01/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <objc/runtime.h>
#import <dUsefulStuff/DCCommon.h>

@interface NSInvocations : GHTestCase
-(void) throwAnException;
@end

@implementation NSInvocations

-(void) testInvocationHandlesException {

   Method method = class_getInstanceMethod([self class], @selector(throwAnException));
   NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
   NSInvocation *inv = [NSInvocation invocationWithMethodSignature:signature];
   inv.target = self;
   inv.selector = @selector(throwAnException);

   @try {
      [inv invoke];
      GHFail(@"Exception not caught");
   }
   @catch (NSException *exception) {
      DC_LOG(@"Exception: %@", exception);
      // Woot!
   }
   
}

-(void) throwAnException {
   @throw [NSException exceptionWithName:@"Crash" reason:@"Really crash" userInfo:nil];
}

@end
