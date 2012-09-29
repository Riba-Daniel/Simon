//
//  SIHttpResponseBody.m
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIHttpPayload.h>

@implementation SIHttpPayload

@synthesize status = _status;
@synthesize message = _message;

-(void) dealloc {
	self.message = nil;
	[super dealloc];
}

-(id<SIJsonAware>) initWithStatus:(SIHttpStatus) status
								  message:(NSString *) message {
	self = [super init];
	if (self) {
		self.status = status;
		self.message = message;
	}
	return self;
}

+(id<SIJsonAware>) httpPayloadWithStatus:(SIHttpStatus) status
										message:(NSString *) message {
	return [[[SIHttpPayload alloc] initWithStatus:status message:message] autorelease];
}

-(id) initWithJsonDictionary:(NSDictionary *) data {
	self = [super init];
	if (self) {
		[self setValuesForKeysWithDictionary:data];
	}
	return self;
}

-(NSDictionary *) jsonDictionary {
	return [self dictionaryWithValuesForKeys:@[@"status", @"message"]];
}

@end
