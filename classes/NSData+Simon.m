//
//  NSData+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 17/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "NSData+Simon.h"

@implementation NSData (Simon)

-(id<SIJsonAware>) jsonToObject {
	
	NSError *error = nil;
	NSDictionary *bodyObjDictionary = [NSJSONSerialization JSONObjectWithData:self
																							options:0
																							  error:&error];
	if (bodyObjDictionary == nil) {
		return nil;
	}
	
	// Now create the return type.
	return [[[[self class] alloc] initWithJsonDictionary:bodyObjDictionary] autorelease];
	
}

@end
