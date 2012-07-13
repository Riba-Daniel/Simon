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
#import <Simon-core/SIConstants.h>

#import <SimonHttpServer/HTTPServer.h>
#import <SimonHttpServer/DDLog.h>
#import <SimonHttpServer/DDTTYLogger.h>

#import "SIAppBackpack.h"
#import "SIStoryRunner.h"
#import "SIUIViewHandlerFactory.h"
#import "SIIncomingHTTPConnection.h"
#import "SIServerException.h"


@interface SIAppBackpack()
-(void) displayUI;
-(void) addNotificationObservers;
-(void) startUp:(NSNotification *) notification;
-(void) shutDown:(NSNotification *) notification;
-(void) runFinished:(NSNotification *) notification;
-(void) runStories:(NSNotification *) notification;
-(void) windowRemoved:(NSNotification *) notification;
-(void) executeOnSimonThread:(void (^)()) block;
+(BOOL) isArgumentPresentWithName:(NSString *) name;
@property (retain, nonatomic) NSDictionary *displayUserInfo;
@end

@implementation SIAppBackpack

@synthesize displayUserInfo = _displayUserInfo;

// Static reference to self to keep alive in an ARC environment.
static SIAppBackpack *_backpack;

#pragma mark - Accessors

+ (SIAppBackpack *)backpack {
   if (_backpack == nil) {
      _backpack = [[SIAppBackpack alloc] init];
   }
   return _backpack;
}

#pragma mark - Lifecycle

+(void) load {
	@autoreleasepool {
		[SIAppBackpack backpack];
	}
}

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	[server stop];
	DC_DEALLOC(server);
	DC_DEALLOC(runner);
	DC_DEALLOC(ui);
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		runner = [[SIStoryRunner alloc] init];
		if ([SIAppBackpack isArgumentPresentWithName:ARG_SHOW_UI]) {
			ui = [[SIUIReportManager alloc] init];
		}
		[self addNotificationObservers];
		
		// Start the HTTP server.
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
		
		// Now run or display if we are not running the server.
		if (ui != nil) {
			if([SIAppBackpack isArgumentPresentWithName:ARG_NO_AUTORUN]) {
				[self displayUI];
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
		[self displayUI];
	}
}

- (void) runAllStories {
	[self executeOnSimonThread: ^{
		[runner runStoriesInSources:runner.reader.storySources];
	}];
}

#pragma mark - UI

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


@end
