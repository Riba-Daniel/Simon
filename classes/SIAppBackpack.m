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
#import <Simon/SIConstants.h>

#import <Simon/SIAppBackpack.h>
#import <Simon/SIStoryRunner.h>
#import <Simon/SIUIAppBackpack.h>
#import <Simon/SIHttpAppBackpack.h>
#import <Simon/NSObject+Simon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>
#import <NSProcessInfo+Simon.h>

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
@synthesize reader = _reader;

@dynamic queue;
@dynamic storySources;

// Static reference to self to keep alive in an ARC environment.
static SIAppBackpack *_backpack;

-(void) dealloc {
	DC_LOG(@"Freeing memory and exiting");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.reader = nil;
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

-(SIStorySources *) storySources {
	return self.reader.storySources;
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
		self.reader = [[[SIStoryFileReader alloc] init] autorelease];
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
		
		NSError *error = nil;
		
		// Read the stories.
		DC_LOG(@"Reading stories");
		BOOL storiesRead = [self.reader readStorySources: &error];
		
		if (!storiesRead) {
			DC_LOG(@"Error reading story files: %@", [error localizedFailureReason]);
			NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code], SI_NOTIFICATION_KEY_STATUS,
											  [error localizedFailureReason], SI_NOTIFICATION_KEY_MESSAGE, nil];
			NSNotification *runFinished = [NSNotification notificationWithName:SI_SHUTDOWN_NOTIFICATION object:self userInfo:userData];
			[[NSNotificationCenter defaultCenter] postNotification:runFinished];
			return;
		}
		
		self.runner.storySources = self.storySources;
		
		// If no stories where read then generate an error and return.
		if ([self.storySources.sources count] == 0) {
			[self setError:&error
						 code:SIErrorNoStoriesFound
				errorDomain:SIMON_ERROR_DOMAIN
		 shortDescription:@"No stories read"
			 failureReason:@"No stories where read from the files."];
			DC_LOG(@"Error reading story files: %@", [error localizedFailureReason]);
			NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code], SI_NOTIFICATION_KEY_STATUS,
											  [error localizedFailureReason], SI_NOTIFICATION_KEY_MESSAGE, nil];
			NSNotification *runFinished = [NSNotification notificationWithName:SI_SHUTDOWN_NOTIFICATION object:self userInfo:userData];
			[[NSNotificationCenter defaultCenter] postNotification:runFinished];
			return;
		}
		
		// Read the runtime to locate all mappings.
		SIRuntime *runtime = [[SIRuntime alloc] init];
		_mappings = [[runtime allMappingMethodsInRuntime] retain];
		DC_DEALLOC(runtime);
		
		// Find the mapping for each story.
		DC_LOG(@"Mappin steps to story steps");
		[self.storySources.sources enumerateObjectsUsingBlock:^(id sourceObj, NSUInteger sourceIdx, BOOL *sourceStop) {
			SIStorySource *source = (SIStorySource *) sourceObj;
			[source.stories enumerateObjectsUsingBlock:^(id storyObj, NSUInteger storyIdx, BOOL *storyStop) {
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
