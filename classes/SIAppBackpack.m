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

#import <CocoaHTTPServer/HTTPServer.h>
#import <CocoaHTTPServer/DDLog.h>
#import <CocoaHTTPServer/DDTTYLogger.h>


#import "SIAppBackpack.h"
#import "SIStoryRunner.h"
#import "SIUIViewHandlerFactory.h"
#import "SIIncomingHTTPConnection.h"
#import "SIServerException.h"


@interface SIAppBackpack()

-(void) addNotificationObservers;

-(void) startUp:(NSNotification *) notification;
-(void) shutDown:(NSNotification *) notification;
-(void) runFinished:(NSNotification *) notification;
-(void) runStories:(NSNotification *) notification;
-(void) windowRemoved:(NSNotification *) notification;

-(void) executeOnSimonThread:(void (^)()) block;

@end


@implementation SIAppBackpack

@synthesize state = _state;
@dynamic storySources;
@dynamic mappings;

// Static reference to self to keep alive in an ARC environment.
static SIAppBackpack *_backpack;

#pragma mark - Accessors

+ (SIAppBackpack *)backpack {
   if (_backpack == nil) {
      //_backpack = [[SIAppBackpack alloc] init];
   }
   return _backpack;
}

-(NSArray *) storySources {
	return runner.reader.storySources;
}

-(NSArray *) mappings {
	return runner.mappings;
}

#pragma mark - Lifecycle

+(void) load {
	@autoreleasepool {
		// Load Simon automatically.
		if (![SIAppBackpack isArgumentPresentWithName:ARG_NO_LOAD]) {
			_backpack = [[SIAppBackpack alloc] init];
			//[SIAppBackpack backpack];
		}
	}
}

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	[server stop];
	DC_DEALLOC(server);
	DC_DEALLOC(runner);
	DC_DEALLOC(logger);
	DC_DEALLOC(ui);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		
		DC_LOG(@"Simon initing");
		
		// Instantiate required instances
		self.state = [[[SIState alloc] init] autorelease];
		runner = [[SIStoryRunner alloc] init];
		logger = [[SIStoryLogger alloc] init];

		// IF a UI is requested, load the report manager.
		if ([SIAppBackpack isArgumentPresentWithName:ARG_SHOW_UI]) {
			ui = [[SIUIReportManager alloc] init];
		}
		[self addNotificationObservers];
		
		// Start the HTTP server only if there is no UI.
		if (ui == nil) {
			DC_LOG(@"Starting HTTP server");
			[DDLog addLogger:[DDTTYLogger sharedInstance]];
			server = [[HTTPServer alloc] init];
			[server setConnectionClass:[SIIncomingHTTPConnection class]];
			[server setPort:5678];
			NSError *error = nil;
			if(![server start:&error])
			{
				@throw [SIServerException exceptionWithReason:[NSString stringWithFormat:@"Error starting HTTP Server: %@", error]];
			}
		}
		
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
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(windowRemoved:)
																name:SI_WINDOW_REMOVED_NOTIFICATION
															 object:nil];
}

// Callbacks.
-(void) startUp:(NSNotification *) notification {
	[self executeOnSimonThread: ^{
		
		DC_LOG(@"Starting Simon");
		
		// Load stories.
		[runner loadStories];
		
		// Now run or display if we are not running the server.
		if (ui != nil) {
			if([SIAppBackpack isArgumentPresentWithName:ARG_NO_AUTORUN]) {
				[ui displayUI];
			} else {
				[self runAllStories];
			}
		}
	}];
}

-(void) shutDown:(NSNotification *) notification  {
	
	DC_LOG(@"ShutDown requested.");
	
	[ui removeWindow];
	
	// Release program hooks and dealloc self.
	DC_LOG(@"Deallocing the keep me alive self reference.");
   DC_DEALLOC(_backpack);
	
	// Remove all notification watching.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) runFinished:(NSNotification *) notification {
	if (ui != nil) {
		[ui displayUI];
	}
}

- (void) runAllStories {
	[self executeOnSimonThread: ^{
		self.state.filteredSources = nil;
		[runner run];
	}];
}

#pragma mark - UI

-(void) runStories:(NSNotification *) notification {
	[ui removeWindow];
}

-(void) windowRemoved:(NSNotification *) notification {
	DC_LOG(@"UI Removed");
	[self executeOnSimonThread: ^{
		[runner run];
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
