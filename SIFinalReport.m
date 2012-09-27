//
//  SIFinalReport.m
//  Simon
//
//  Created by Derek Clarkson on 27/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIFinalReport.h"

@implementation SIFinalReport

@synthesize notRun = _notRun;
@synthesize successful = _successful;
@synthesize notMapped = _notMapped;
@synthesize ignored = _ignored;
@synthesize failed = _failed;

-(id) initWithJsonDictionary:(NSDictionary *) data {
	self = [super initWithJsonDictionary: data];
	if (self) {
		self.notRun = [[data valueForKey:FINAL_REPORT_JSON_KEY_NOT_RUN] unsignedIntegerValue];
		self.successful = [[data valueForKey:FINAL_REPORT_JSON_KEY_SUCCESSFUL] unsignedIntegerValue];
		self.notMapped = [[data valueForKey:FINAL_REPORT_JSON_KEY_NOT_MAPPED] unsignedIntegerValue];
		self.ignored = [[data valueForKey:FINAL_REPORT_JSON_KEY_IGNORED] unsignedIntegerValue];
		self.failed = [[data valueForKey:FINAL_REPORT_JSON_KEY_FAILED] unsignedIntegerValue];
	}
	return self;
}

-(NSDictionary *) jsonDictionary {
	NSMutableDictionary *jsonData = (NSMutableDictionary *)[super jsonDictionary];
	[jsonData setObject:[NSNumber numberWithUnsignedInteger:self.notRun] forKey:FINAL_REPORT_JSON_KEY_NOT_RUN];
	[jsonData setObject:[NSNumber numberWithUnsignedInteger:self.successful] forKey:FINAL_REPORT_JSON_KEY_SUCCESSFUL];
	[jsonData setObject:[NSNumber numberWithUnsignedInteger:self.notMapped] forKey:FINAL_REPORT_JSON_KEY_NOT_MAPPED];
	[jsonData setObject:[NSNumber numberWithUnsignedInteger:self.ignored] forKey:FINAL_REPORT_JSON_KEY_IGNORED];
	[jsonData setObject:[NSNumber numberWithUnsignedInteger:self.failed] forKey:FINAL_REPORT_JSON_KEY_FAILED];
	return jsonData;
}

@end
