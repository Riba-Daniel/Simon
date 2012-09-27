//
//  SIFinalReportTests.m
//  Simon
//
//  Created by Derek Clarkson on 27/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIFinalReport.h>
#import <Simon/SIHttpPayload.h>

@interface SIFinalReportTests : GHTestCase

@end

@implementation SIFinalReportTests

-(void) testJsonDictionary {
	SIFinalReport *report = [[[SIFinalReport alloc] initWithStatus:SIHttpStatusError message:@"abc"] autorelease];
	report.notRun = 2;
	report.successful = 3;
	report.ignored = 4;
	report.notMapped = 5;
	report.failed = 6;
	
	NSDictionary *jsonDic = [report jsonDictionary];
	

	GHAssertEquals([[jsonDic valueForKey:PAYLOAD_KEY_STATUS] intValue], SIHttpStatusError, nil);
	GHAssertEqualStrings([jsonDic valueForKey:PAYLOAD_KEY_MESSAGE], @"abc", nil);
	GHAssertEquals([[jsonDic valueForKey:FINAL_REPORT_JSON_KEY_NOT_RUN] intValue], 2, nil);
	GHAssertEquals([[jsonDic valueForKey:FINAL_REPORT_JSON_KEY_SUCCESSFUL] intValue], 3, nil);
	GHAssertEquals([[jsonDic valueForKey:FINAL_REPORT_JSON_KEY_IGNORED] intValue], 4, nil);
	GHAssertEquals([[jsonDic valueForKey:FINAL_REPORT_JSON_KEY_NOT_MAPPED] intValue], 5, nil);
	GHAssertEquals([[jsonDic valueForKey:FINAL_REPORT_JSON_KEY_FAILED] intValue], 6, nil);
}

-(void) testInitWithJsonDictionary {
	NSDictionary *jsonDic = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithInt:SIHttpStatusError], PAYLOAD_KEY_STATUS,
									 @"abc", PAYLOAD_KEY_MESSAGE,
									 [NSNumber numberWithInt:2], FINAL_REPORT_JSON_KEY_FAILED,
									 [NSNumber numberWithInt:3], FINAL_REPORT_JSON_KEY_IGNORED,
									 [NSNumber numberWithInt:4], FINAL_REPORT_JSON_KEY_NOT_MAPPED,
									 [NSNumber numberWithInt:5], FINAL_REPORT_JSON_KEY_NOT_RUN,
									 [NSNumber numberWithInt:6], FINAL_REPORT_JSON_KEY_SUCCESSFUL,
									 nil];
	
	SIFinalReport *report = [[[SIFinalReport alloc] initWithJsonDictionary:jsonDic] autorelease];
	
	GHAssertEquals(report.status, SIHttpStatusError, nil);
	GHAssertEqualStrings(report.message, @"abc", nil);
	GHAssertEquals(report.failed, 2u, nil);
	GHAssertEquals(report.ignored, 3u, nil);
	GHAssertEquals(report.notMapped, 4u, nil);
	GHAssertEquals(report.notRun, 5u, nil);
	GHAssertEquals(report.successful, 6u, nil);

}

@end
