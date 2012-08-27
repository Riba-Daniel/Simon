//
//  SIIncomingHTTPConnection.m
//  Simon
//
//  Created by Derek Clarkson on 13/07/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import <Simon/SIHttpIncomingConnection.h>
#import <Simon/SIHttpRequestProcessor.h>
#import <Simon/SIHttpRunAllRequestProcessor.h>
#import <Simon/SIHttpHeartbeatRequestProcessor.h>
#import <Simon/SIHttpExitRequestProcessor.h>
#import <Simon/NSString+Simon.h>
#import <Simon/SIAppBackpack.h>

@interface SIHttpIncomingConnection ()
@property (retain, nonatomic) NSArray *processors;
-(id<SIHttpRequestProcessor>) processorForMethod:(SIHttpMethod) method andPath:(NSString *) path;
@end

@implementation SIHttpIncomingConnection

@synthesize processors;

-(void) dealloc {
	self.processors = nil;
	[super dealloc];
}

-(id) initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig {
	self = [super initWithAsyncSocket:newSocket configuration:aConfig];
	if (self) {
		id<SIHttpRequestProcessor> runAllProcessor = [[[SIHttpRunAllRequestProcessor alloc] init] autorelease];
		id<SIHttpRequestProcessor> heartbeatProcessor = [[[SIHttpHeartbeatRequestProcessor alloc] init] autorelease];
		id<SIHttpRequestProcessor> exitProcessor = [[[SIHttpExitRequestProcessor alloc] init] autorelease];
		self.processors = [NSArray arrayWithObjects:runAllProcessor, heartbeatProcessor, exitProcessor, nil];
	}
	return self;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
	SIHttpMethod siMethod = [method siHttpMethod];
	return [self processorForMethod:siMethod andPath:path] != nil ? YES : [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {

	SIHttpMethod siMethod = [method siHttpMethod];
	id<SIHttpRequestProcessor> processor = [self processorForMethod:siMethod andPath:path];
	if (processor != nil) {
		return [processor expectingHttpBody];
	}
	
	// Otherwise default to the super.
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {

	SIHttpMethod siMethod = [method siHttpMethod];
	id<SIHttpRequestProcessor> processor = [self processorForMethod:siMethod andPath:path];
	
	if (processor != nil) {
		return [processor processPath:path withMethod:siMethod andBody:nil];
	}

	return [super httpResponseForMethod:method URI:path];
}

-(id<SIHttpRequestProcessor>) processorForMethod:(SIHttpMethod) method andPath:(NSString *) path {
	for (id<SIHttpRequestProcessor> processor in processors) {
		if ([processor canProcessPath:path withMethod:method]) {
			return processor;
		}
	}
	return nil;
}

@end
