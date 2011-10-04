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
#import "SIInternal.h"


@interface SIAppBackpack()
-(void) start;
-(void) startUp:(NSNotification *) notification;
-(void) addApplicationReadyObserver;
-(void) removeApplicationReadyObserver;
@end

@implementation SIAppBackpack

- (id)init {
	self = [super init];
	if (self) {
		[self addApplicationReadyObserver];
	}
	return self;
}

-(id) initWithStoryFile:(NSString *) aFileName {
	self = [super init];
	if (self) {
		fileName = [aFileName retain];
		[self addApplicationReadyObserver];
	}
	return self;
}

-(void) addApplicationReadyObserver {
	// Hook into the app startup.
	DC_LOG(@"Applying program hooks to notification center: %@", [NSNotificationCenter defaultCenter]);
	[[NSNotificationCenter defaultCenter] addObserver:self 
														  selector:@selector(startUp:) 
																name:UIApplicationDidBecomeActiveNotification 
															 object:nil];
}

-(void) removeApplicationReadyObserver {
	DC_LOG(@"Removing program hooks to notification center: %@", [NSNotificationCenter defaultCenter]);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


// Background method
-(void) start {
	
	DC_LOG(@"Simon's background task starting");
	[NSThread currentThread].name = @"Simon";

	SIStoryRunner *runner = [[SIStoryRunner alloc] init];
	
	// Now tell it to use just the passed story file is present.
	if (fileName != nil) {
		SIStoryFileReader *reader = [[SIStoryFileReader alloc] initWithFileName:fileName];
		runner.reader = reader;
		[reader release];
	}
	
	NSError *error = nil;
	DC_LOG(@"Calling story runner");
	if (![runner runStories:&error]) {
		[DCDialogs displayMessage:[error localizedFailureReason] title:[error localizedDescription]]; 
	}
	
	[runner release];
	
	// Release program hooks and dealloc self.
	[self removeApplicationReadyObserver];
	[self release];
}

// Callbacks.
-(void) startUp:(NSNotification *) notification {
	DC_LOG(@"App is up so starting Simon's background queue");
	dispatch_queue_t queue = dispatch_queue_create(SIMONS_QUEUE, NULL);
	dispatch_async(queue, ^{
		[self start];
	});
}

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	DC_DEALLOC(fileName);
	[super dealloc];
}

@end
