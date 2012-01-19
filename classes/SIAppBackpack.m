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
#import "SIUIHandlerFactory.h"


@interface SIAppBackpack()
-(void) start;
-(void) startUp:(NSNotification *) notification;
-(void) shutDown:(NSNotification *) notification;
-(void) addNotificationObservers;
@end

@implementation SIAppBackpack

// Static reference to the current story runner.
static SIStoryRunner *runner;

- (id)init {
	self = [super init];
	if (self) {
		[self addNotificationObservers];
	}
	return self;
}

// Provides a class based access to the current story runner.
+(SIStoryRunner *) runner {
	return runner;
}

-(id) initWithStoryFile:(NSString *) aFileName {
	self = [super init];
	if (self) {
		fileName = [aFileName retain];
		[self addNotificationObservers];
	}
	return self;
}

-(void) addNotificationObservers {
	// Hook into the app startup.
	SI_LOG(@"Applying program hooks to notification center: %@", [NSNotificationCenter defaultCenter]);
	[[NSNotificationCenter defaultCenter] addObserver:self 
														  selector:@selector(startUp:) 
																name:UIApplicationDidBecomeActiveNotification 
															 object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
														  selector:@selector(shutDown:) 
																name:@"Simon shutdown" 
															 object:nil];
}

// Background method
-(void) start {
	
	SI_LOG(@"Simon's background task starting");
	[NSThread currentThread].name = @"Simon";
	
	DC_DEALLOC(runner);
	runner = [[SIStoryRunner alloc] init];
	
	// Now tell it to use just the passed story file is present.
	if (fileName != nil) {
		SIStoryFileReader *reader = [[SIStoryFileReader alloc] initWithFileName:fileName];
		runner.reader = reader;
		[reader release];
	}
	
	NSError *error = nil;
	SI_LOG(@"Calling story runner");
	if (![runner runStories:&error]) {
		// Do mothing as runner has code to deal with the error.
	}
	
}

// Callbacks.
-(void) startUp:(NSNotification *) notification {
	SI_LOG(@"App is up so starting Simon's background queue");
	dispatch_queue_t queue = dispatch_queue_create(SI_QUEUE_NAME, NULL);
	dispatch_async(queue, ^{
		[self start];
	});
}

-(void) shutDown:(NSNotification *) notification  {
	// Release program hooks and dealloc self.
	SI_LOG(@"ShutDown requested");
	
	// Shut down the handler factory for UI components.
	[SIUIHandlerFactory shutDown];
	
	// Remove all notification watching.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self release];
}

-(void) dealloc {
	SI_LOG(@"Freeing memory and exiting");
	DC_DEALLOC(fileName);
	DC_DEALLOC(runner);
	[super dealloc];
}

@end
