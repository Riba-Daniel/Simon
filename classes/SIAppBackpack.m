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
-(void) displayUI;
-(void) addNotificationObservers;
-(void) startUp:(NSNotification *) notification;
-(void) shutDown:(NSNotification *) notification;
-(void) runFinished:(NSNotification *) notification;
-(void) runStories:(NSNotification *) notification;
-(void) windowRemoved:(NSNotification *) notification;
-(void) executeOnSimonThread:(void (^)()) block;
@end

@implementation SIAppBackpack

@synthesize autorun = autorun_;

// Static reference to self to keep alive in an ARC environment.
static SIAppBackpack *backpack_;

#pragma mark - Accessors

+ (SIAppBackpack *)backpack {
   if (backpack_ == nil) {
      backpack_ = [[SIAppBackpack alloc] init];
   }
   return backpack_;
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
		ui = [[SIUIReportManager alloc] init];
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
	[[NSNotificationCenter defaultCenter] addObserver:self 
														  selector:@selector(runStories:) 
																name:SI_RUN_STORIES_NOTIFICATION  
															 object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
														  selector:@selector(windowRemoved:) 
																name:SI_WINDOW_REMOVED_NOTIFICATION  
															 object:nil];
}

// Callbacks.
-(void) startUp:(NSNotification *) notification {
	[self executeOnSimonThread: ^{
		[runner loadStories];
		if(self.autorun) {
			[runner runStoriesInSources:runner.reader.storySources];
		} else {
			[self displayUI];
		}
	}];
}

-(void) runFinished:(NSNotification *) notification {
	[self displayUI];
}

-(void) runStories:(NSNotification *) notification {
	
	// Store the list of stories to be run.
	storiesToRun = [[notification.userInfo objectForKey:SI_STORIES_TO_RUN_LIST] retain];
	DC_LOG(@"Number of stories to be run: %i", [(NSArray *)[storiesToRun valueForKeyPath:@"@unionOfArrays.stories"] count]);
	[ui removeWindow];
}

-(void) windowRemoved:(NSNotification *) notification {
	DC_LOG(@"UI Removed");
	[self executeOnSimonThread: ^{
		[runner runStoriesInSources:storiesToRun];
		DC_DEALLOC(storiesToRun);
	}];
}


-(void) executeOnSimonThread:(void (^)()) block {
	dispatch_queue_t queue = dispatch_queue_create(SI_QUEUE_NAME, NULL);
	dispatch_async(queue, ^{
		DC_LOG(@"Simon's background task starting");
		[NSThread currentThread].name = @"Simon";
		block();
	});
   dispatch_release(queue);
	
}

-(void) displayUI {
	DC_LOG(@"Number of stories to display: %i", [(NSArray *)[runner.reader.storySources valueForKeyPath:@"@unionOfArrays.stories"] count]);
	[ui reportOnStorySources:runner.reader.storySources andMappings:runner.mappings];
}

-(void) shutDown:(NSNotification *) notification  {
	
	[ui removeWindow];

	// Release program hooks and dealloc self.
	DC_LOG(@"ShutDown requested, deallocing the keep me alive self reference.");
   DC_DEALLOC(backpack_);
	
	// Remove all notification watching.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
