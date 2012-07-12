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
#import <Simon-core/SIConstants.h>
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
@property (retain, nonatomic) NSDictionary *displayUserInfo;
@end

@implementation SIAppBackpack

@synthesize autorun = autorun_;
@synthesize displayUserInfo = displayUserInfo_;

// Static reference to self to keep alive in an ARC environment.
static SIAppBackpack *backpack_;

#pragma mark - Accessors

+ (SIAppBackpack *)backpack {
   if (backpack_ == nil) {
      backpack_ = [[SIAppBackpack alloc] init];
   }
   return backpack_;
}

#pragma mark - Lifecycle

+(void) load {
	@autoreleasepool {
		
		// Find out if we are notloading.
		NSArray * arguments = [[NSProcessInfo processInfo] arguments];
		__block BOOL runSimon = YES;
		[arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([(NSString *) obj isEqualToString:@"--noload"]) {
				runSimon = NO;
			}
		}];
		
		// Now start Simon.
		if (runSimon) {
			[SIAppBackpack backpack];
		}

	}
}

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

#pragma mark - Backpack

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
		
		// Load stories and setup display info.
		[runner loadStories];
		
		// Find out if autorun is disabled.
		NSArray * arguments = [[NSProcessInfo processInfo] arguments];
		[arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			if ([(NSString *) obj isEqualToString:@"--noautorun"]) {
				self.autorun = NO;
			}
		}];
		
		// Now run or display.
		if(self.autorun) {
			[runner runStoriesInSources:runner.reader.storySources];
		} else {
			// Setup default settings.
			[self displayUI];
		}
	}];
}

-(void) runFinished:(NSNotification *) notification {
	[self displayUI];
}

-(void) runStories:(NSNotification *) notification {
	self.displayUserInfo = notification.userInfo;
	DC_LOG(@"Received userInfo: %@", self.displayUserInfo);
	[ui removeWindow];
}

-(void) windowRemoved:(NSNotification *) notification {
	DC_LOG(@"UI Removed");
	[self executeOnSimonThread: ^{
		[runner runStoriesInSources:[self.displayUserInfo objectForKey:SI_UI_STORIES_TO_RUN_LIST]];
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
	NSString *searchTerms = self.displayUserInfo == nil ? nil : [self.displayUserInfo objectForKey:SI_UI_SEARCH_TERMS];
	NSNumber *returnToDisplayView = self.displayUserInfo == nil ? [NSNumber numberWithBool:NO] :[self.displayUserInfo objectForKey:SI_UI_RETURN_TO_DETAILS];
	DC_LOG(@"Displaying UI with search terms: %@", searchTerms);
	NSDictionary *displayInfo = [NSDictionary dictionaryWithObjectsAndKeys:
										  runner.reader.storySources, SI_UI_ALL_STORIES_LIST,
										  [self.displayUserInfo objectForKey:SI_UI_STORIES_TO_RUN_LIST], SI_UI_STORIES_TO_RUN_LIST,
										  returnToDisplayView, SI_UI_RETURN_TO_DETAILS,
										  searchTerms, SI_UI_SEARCH_TERMS, nil]; 
	[ui displayUIWithUserInfo:displayInfo];
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
