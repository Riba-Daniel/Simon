//
//  SIHttpResponseBody.m
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIHttpBody.h>

@implementation SIHttpBody

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

+(id<SIJsonAware>) httpBodyWithStatus:(SIHttpStatus) status
										message:(NSString *) message {
	return [[[SIHttpBody alloc] initWithStatus:status message:message] autorelease];
}

-(id) initWithJsonDictionary:(NSDictionary *) data {
	self = [super init];
	if (self) {
		self.status = [[data valueForKey:RESPONSE_JSON_KEY_STATUS] intValue];
		self.message = [data valueForKey:RESPONSE_JSON_KEY_MESSAGE];
	}
	return self;
}

-(NSDictionary *) jsonDictionary {
	NSMutableDictionary *jsonData = [NSMutableDictionary dictionary];
	[jsonData setObject:[NSNumber numberWithInt:self.status] forKey:RESPONSE_JSON_KEY_STATUS];
	if (self.message != nil) {
		[jsonData setObject:self.message forKey:RESPONSE_JSON_KEY_MESSAGE];
	}
	return jsonData;
}

@end
