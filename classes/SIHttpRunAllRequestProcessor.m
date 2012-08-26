//
//  SIHttpRunAllRequest.m
//  Simon
//
//  Created by Derek Clarkson on 24/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpRunAllRequestProcessor.h>
#import <Simon/SIConstants.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <dUsefulStuff/DCCommon.h>

#define REPORT @"<testsuite>" \
"<testcase classname=\"foo\" name=\"ASuccessfulTest\"/>" \
"<testcase classname=\"foo\" name=\"AnotherSuccessfulTest\"/>" \
"<testcase classname=\"foo\" name=\"AFailingTest\">" \
"<failure type=\"NotEnoughFoo\"> details about failure </failure>" \
"</testcase>" \
"</testsuite>"

@implementation SIHttpRunAllRequestProcessor

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodPost && [path isEqualToString:@"/run/all"];
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body {
	NSNotification *notification = [NSNotification notificationWithName:SI_RUN_STORIES_NOTIFICATION object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	return nil;
	
	NSString *responseBody = REPORT;
	return [[[HTTPDataResponse alloc] initWithData:DC_STRING_TO_DATA(responseBody)] autorelease];

}

-(BOOL) expectingHttpBody {
	return NO;
}

@end
