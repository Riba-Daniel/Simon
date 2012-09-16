//
//  SIHttpPostRequestHandler.m
//  Simon
//
//  Created by Derek Clarkson on 16/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIHttpPostRequestHandler.h"
#import <Simon/SIHttpBody.h>

#import <dUsefulStuff/NSError+dUsefulStuff.h>

@interface SIHttpPostRequestHandler () {
@private
	Class _requestBodyClass;
}

@end

@implementation SIHttpPostRequestHandler

#pragma mark - Lifecycle

-(id) initWithPath:(NSString *) path
  requestBodyClass:(Class) requestBodyClass
			  process:(RequestReceivedBlock) requestReceivedBlock {
	self = [super initWithPath:path process: requestReceivedBlock];
	if (self) {
		_requestBodyClass = requestBodyClass;
	}
	return self;
}

#pragma mark - Interface methods

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodPost && [path isEqualToString:self.path];
}

-(BOOL) expectingHttpBody {
	return _requestBodyClass != NULL;
}

-(id<SIJsonAware>) bodyObjectFromBody:(NSData *) body {

	if (_requestBodyClass == NULL) {
		return nil;
	}
	
	// Convert to a dictionary.
	NSError *error = nil;
	NSDictionary *bodyObjDictionary = [NSJSONSerialization JSONObjectWithData:body
																							options:0
																							  error:&error];
	if (bodyObjDictionary == nil) {
		return [SIHttpBody httpBodyWithStatus: SIHttpStatusError message:[error localizedErrorMessage]];
	}
	
	// Now create the return type.
	return [[[_requestBodyClass alloc] initWithJsonDictionary:bodyObjDictionary] autorelease];
}

#pragma mark - Helper methods


@end
