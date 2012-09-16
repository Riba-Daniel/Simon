//
//  SIIncomingHTTPConnection.m
//  Simon
//
//  Created by Derek Clarkson on 13/07/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import <Simon/SIHttpIncomingConnection.h>
#import <Simon/NSString+Simon.h>
#import <Simon/SIAppBackpack.h>
#import <Simon/SIHttpGetRequestHandler.h>

@interface SIHttpIncomingConnection () {
	NSMutableData *bodyContent;
}

-(SIHttpGetRequestHandler *) processorForMethod:(SIHttpMethod) method andPath:(NSString *) path;
@end

@implementation SIHttpIncomingConnection

static NSArray *_processors;

+(void) setProcessors:(NSArray *) processorArray {
	[processorArray retain];
	[_processors release];
	_processors = processorArray;
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
	SIHttpMethod siMethod = [method siHttpMethod];
	BOOL supported = [self processorForMethod:siMethod andPath:path] != nil ? YES : [super supportsMethod:method atPath:path];
	DC_LOG(@"Do we support %@ %@ => %@", method, path, DC_PRETTY_BOOL(supported));
	return supported;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {

	SIHttpMethod siMethod = [method siHttpMethod];
	SIHttpGetRequestHandler *processor = [self processorForMethod:siMethod andPath:path];
	BOOL expectingBody = NO;
	if (processor != nil) {
		expectingBody = [processor expectingHttpBody];
	} else {
		expectingBody = [super expectsRequestBodyFromMethod:method atPath:path];
	}
	
	DC_LOG(@"Expecting body for %@ %@ => %@", method, path, DC_PRETTY_BOOL(expectingBody));
	return expectingBody;

}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {

	SIHttpMethod siMethod = [method siHttpMethod];
	SIHttpGetRequestHandler *processor = [self processorForMethod:siMethod andPath:path];
	
	NSObject<HTTPResponse> *response;
	if (processor != nil) {
		 response = [processor processPath:path andBody:bodyContent];
	} else {
		response = [super httpResponseForMethod:method URI:path];
	}

	DC_LOG(@"Response for %@ => %@", path, response);
	
	// Clear the body data.
	DC_DEALLOC(bodyContent);
	
	// Return
	return response;
}

- (void)prepareForBodyWithSize:(UInt64)contentLength {
	bodyContent = [[NSMutableData alloc] initWithCapacity:contentLength];
}

- (void)processBodyData:(NSData *)postDataChunk {
	[bodyContent appendData:postDataChunk];
}

-(SIHttpGetRequestHandler *) processorForMethod:(SIHttpMethod) method andPath:(NSString *) path {
	for (SIHttpGetRequestHandler *processor in _processors) {
		if ([processor canProcessPath:path withMethod:method]) {
			return processor;
		}
	}
	return nil;
}

@end
