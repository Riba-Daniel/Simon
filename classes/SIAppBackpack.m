//
//  SIAppBackpack.m
//  Simon
//
//  Created by Derek Clarkson on 7/13/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/DCDialogs.h>
#import "SIConstants.h"

#import "SIAppBackpack.h"
#import "SIStoryRunner.h"
#import "SIUIAppBackpack.h"
#import "SIHttpAppBackpack.h"

@implementation SIAppBackpack

@synthesize state = _state;
@synthesize runner = _runner;
@dynamic storySources;
@dynamic mappings;

// Static reference to self to keep alive in an ARC environment.
static SIAppBackpack *_backpack;

#pragma mark - Accessors

+ (SIAppBackpack *)backpack {
   return _backpack;
}

-(NSArray *) storySources {
	return self.runner.reader.storySources;
}

-(NSArray *) mappings {
	return self.runner.mappings;
}

#pragma mark - Lifecycle

+(void) load {
	@autoreleasepool {
		// Load Simon automatically.
		if (![SIAppBackpack isArgumentPresentWithName:ARG_NO_LOAD]) {
			if ([SIAppBackpack isArgumentPresentWithName:ARG_SHOW_UI]) {
				_backpack = [[SIUIAppBackpack alloc] init];
			} else {
				_backpack = [[SIHttpAppBackpack alloc] init];
			}
		}
	}
}

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	DC_DEALLOC(_runner);
	DC_DEALLOC(_state);
	DC_DEALLOC(logger);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {

		// Because this is executing during +load just hook onto the app start notification.
		DC_LOG(@"Adding hook to application start");
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(startUp:)
																	name:UIApplicationDidBecomeActiveNotification
																 object:nil];
	}
	return self;
}

#pragma mark - Backpack

// Callbacks.
-(void) startUp:(NSNotification *) notification {

	// Instantiate required instances
	DC_LOG(@"Simon initialising");
	
	_state = [[SIState alloc] init];
	_runner = [[SIStoryRunner alloc] init];
	logger = [[SIStoryLogger alloc] init];
	
	DC_LOG(@"Applying program hooks to notification center: %@", [NSNotificationCenter defaultCenter]);
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(runFinished:)
																name:SI_RUN_FINISHED_NOTIFICATION
															 object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(shutDown:)
																name:SI_SHUTDOWN_NOTIFICATION
															 object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(runStories:)
																name:SI_RUN_STORIES_NOTIFICATION
															 object:nil];
	
	[self executeOnSimonThread: ^{

		DC_LOG(@"Starting Simon");
		
		NSError *error = nil;
		if ([self.runner loadStories:&error]) {
			// Tell the state to generate a set of run indexes to indicate all stories should be run.
			[[NSNotificationCenter defaultCenter] postNotificationName:SI_RUN_STORIES_NOTIFICATION object:self];
		} else {
			NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code], SI_NOTIFICATION_KEY_STATUS,
											  [error localizedFailureReason], SI_NOTIFICATION_KEY_MESSAGE, nil];
			NSNotification *runFinished = [NSNotification notificationWithName:SI_SHUTDOWN_NOTIFICATION object:self userInfo:userData];
			[[NSNotificationCenter defaultCenter] postNotification:runFinished];
		}
		
	}];
}

-(void) shutDown:(NSNotification *) notification  {
	DC_LOG(@"ShutDown requested.");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
   DC_DEALLOC(_backpack);
}

-(void) runFinished:(NSNotification *) notification {}

-(void) runStories:(NSNotification *) notification {
	[self executeOnSimonThread: ^{
		[self.runner run];
	}];
}

#pragma mark - Thread handling

-(void) executeOnSimonThread:(void (^)()) block {
	dispatch_queue_t queue = dispatch_queue_create(SI_QUEUE_NAME, NULL);
	dispatch_async(queue, ^{
		DC_LOG(@"Executing block on Simon's background thread");
		[NSThread currentThread].name = @"Simon";
		block();
	});
   dispatch_release(queue);
	
}

#pragma mark - Utils

+(BOOL) isArgumentPresentWithName:(NSString *) name {
	NSArray * arguments = [[NSProcessInfo processInfo] arguments];
	__block BOOL response = NO;
	[arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([(NSString *) obj isEqualToString:name]) {
			response = YES;
			*stop = YES;
		}
	}];
	return response;
}

+(NSString *) argumentValueForName:(NSString *) name {
	return nil;
}

@end
