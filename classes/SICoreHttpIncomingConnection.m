//
//  SIIncomingHTTPConnection.m
//  Simon
//
//  Created by Derek Clarkson on 13/07/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import <Simon/SICoreHttpIncomingConnection.h>
#import <Simon/NSString+Simon.h>
#import <Simon/SIAppBackpack.h>
#import <Simon/SICoreHttpRequestProcessor.h>
#import "TargetConditionals.h"

@interface SICoreHttpIncomingConnection ()
-(SICoreHttpRequestProcessor *) processorForMethod:(SIHttpMethod) method andPath:(NSString *) path;
@end

@implementation SICoreHttpIncomingConnection

static NSArray *_processors;

-(void) dealloc {
	DC_DEALLOC(_processors);
	[super dealloc];
}

+(void) setProcessors:(NSArray *) processorArray {
	_processors = [processorArray retain];
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
	for (SICoreHttpRequestProcessor *processor in _processors) {
		if ([processor canProcessPath:path withMethod:method]) {
			return processor;
		}
	}
	return nil;
}

@end
