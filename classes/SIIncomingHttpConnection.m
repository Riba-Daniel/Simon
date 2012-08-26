//
//  SIIncomingHTTPConnection.m
//  Simon
//
//  Created by Derek Clarkson on 13/07/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIIncomingHttpConnection.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIAppBackpack.h>

@interface SIIncomingHttpConnection ()
@property (retain, nonatomic) NSArray *processors;
@end

@implementation SIIncomingHttpConnection

@synthesize processors;

-(void) dealloc {
	self.processors = nil;
	[super dealloc];
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {

	// Expect all posts to have a http body.
	if([method isEqualToString:@"POST"]) {
		return YES;
	}
	
	// Otherwise default to the super.
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
	return [super httpResponseForMethod:method URI:path];
}

@end
