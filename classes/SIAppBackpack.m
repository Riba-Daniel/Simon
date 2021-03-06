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
#import <dUsefulStuff/NSObject+dUsefulStuff.h>

#import <Simon/SIConstants.h>

#import <Simon/SIAppBackpack.h>
#import <Simon/SIStoryRunner.h>
#import <Simon/SIUIAppBackpack.h>
#import <Simon/SIHttpAppBackpack.h>
#import <Simon/NSObject+Simon.h>
#import <Simon/NSProcessInfo+Simon.h>
#import <Simon/SIStoryTextFileSource.h>

// Simon's background thread name.
#define SI_QUEUE_NAME "au.com.derekclarkson.simon"

@interface SIAppBackpack () {
@private
	SIStoryLogger *logger;
	dispatch_queue_t _queue;
}
@end

@implementation SIAppBackpack

@synthesize runner = _runner;
@synthesize mappings = _mappings;
@synthesize storyAnalyser = _storyAnalyser;

@dynamic queue;
@dynamic storyGroupManager;

// Static reference to self to keep alive in an ARC environment.
static SIAppBackpack *_backpack;

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.storyAnalyser = nil;
	DC_DEALLOC(_runner);
	DC_DEALLOC(logger);
	DC_DEALLOC(_mappings);
	self.queue = nil;
	[super dealloc];
}

#pragma mark - Accessors

+ (SIAppBackpack *)backpack {
   return _backpack;
}

+ (void) setBackpack:(SIAppBackpack *) backpack {
	[backpack retain];
	[_backpack release];
	_backpack = backpack;
}

-(void) setQueue:(dispatch_queue_t)queue {
	if (queue != nil) {
		dispatch_retain(queue);
	}
	if (_queue != nil) {
		DC_LOG(@"Releasing the old queue");
		dispatch_release(_queue);
	}
	_queue = queue;
}

-(dispatch_queue_t) queue {
	return _queue;
}

-(SIStoryGroupManager *) storyGroupManager {
	return self.storyAnalyser.storyGroupManager;
}

#pragma mark - Lifecycle

+(void) load {
	@autoreleasepool {
		// Load Simon automatically.
		NSProcessInfo *info = [NSProcessInfo processInfo];
		if (![info isArgumentPresentWithName:ARG_NO_LOAD]) {
			SIAppBackpack *backpack;
			if ([info isArgumentPresentWithName:ARG_SHOW_UI]) {
				backpack = [[SIUIAppBackpack alloc] init];
			} else {
				backpack = [[SIHttpAppBackpack alloc] init];
			}
			[SIAppBackpack setBackpack:backpack];
			[backpack release];
		}
	}
}

- (id)init {
	self = [super init];
	if (self) {
		
		// Create Simons background queue.
		self.queue = dispatch_queue_create(SI_QUEUE_NAME, NULL);
		
		// Instantiate required instances
		DC_LOG(@"Simon initialising");
		id<SIStoryTextSource> storyTextSource = [[SIStoryTextFileSource alloc] init];
		self.storyAnalyser = [[[SIStoryAnalyser alloc] initWithStoryTextSource:storyTextSource] autorelease];
		[storyTextSource release];
		
		_runner = [[SIStoryRunner alloc] init];
		if ([[NSProcessInfo processInfo] isArgumentPresentWithName:ARG_REPORT]) {
			logger = [[SIStoryLogger alloc] init];
		}
		
		// Because this is executing during +load just hook onto the app start notification.
		DC_LOG(@"Adding hook to application start");
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(startUp:)
																	name:UIApplicationDidBecomeActiveNotification
																 object:nil];
	}
	return self;
}

-(void) exit {
	
	// Don't exit immediately, queue the request.
	dispatch_async(dispatch_get_main_queue(), ^{
		dispatch_async(dispatch_get_main_queue(), ^(void){
			DC_LOG(@"Exiting the application");
			// Flush all streams and exit.
			fflush(NULL);
			fclose(NULL);
			exit(0);
		});
	});
}

#pragma mark - Backpack

// Callbacks.
-(void) startUp:(NSNotification *) notification {
	
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
		
		// Read the stories.
		NSError *error = nil;
		BOOL started = [self.storyAnalyser startWithError:&error];
		
		if (!started) {
			DC_LOG(@"Error reading story files: %@", [error localizedFailureReason]);
			NSDictionary *userData = @{SI_NOTIFICATION_KEY_STATUS: @(error.code),
										SI_NOTIFICATION_KEY_MESSAGE: [error localizedFailureReason]};
			NSNotification *shutdown = [NSNotification notificationWithName:SI_SHUTDOWN_NOTIFICATION object:self userInfo:userData];
			[[NSNotificationCenter defaultCenter] postNotification:shutdown];
			return;
		}
		
		self.runner.storyGroupManager = self.storyGroupManager;
		
		// If no stories where read then generate an error and return.
		if ([self.storyGroupManager.storyGroups count] == 0) {
			DC_LOG(@"Error reading story files: No files found");
			NSDictionary *userData = @{SI_NOTIFICATION_KEY_STATUS: @(SIErrorNoStoriesFound),
										SI_NOTIFICATION_KEY_MESSAGE: @"No stories where read from the files."};
			NSNotification *runFinished = [NSNotification notificationWithName:SI_SHUTDOWN_NOTIFICATION object:self userInfo:userData];
			[[NSNotificationCenter defaultCenter] postNotification:runFinished];
			return;
		}
		
		// Read the runtime to locate all mappings.
		SIRuntime *runtime = [[SIRuntime alloc] init];
		_mappings = [[runtime allMappingMethodsInRuntime] retain];
		DC_DEALLOC(runtime);
		
		// Find the mapping for each story.
		DC_LOG(@"Mapping steps to story steps");
		[self.storyGroupManager.storyGroups enumerateObjectsUsingBlock:^(id sourceObj, NSUInteger sourceIdx, BOOL *sourceStop) {
			SIStoryGroup *storyGroup = (SIStoryGroup *) sourceObj;
			[storyGroup.stories enumerateObjectsUsingBlock:^(id storyObj, NSUInteger storyIdx, BOOL *storyStop) {
				SIStory *story = (SIStory *) storyObj;
				[story mapSteps:(NSArray *) self.mappings];
			}];
		}];
		
		// Call the override point.
		[self startUpFinished];
	}];
}

-(void) startUpFinished {
	// DO nothing here.
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

@end
