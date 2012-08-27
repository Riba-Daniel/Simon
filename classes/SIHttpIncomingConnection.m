//
//  SIIncomingHTTPConnection.m
//  Simon
//
//  Created by Derek Clarkson on 13/07/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpIncomingConnection.h>
#import <Simon/SIHttpRequestProcessor.h>
#import <Simon/SIHttpRunAllRequestProcessor.h>
#import <Simon/SIHttpHeartbeatRequestProcessor.h>
#import <Simon/NSString+Simon.h>
#import <dUsefulStuff/DCCommon.h>
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
		id<SIHttpRequestProcessor> runAllProcessor = [[SIHttpRunAllRequestProcessor alloc] init];
		id<SIHttpRequestProcessor> heartbeatProcessor = [[SIHttpHeartbeatRequestProcessor alloc] init];
		self.processors = [NSArray arrayWithObjects:runAllProcessor, heartbeatProcessor, nil];
		[runAllProcessor release];
		[heartbeatProcessor release];
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
	
	if (processor == nil) {
		return [super httpResponseForMethod:method URI:path];
	}

	return [processor processPath:path withMethod:siMethod andBody:nil];

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
