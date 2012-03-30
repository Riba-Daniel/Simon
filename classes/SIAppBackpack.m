//
//  SIAppBackpack.m
//  Simon
//
//  Created by Derek Clarkson on 7/13/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIAppBackpack.h"
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/DCDialogs.h>
#import "SIStoryRunner.h"
#import "SIConstants.h"
#import "SIUIViewHandlerFactory.h"


@interface SIAppBackpack()
-(void) start;
-(void) startUp:(NSNotification *) notification;
-(void) shutDown:(NSNotification *) notification;
-(void) addNotificationObservers;
@end

@implementation SIAppBackpack

// Static reference to self to keep alive in an ARC environment.
static SIAppBackpack *keepMeAlive;

// Static reference to the current story runner.
static SIStoryRunner *runner;

- (id)init {
	self = [super init];
	if (self) {
      keepMeAlive = [self retain];
		[self addNotificationObservers];
	}
	return self;
}

// Provides a class based access to the current story runner.
+(SIStoryRunner *) runner {
	return runner;
}

-(void) addNotificationObservers {
	// Hook into the app startup.
	DC_LOG(@"Applying program hooks to notification center: %@", [NSNotificationCenter defaultCenter]);
	[[NSNotificationCenter defaultCenter] addObserver:self 
														  selector:@selector(startUp:) 
																name:UIApplicationDidBecomeActiveNotification 
															 object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
														  selector:@selector(shutDown:) 
																name:SI_SHUTDOWN_NOTIFICATION  
															 object:nil];
}

// Background method
-(void) start {
	
	DC_LOG(@"Simon's background task starting");
	[NSThread currentThread].name = @"Simon";
	
	DC_DEALLOC(runner);
	runner = [[SIStoryRunner alloc] init];
	
	NSError *error = nil;
	DC_LOG(@"Calling story runner");
	if (![runner runStories:&error]) {
		// Do nothing as runner has code to deal with the error.
	}
   
}

// Callbacks.
-(void) startUp:(NSNotification *) notification {
	DC_LOG(@"App is up so starting Simon's background queue");
	dispatch_queue_t queue = dispatch_queue_create(SI_QUEUE_NAME, NULL);
	dispatch_async(queue, ^{
		[self start];
	});
   dispatch_release(queue);
   
}

-(void) shutDown:(NSNotification *) notification  {

	// Release program hooks and dealloc self.
	DC_LOG(@"ShutDown requested, deallocing the keep me alive self reference.");
   DC_DEALLOC(keepMeAlive);

	// Remove all notification watching.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	DC_DEALLOC(runner);
	[super dealloc];
}

@end
