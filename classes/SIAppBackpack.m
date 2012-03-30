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

@synthesize autorun = autorun_;

// Static reference to self to keep alive in an ARC environment.
static SIAppBackpack *backpack_;

#pragma mark - Accessors

+ (SIAppBackpack *)backpack {
   if (backpack_ == nil) {
      backpack_ = [[super allocWithZone:NULL] init];
   }
   return backpack_;
}

#pragma mark - Singleton overrides

+ (id)allocWithZone:(NSZone*)zone {
   return [[self backpack] retain];
}

- (id)copyWithZone:(NSZone *)zone {
   return self;
}

- (id)retain {
   return self;
}

- (NSUInteger)retainCount {
   return NSUIntegerMax;
}

- (oneway void)release {
}

- (id)autorelease {
   return self;
}

#pragma mark - Instance methods

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	DC_DEALLOC(runner);
	DC_DEALLOC(ui);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		runner = [[SIStoryRunner alloc] init];
		ui = [[SIStoryInAppReporter alloc] init];
		self.autorun = YES;
		[self addNotificationObservers];
	}
	return self;
}

-(void) addNotificationObservers {
	// Hook into the app startup.
	DC_LOG(@"Applying program hooks to notification center: %@", [NSNotificationCenter defaultCenter]);
	[[NSNotificationCenter defaultCenter] addObserver:self 
														  selector:@selector(startUp:) 
																name:UIApplicationDidBecomeActiveNotification 
															 object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
														  selector:@selector(displayUI) 
																name:SI_RUN_FINISHED_NOTIFICATION  
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
	[runner loadStories];
	if(self.autorun) {
		[runner runStories];
	} else {
		[self displayUI];
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

-(void) displayUI {
	[ui reportOnStorySources:runner.storySources andMappings:runner.mappings];
}

-(void) shutDown:(NSNotification *) notification  {
	
	// Release program hooks and dealloc self.
	DC_LOG(@"ShutDown requested, deallocing the keep me alive self reference.");
   DC_DEALLOC(backpack_);
	
	// Remove all notification watching.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
