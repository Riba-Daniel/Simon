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
		[self setValuesForKeysWithDictionary:data];
	}
	return self;
}

-(NSDictionary *) jsonDictionary {
	NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[super jsonDictionary]];
	[data addEntriesFromDictionary:[self dictionaryWithValuesForKeys:@[@"notRun",@"successful",@"notMapped",@"ignored",@"failed"]]];
	return data;
}

@end
