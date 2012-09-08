//
//  SIHttpRequestProcessor+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SIHttpRequestProcessor+Simon.h"
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <dUsefulStuff/DCCommon.h>

@implementation SICoreHttpRequestProcessor (Simon)

-(NSObject<HTTPResponse> *) httpResponseWithBody:(id<SIJsonAware>) body {
	NSError *error = nil;
	NSData *data = [NSJSONSerialization dataWithJSONObject:[body jsonDictionary] options:0 error:&error];
	if (data == nil)  {
		NSString *errorMsg = [NSString stringWithFormat:@"Error: %@", [error localizedFailureReason]];
		return [[[HTTPDataResponse alloc] initWithData:DC_STRING_TO_DATA(errorMsg)] autorelease];
	}
	return [[[HTTPDataResponse alloc] initWithData:data] autorelease];

}

@end
