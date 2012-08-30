//
//  SIHttpResponseBody.m
//  Simon
//
//  Created by Derek Clarkson on 29/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpResponseBody.h>

@implementation SIHttpResponseBody

@synthesize status = _status;

-(id) initWithJsonDictionary:(NSDictionary *) data {
	self = [super init];
	if (self) {
		self.status = [[data valueForKey:RESPONSE_JSON_KEY_STATUS] intValue];
	}
	return self;
}

-(NSDictionary *) jsonDictionary {
	NSMutableDictionary *jsonData = [NSMutableDictionary dictionary];
	[jsonData setObject:[NSNumber numberWithInt:self.status] forKey:RESPONSE_JSON_KEY_STATUS];
	return jsonData;
}

@end
