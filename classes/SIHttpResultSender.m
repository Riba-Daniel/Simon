//
//  SIHttpResultSender.m
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIHttpResultSender.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIFinalReport.h>

@interface SIHttpResultSender () {
	@private
	SIHttpConnection *_connection;
}

@end

@implementation SIHttpResultSender

-(void) dealloc {
	DC_DEALLOC(_connection);
	[super dealloc];
}

-(id) initWithConnection:(SIHttpConnection *) connection {
	self = [super init];
	if (self) {
		_connection = [connection retain];
	}
	return self;
	
}

-(void) runStarting:(NSNotification *) notification {
	[super runStarting:notification];
	// DO something http'y
}

-(void) storyStarting:(NSNotification *) notification {
	[super storyStarting:notification];
	// DO something http'y
}

-(void) storyExecuted:(NSNotification *) notification {
	[super storyExecuted:notification];
	// DO something http'y
}

-(void) runFinished:(NSNotification *) notification {
	[super runFinished:notification];
	
	// Create the results object.
	SIFinalReport *results = [[SIFinalReport alloc] init];
	results.successful = [[self storiesWithStatus:SIStoryStatusSuccess] count];
	results.ignored = [[self storiesWithStatus:SIStoryStatusIgnored] count];
	results.failed = [[self storiesWithStatus:SIStoryStatusError] count];
	results.notMapped = [[self storiesWithStatus:SIStoryStatusNotMapped] count];
	results.notRun = [[self storiesWithStatus:SIStoryStatusNotRun] count];
	results.status = SIHttpStatusOk;
	
	[_connection sendRESTPostRequest:HTTP_PATH_RUN_FINISHED
								requestBody:results
						responseBodyClass:[SIHttpPayload class]
							  successBlock:NULL
								 errorBlock:NULL];
	[results release];
}

@end
