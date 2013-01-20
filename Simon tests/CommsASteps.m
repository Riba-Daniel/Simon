//
//  CommsASteps.m
//  Simon
//
//  Created by Derek Clarkson on 7/1/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon/Simon.h>
#import <objc/runtime.h>


@interface CommsASteps : NSObject

@end

@implementation CommsASteps

mapStepToSelector(@"Given this class stores (.*) in the story storage using key (.*)", storesString:withKey:)
-(void) storesString:(NSString *) aString withKey:(NSString *) key{
	storeInStory(key, aString);
}

@end
