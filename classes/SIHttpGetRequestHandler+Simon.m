//
//  SIHttpGetRequestHandler+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 26/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIHttpGetRequestHandler+Simon.h"
#import <SImon/NSData+Simon.h>
#import <SImon/SIHttpPayload.h>
#import <dUsefulStuff/NSError+dUsefulStuff.h>
#import <dUsefulStuff/DCCommon.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>

@implementation SIHttpGetRequestHandler (Simon)

-(id<SIJsonAware>) objectOfClass:(Class) class fromData:(NSData *) data error:(NSError **) error {
	
	// Convert to a dictionary.
	id<SIJsonAware> obj = [data jsonToObjectWithClass:class error:error];
	if (obj == nil) {
		return [SIHttpPayload httpPayloadWithStatus: SIHttpStatusError message:[*error localizedErrorMessage]];
	}
	
	return obj;
}

-(NSObject<HTTPResponse> *) httpResponseWithPayload:(id<SIJsonAware>) payload {
	
	NSData *data = nil;
	NSError *error = nil;
	data = [NSJSONSerialization dataWithJSONObject:[payload jsonDictionary] options:0 error:&error];
	if (data == nil)  {
		return [self httpResponseWithError:error];
	}
	
	DC_LOG(@"Returning HTTP response with body: %@", DC_DATA_TO_STRING(data));
	return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
	
}

-(NSObject<HTTPResponse> *) httpResponseWithError:(NSError *) error {
	
	// Attempt to create a JSON response.
	NSString *msg = [error localizedErrorMessage];
	DC_LOG(@"Creating response for error: %@", msg);
	SIHttpPayload *body = [SIHttpPayload httpPayloadWithStatus:SIHttpStatusError message:msg];
	
	NSError *jsonError = nil;
	NSData *data = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
	if (data == nil) {
		// And if that fails, just send the text.
		return [[[HTTPDataResponse alloc] initWithData:DC_STRING_TO_DATA(msg)] autorelease];
	}
	
	return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
}

@end
