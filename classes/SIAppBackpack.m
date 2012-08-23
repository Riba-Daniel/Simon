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
#import <dUsefulStuff/NSObject+dUsefulStuff.h>

@interface SIAppBackpack (){
@private
	SIStoryLogger *logger;
}
+(int) argIndexForName:(NSString *) name;
@end

@implementation SIAppBackpack

@synthesize runner = _runner;
@synthesize mappings = _mappings;
@synthesize reader = _reader;

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
	[super dealloc];
}

#pragma mark - Accessors

+ (SIAppBackpack *)backpack {
   return _backpack;
}

-(NSArray *) mappings {
	return _mappings;
}

-(SIStorySources *) storySources {
	return self.reader.storySources;
}

#pragma mark - Lifecycle

+(void) load {
	@autoreleasepool {
		// Load Simon automatically.
		if (![SIAppBackpack isArgumentPresentWithName:ARG_NO_LOAD]) {
			if ([SIAppBackpack isArgumentPresentWithName:ARG_SHOW_UI]) {
				_backpack = [[SIUIAppBackpack alloc] init];
			} else {
				_backpack = [[SIHttpAppBackpack alloc] init];
			}
		}
	}
}

- (id)init {
	self = [super init];
	if (self) {
		
		// Instantiate required instances
		DC_LOG(@"Simon initialising");
		self.reader = [[[SIStoryFileReader alloc] init] autorelease];
		_runner = [[SIStoryRunner alloc] init];
		logger = [[SIStoryLogger alloc] init];
		
		// Because this is executing during +load just hook onto the app start notification.
		DC_LOG(@"Adding hook to application start");
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(startUp:)
																	name:UIApplicationDidBecomeActiveNotification
																 object:nil];
	}
	return self;
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
		
		// Everything is loaded and ready to go so post a notification to run.
		[[NSNotificationCenter defaultCenter] postNotificationName:SI_RUN_STORIES_NOTIFICATION object:self];
		
	}];
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

#pragma mark - Process arguments

+(BOOL) isArgumentPresentWithName:(NSString *) name {
	return [self argIndexForName:name] != NSNotFound;
}

+(NSString *) argumentValueForName:(NSString *) name {
	
	int index = [self argIndexForName:name];
	NSArray * arguments = [[NSProcessInfo processInfo] arguments];
	
	// return nil if not found or no more arguments.
	if (index == NSNotFound || index + 1 == [arguments count]) {
		return nil;
	}

	NSString *argValue = [arguments objectAtIndex:index + 1];
	
	// return nil if the value is actually a flag or argument name.
	if ([argValue characterAtIndex:0] == '-') {
		return nil;
	}
	
	return argValue;
}

+(int) argIndexForName:(NSString *) name {
	NSArray * arguments = [[NSProcessInfo processInfo] arguments];
	__block int argIndex = NSNotFound;
	NSString *fullArgName = [NSString stringWithFormat:@"--%@", name];
	
	// Get the index of the argument.
	[arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([(NSString *) obj isEqualToString:fullArgName]) {
			argIndex = idx;
			*stop = YES;
		}
	}];
	
	return argIndex;
	
}

@end
