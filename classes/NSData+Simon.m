//
//  NSData+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 17/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "NSData+Simon.h"

@implementation NSData (Simon)

-(id<SIJsonAware>) jsonToObjectWithClass:(Class) expectedClass error:(NSError **) error {
	
	NSDictionary *bodyObjDictionary = [NSJSONSerialization JSONObjectWithData:self
																							options:0
																							  error:error];
	if (bodyObjDictionary == nil) {
		return nil;
	}
	
	// Now create the return type.
	return [[[expectedClass alloc] initWithJsonDictionary:bodyObjDictionary] autorelease];
	
}

@end
