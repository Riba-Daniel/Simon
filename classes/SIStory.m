//
//  Story.m
//  Simon
//
//  Created by Derek Clarkson on 5/30/11.
//  Copyright 2011. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>
#import <objc/runtime.h>
#import "SIStory.h"
#import "SIStep.h"
#import "NSString+Simon.h"
#import "SISimon.h"
#import "SIConstants.h"

@interface SIStory()
-(id) instanceForTargetClass:(Class) targetClass;
@end

@implementation SIStory

@synthesize status = status_;
@synthesize mappingWithError = mappingWithError_;
@synthesize steps = steps_;
@synthesize title = title_;
@synthesize error = error_;

-(void) dealloc {
	SI_LOG(@"Deallocing");
	DC_DEALLOC(error_);
	DC_DEALLOC(steps_);
	DC_DEALLOC(mappingWithError_);
	self.title = nil;
	DC_DEALLOC(instanceCache);
	DC_DEALLOC(storyCache);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		steps_ = [[NSMutableArray alloc] init];
		instanceCache = [[NSMutableDictionary alloc] init];
		storyCache = [[NSMutableDictionary alloc] init];
		status_ = SIStoryStatusNotRun;
	}
	return self;
}

-(SIStep *) createStepWithKeyword:(SIKeyword) keyword command:(NSString *) theCommand {
	SIStep * step = [[[SIStep alloc] initWithKeyword:keyword command:theCommand] autorelease];
	SI_LOG(@"Adding new step with keyword %i and command \"%@\"", keyword, theCommand);
	[self.steps addObject:step];
	return step;
}

-(SIStep *) stepAtIndex:(NSUInteger) index {
	return [self.steps objectAtIndex:index];
}

-(BOOL) invoke {
	
	// If the story is not fully mapped then exit because we cannot run it.
	for (SIStep *step in self.steps) {
		if (![step isMapped]) {
			SI_LOG(@"Story is not fully mapped. Cannot execute step %@", step.command);
			status_ = SIStoryStatusNotMapped;
			return NO;
		}
	}
	
	SI_LOG(@"Executing steps");
	for (SIStep *step in self.steps) {
		
		// First check the cache for an instance of the class. 
		// Create an instance of the class if we don't have one.
		id instance = [self instanceForTargetClass:step.stepMapping.targetClass];
		
		// Now invoke the step on the class.
      
		if (![step invokeWithObject:instance error:&error_]) {
			// Retain the error because it will be an autoreleased one.
			[error_ retain];
         mappingWithError_ = [step.stepMapping retain];
			status_ = SIStoryStatusError;
			return NO;
		}
	}
	
	status_ = SIStoryStatusSuccess;
	return YES;
}

-(id) instanceForTargetClass:(Class) targetClass {
	
	NSString *cacheKey = NSStringFromClass(targetClass);
	
	id instance = [instanceCache objectForKey:cacheKey];
	if (instance != nil) {
		return instance;
	}
	
	// Create one.
	SI_LOG(@"Creating instance of %@", NSStringFromClass(targetClass));
	instance = [[[targetClass alloc] init] autorelease];
	[instanceCache setObject:instance forKey:cacheKey];
	
	// Inject a reference to the story so it can be accessed for data. Note we assign so we don't have 
	// to worry about retains. This is fine as the story will be around longer than the test class.
	objc_setAssociatedObject(instance, SI_INSTANCE_STORY_REF_KEY, self, OBJC_ASSOCIATION_ASSIGN);
	
	return instance;
}

-(void) mapSteps:(NSArray *) mappings {
	for (SIStep *step in self.steps) {
		[step findMappingInList:mappings];
	}
}

-(void) storeObject:(id) object withKey:(id) key {
	[storyCache setObject:object forKey:key];
}

-(id) retrieveObjectWithKey:(id) key {
	return [storyCache objectForKey:key];
}

@end
