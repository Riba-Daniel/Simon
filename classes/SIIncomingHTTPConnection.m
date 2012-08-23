//
//  SIIncomingHTTPConnection.m
//  Simon
//
//  Created by Derek Clarkson on 13/07/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <Simon/SIIncomingHTTPConnection.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIAppBackpack.h>

#define REPORT @"<testsuite>" \
"<testcase classname=\"foo\" name=\"ASuccessfulTest\"/>" \
"<testcase classname=\"foo\" name=\"AnotherSuccessfulTest\"/>" \
"<testcase classname=\"foo\" name=\"AFailingTest\">" \
"<failure type=\"NotEnoughFoo\"> details about failure </failure>" \
"</testcase>" \
"</testsuite>"

@implementation SIIncomingHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	if ([method isEqualToString:@"POST"]) {
		return [path isEqualToString:@"/run/all"];
	}
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
	if([method isEqualToString:@"POST"]) {
		return YES;
	}
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/run/all"]) {
		NSNotification *notification = [NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:self];
		[[NSNotificationCenter defaultCenter] postNotification:notification];
		NSString *responseBody = REPORT;
		return [[[HTTPDataResponse alloc] initWithData:DC_STRING_TO_DATA(responseBody)] autorelease];
	}
	return [super httpResponseForMethod:method URI:path];
}

@end
