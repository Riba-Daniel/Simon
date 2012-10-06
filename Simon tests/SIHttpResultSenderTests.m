//
//  SIHttpResultSenderTests.m
//  Simon
//
//  Created by Derek Clarkson on 30/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIHttpResultSender.h>
#import <Simon/SIStory.h>
#import <OCMock/OCMock.h>
#import <OCMock/OCMArg.h>
#import <Simon/SIhttpConnection.h>
#import <Simon/SIHttpPayload.h>
#import <Simon/SIFinalReport.h>

@interface SIHttpResultSenderTests : GHTestCase
-(void) addStoryToSender:(SIHttpResultSender *) sender withStatus:(SIStoryStatus) status;
@end

@implementation SIHttpResultSenderTests



-(void) testSendsResults {
	
	id mockConnection = [OCMockObject mockForClass:[SIHttpConnection class]];
	[[mockConnection expect] sendRESTPostRequest:HTTP_PATH_RUN_FINISHED
												requestBody:[OCMArg checkWithBlock:^(id value) {
		GHAssertTrue([value isKindOfClass:[SIFinalReport class]], nil);
		SIFinalReport *report = (SIFinalReport *)value;
		GHAssertEquals(report.successful, 1u, nil);
		GHAssertEquals(report.ignored, 1u, nil);
		GHAssertEquals(report.failed, 1u, nil);
		GHAssertEquals(report.notRun, 1u, nil);
		GHAssertEquals(report.notMapped, 1u, nil);
		GHAssertEquals(report.status, SIHttpStatusOk, nil);
		return YES;
	}]
										responseBodyClass:[SIHttpPayload class]
											  successBlock:nil
												 errorBlock:[OCMArg any]];
	
	SIHttpResultSender *sender = [[[SIHttpResultSender alloc] initWithConnection:mockConnection] autorelease];
	
	[self addStoryToSender:sender withStatus:SIStoryStatusError];
	[self addStoryToSender:sender withStatus:SIStoryStatusIgnored];
	[self addStoryToSender:sender withStatus:SIStoryStatusNotMapped];
	[self addStoryToSender:sender withStatus:SIStoryStatusNotRun];
	[self addStoryToSender:sender withStatus:SIStoryStatusSuccess];
	
	[sender runFinished:[NSNotification notificationWithName:@"x" object:self userInfo:nil]];
	
}

-(void) addStoryToSender:(SIHttpResultSender *) sender withStatus:(SIStoryStatus) status {
	
	id mockStory = [OCMockObject mockForClass:[SIStory class]];
	// Turn of strict selector match diagnostic because GHTestCase as a status method and the compiler doesn't know which to use.
#pragma GCC diagnostic ignored "-Wstrict-selector-match"
	[[[mockStory stub] andReturnValue:OCMOCK_VALUE(status)] status];
#pragma GCC diagnostic warning "-Wstrict-selector-match"
	
	NSDictionary *userInfo = @{SI_NOTIFICATION_KEY_STORY:mockStory};
	NSNotification *notification = [NSNotification notificationWithName:@"x" object:self userInfo:userInfo];
	
	[sender storyExecuted:notification];
	
}


@end
