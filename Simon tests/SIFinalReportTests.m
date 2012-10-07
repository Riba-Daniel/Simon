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
	

	GHAssertEquals([[jsonDic valueForKey:@"status"] intValue], SIHttpStatusError, nil);
	GHAssertEqualStrings([jsonDic valueForKey:@"message"], @"abc", nil);
	GHAssertEquals([[jsonDic valueForKey:@"notRun"] intValue], 2, nil);
	GHAssertEquals([[jsonDic valueForKey:@"successful"] intValue], 3, nil);
	GHAssertEquals([[jsonDic valueForKey:@"ignored"] intValue], 4, nil);
	GHAssertEquals([[jsonDic valueForKey:@"notMapped"] intValue], 5, nil);
	GHAssertEquals([[jsonDic valueForKey:@"failed"] intValue], 6, nil);
}

-(void) testInitWithJsonDictionary {
	NSDictionary *jsonDic = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithInt:SIHttpStatusError], @"status", @"abc", @"message",
									 [NSNumber numberWithInt:2], @"failed",
									 [NSNumber numberWithInt:3], @"ignored",
									 [NSNumber numberWithInt:4], @"notMapped",
									 [NSNumber numberWithInt:5], @"notRun",
									 [NSNumber numberWithInt:6], @"successful",
									 nil];
	
	SIFinalReport *report = [[[SIFinalReport alloc] initWithJsonDictionary:jsonDic] autorelease];
	
	GHAssertEquals(report.status, SIHttpStatusError, nil);
	GHAssertEqualStrings(report.message, @"abc", nil);
	GHAssertEquals(report.failed, 2lu, nil);
	GHAssertEquals(report.ignored, 3lu, nil);
	GHAssertEquals(report.notMapped, 4lu, nil);
	GHAssertEquals(report.notRun, 5lu, nil);
	GHAssertEquals(report.successful, 6lu, nil);

}

@end
