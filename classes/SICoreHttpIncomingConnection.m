//
//  SIIncomingHTTPConnection.m
//  Simon
//
//  Created by Derek Clarkson on 13/07/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import <Simon/SICoreHttpIncomingConnection.h>
#import <Simon/SICoreHttpRequestProcessor.h>
#import <Simon/SIHttpRunAllRequestProcessor.h>
#import <Simon/SIHttpHeartbeatRequestProcessor.h>
#import <Simon/SIHttpExitRequestProcessor.h>
#import <Simon/NSString+Simon.h>
#import <Simon/SIAppBackpack.h>
#import "TargetConditionals.h"

@interface SICoreHttpIncomingConnection ()
@property (retain, nonatomic) NSArray *processors;
-(SICoreHttpRequestProcessor *) processorForMethod:(SIHttpMethod) method andPath:(NSString *) path;
@end

@implementation SICoreHttpIncomingConnection

@synthesize processors;

-(void) dealloc {
	self.processors = nil;
	[super dealloc];
}

-(id) initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig {
	self = [super initWithAsyncSocket:newSocket configuration:aConfig];
	if (self) {
		
		// Load appropriate request processors depending on whether we are in Simon or the Pieman.
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
		// Simon
		DC_LOG(@"Loading iOS request processors");
		SICoreHttpRequestProcessor * runAllProcessor = [[[SIHttpRunAllRequestProcessor alloc] init] autorelease];
		SICoreHttpRequestProcessor * heartbeatProcessor = [[[SIHttpHeartbeatRequestProcessor alloc] init] autorelease];
		SICoreHttpRequestProcessor * exitProcessor = [[[SIHttpExitRequestProcessor alloc] init] autorelease];
		self.processors = [NSArray arrayWithObjects:runAllProcessor, heartbeatProcessor, exitProcessor, nil];
#else
		// Pieman
		DC_LOG(@"Loading OS X request processors");
#endif
	}
	return self;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
	SIHttpMethod siMethod = [method siHttpMethod];
	return [self processorForMethod:siMethod andPath:path] != nil ? YES : [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {

	SIHttpMethod siMethod = [method siHttpMethod];
	SICoreHttpRequestProcessor *processor = [self processorForMethod:siMethod andPath:path];
	if (processor != nil) {
		return [processor expectingHttpBody];
	}
	
	// Otherwise default to the super.
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {

	SIHttpMethod siMethod = [method siHttpMethod];
	SICoreHttpRequestProcessor *processor = [self processorForMethod:siMethod andPath:path];
	
	if (processor != nil) {
		return [processor processPath:path withMethod:siMethod andBody:nil];
	}

	return [super httpResponseForMethod:method URI:path];
}

-(SICoreHttpRequestProcessor *) processorForMethod:(SIHttpMethod) method andPath:(NSString *) path {
	for (SICoreHttpRequestProcessor *processor in processors) {
		if ([processor canProcessPath:path withMethod:method]) {
			return processor;
		}
	}
	return nil;
}

@end
