//
//  CommsASteps.m
//  Simon
//
//  Created by Derek Clarkson on 7/1/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon/Simon.h>
#import <GHUnitIOS/GHUnit.h>
#import <objc/runtime.h>


@interface CommsBSteps : GHTestCase

@end

@implementation CommsBSteps

mapStepToSelector(@"then this class should be able to retrieve (.*) from storage with key (.*)", retrieveString:withKey:)
-(void) retrieveString:(NSString *) aString withKey:(NSString *) key{
	NSString *value = retrieveFromStory(key);
	GHAssertEqualStrings(value, aString, @"Strings do not match");
}

@end
