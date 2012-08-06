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
#import "SIConstants.h"

@interface SIStory(_private)
-(id) instanceForTargetClass:(Class) targetClass;
-(BOOL) invokeSteps;
@end

@implementation SIStory

@synthesize status = _status;
@synthesize stepWithError = _stepWithError;
@synthesize steps = _steps;
@synthesize title = _title;
@synthesize error = _error;

-(void) dealloc {
	DC_LOG(@"Deallocing");
	self.steps = nil;
	self.title = nil;
	DC_DEALLOC(_error);
	DC_DEALLOC(_stepWithError);
	DC_DEALLOC(instanceCache);
	DC_DEALLOC(storyCache);
	[super dealloc];
}

-(id) init {
	self = [super init];
	if (self) {
		self.steps = [NSMutableArray array];
		[self reset];
	}
	return self;
}

-(SIStep *) createStepWithKeyword:(SIKeyword) keyword command:(NSString *) theCommand {
	
	if (![self.steps isKindOfClass:[NSMutableArray class]]) {
		self.steps = [NSMutableArray arrayWithArray:self.steps];
	}
	
	SIStep * step = [[[SIStep alloc] initWithKeyword:keyword command:theCommand] autorelease];
	DC_LOG(@"Adding new step with keyword %i and command \"%@\"", keyword, theCommand);
	[(NSMutableArray *)self.steps addObject:step];

	return step;
}

-(SIStep *) stepAtIndex:(NSUInteger) index {
	return [self.steps objectAtIndex:index];
}

-(BOOL) invoke {

	// Allocate the caches.
	instanceCache = [[NSMutableDictionary alloc] init];
	storyCache = [[NSMutableDictionary alloc] init];

	BOOL result = [self invokeSteps];

	// Clear the caches.
	DC_DEALLOC(instanceCache);
	DC_DEALLOC(storyCache);
	
	return result;
}

-(void) reset {

	// Reset any current result data.
	DC_LOG(@"Resetting");
	_status = SIStoryStatusNotRun;
	DC_DEALLOC(_stepWithError);
	DC_DEALLOC(_error);

	for (SIStep *step in self.steps) {
		[step reset];
	}
}

-(BOOL) invokeSteps {

	// If the story is not fully mapped then exit because we cannot run it.
	for (SIStep *step in self.steps) {
		if (![step isMapped]) {
			DC_LOG(@"Story is not fully mapped. Cannot execute step %@", step.command);
			_status = SIStoryStatusNotMapped;
			return NO;
		}
	}
	
	DC_LOG(@"Executing steps");
	for (SIStep *step in self.steps) {
		
		// First check the cache for an instance of the class. 
		// Create an instance of the class if we don't have one.
		id instance = [self instanceForTargetClass:step.stepMapping.targetClass];
		
		// Now invoke the step on the class.
      
		if (![step invokeWithObject:instance error:&_error]) {
			// Retain the error because it will be an autoreleased one.
			[_error retain];
         _stepWithError = [step retain];
			_status = SIStoryStatusError;
			return NO;
		}
	}
	
	_status = SIStoryStatusSuccess;
	return YES;
	
}

-(id) instanceForTargetClass:(Class) targetClass {
	
	NSString *cacheKey = NSStringFromClass(targetClass);
	
	id instance = [instanceCache objectForKey:cacheKey];
	if (instance != nil) {
		return instance;
	}
	
	// Create one.
	DC_LOG(@"Creating instance of %@", NSStringFromClass(targetClass));
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
