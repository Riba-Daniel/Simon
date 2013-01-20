//
//  SIUIUtils.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>

#import <Simon/SIUIApplication.h>
#import <Simon/UIView+Simon.h>
#import <Simon/SIUIViewDescriptionVisitor.h>
#import <Simon/NSObject+Simon.h>
#import <Simon/SIAppBackpack.h>
#import <Simon/NSProcessInfo+Simon.h>

#import <PublicAutomation/UIAutomationBridge.h>

#import <QuartzCore/CALayer.h>

@implementation SIUIApplication

static SIUIApplication *application = nil;

@synthesize viewHandlerFactory = _viewHandlerFactory;
@synthesize disableKeyboardAutocorrect = _disableAutoCorrect;
@synthesize logActions = _logActions;
@synthesize retryFrequency = _retryFrequency;
@synthesize timeout = _timeout;

#pragma mark - Accessors

+ (SIUIApplication *)application {
   if (application == nil) {
      application = [[super allocWithZone:NULL] init];
   }
   return application;
}

#pragma mark - Singleton overrides

- (id)init
{
   self = [super init];
   if (self) {
		SIUIViewHandlerFactory *factory = [[SIUIViewHandlerFactory alloc] init];
      self.viewHandlerFactory = factory;
		self.logActions = [[NSProcessInfo processInfo] isArgumentPresentWithName:ARG_LOG_ACTIONS];
		self.retryFrequency = DEFAULT_RETRY_FREQUENCY;
		self.timeout = DEFAULT_TIMEOUT;
		[factory release];
   }
   return self;
}

-(void)dealloc
{
   self.viewHandlerFactory = nil;
   [super dealloc];
}

+ (id)allocWithZone:(NSZone*)zone {
   return [[SIUIApplication application] retain];
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

#pragma mark - Searching


-(void) logUITree {
	
	[self executeBlockOnMainThread:^{
		
		NSLog(@"Tree view of current window");
		NSLog(@"====================================================");
		
		SIUIViewDescriptionVisitor *visitor = [[SIUIViewDescriptionVisitor alloc] initWithDelegate:self];
		[visitor visitAllWindows];
		//[visitor visitView:[UIApplication sharedApplication].keyWindow];
		DC_DEALLOC(visitor);
	}];
	
}

-(void) visitView:(UIView *) view
		description:(NSString *) description
		 attributes:(NSDictionary *) attributes
		  indexPath:(NSIndexPath *) indexPath
			 sibling:(int) siblingIndex {
	
	// Build a string of the attributes.
	NSMutableString *attributeString = [NSMutableString string];
	[attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[attributeString appendFormat:@", @%@='%@'", key, obj];
	}];
	
	// Log the main details.
	NSString *name = NSStringFromClass([view class]);
	NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];
	NSUInteger depth = [indexPath length];
	NSString *prefix = [@"" stringByPaddingToLength:depth * 3 withString:@"   " startingAtIndex:0];
	NSString *siblingString = siblingIndex > 0 ? [NSString stringWithFormat:@" [%i]", siblingIndex]: @"";
	NSLog(@"%1$@[%3$i] %2$@%4$@%5$@", prefix, name, index, siblingString, attributeString);
	
}

#pragma mark - View handlers

-(SIUIViewHandler *) viewHandlerForView:(UIView *) view {
   SIUIViewHandler *handler = [self.viewHandlerFactory handlerForView:view];
   handler.view = view;
   return handler;
}

#pragma mark - Pauses and holds


@end
