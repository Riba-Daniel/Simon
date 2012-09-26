//
//  SIHttpConnectionTests.m
//  Simon
//
//  Created by Derek Clarkson on 20/09/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIHttpConnection.h>
#import <Simon/SIHttpBody.h>
#import <dUsefulStuff/DCCommon.h>
#import <objc/runtime.h>

BOOL bodyPresent;
BOOL bodyCorrect;

@interface SIHttpConnectionTests : GHTestCase {
@private
	IMP oldImp;
	Method oldMethod;
	SIHttpConnection *connection;
	__block BOOL successBlockCalled;
	__block BOOL errorBlockCalled;
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
					  returningResponse:(NSURLResponse **)response
									  error:(NSError **)error;
+ (NSData *)errorFromRequest:(NSURLRequest *)request
			  returningResponse:(NSURLResponse **)response
							  error:(NSError **)error;
+ (NSData *)errorFromInvalidReponseWithRequest:(NSURLRequest *)request
									  returningResponse:(NSURLResponse **)response
													  error:(NSError **)error;
@end

@implementation SIHttpConnectionTests

-(void) setUp {
	
	// Override the NSURLConnection send method so it does nothing.
	oldMethod = class_getClassMethod([NSURLConnection class], @selector(sendSynchronousRequest:returningResponse:error:));
	oldImp = method_getImplementation(oldMethod);
	
	connection = [[SIHttpConnection alloc] initWithHostUrl:@"abc.com"
															sendGCDQueue:dispatch_get_current_queue()
													  responseGCDQueue:dispatch_get_current_queue()];
	successBlockCalled = NO;
	errorBlockCalled = NO;
	
}

-(void) tearDown {
	// Restore the method.
	method_setImplementation(oldMethod, oldImp);
	DC_DEALLOC(connection);
}

#pragma mark - Tests

-(void) testSendGet {
	
	Method newMethod = class_getClassMethod([self class], @selector(sendSynchronousRequest:returningResponse:error:));
	IMP newImp = method_getImplementation(newMethod);
	method_setImplementation(oldMethod, newImp);
	
	[connection sendRESTRequest:@"/def"
								method:SIHttpMethodGet
						 requestBody:nil
				 responseBodyClass:nil
						successBlock:^(id<SIJsonAware> bodyObj) {
							DC_LOG(@"Success block");
							successBlockCalled = YES;
						}
						  errorBlock:^(id<SIJsonAware> bodyObj, NSError *error) {
							  DC_LOG(@"Error block");
							  errorBlockCalled = YES;
						  }];
	
	[NSThread sleepForTimeInterval:0.1];
	
	GHAssertTrue(successBlockCalled, nil);
	GHAssertFalse(errorBlockCalled, nil);
}

-(void) testSendGetGeneratesError {
	
	Method newMethod = class_getClassMethod([self class], @selector(errorFromRequest:returningResponse:error:));
	IMP newImp = method_getImplementation(newMethod);
	method_setImplementation(oldMethod, newImp);
	
	[connection sendRESTRequest:@"/def"
								method:SIHttpMethodGet
						 requestBody:nil
				 responseBodyClass:nil
						successBlock:^(id<SIJsonAware> bodyObj) {
							DC_LOG(@"Success block");
							successBlockCalled = YES;
						}
						  errorBlock:^(id<SIJsonAware> bodyObj, NSError *error) {
							  DC_LOG(@"Error block");
							  errorBlockCalled = YES;
							  GHAssertEquals([error code], 1, nil);
						  }];
	
	[NSThread sleepForTimeInterval:0.1];
	
	GHAssertFalse(successBlockCalled, nil);
	GHAssertTrue(errorBlockCalled, nil);
}

-(void) testSendPostGeneratesErrorForInvalidResponse {
	
	Method newMethod = class_getClassMethod([self class], @selector(errorFromInvalidReponseWithRequest:returningResponse:error:));
	IMP newImp = method_getImplementation(newMethod);
	method_setImplementation(oldMethod, newImp);
	
	[connection sendRESTRequest:@"/def"
								method:SIHttpMethodPost
						 requestBody:nil
				 responseBodyClass:[SIHttpBody class]
						successBlock:^(id<SIJsonAware> bodyObj) {
							DC_LOG(@"Success block with %@", bodyObj);
							successBlockCalled = YES;
						}
						  errorBlock:^(id<SIJsonAware> bodyObj, NSError *error) {
							  DC_LOG(@"Error block");
							  errorBlockCalled = YES;
							  GHAssertEquals([error code], 3840, nil);
						  }];
	
	[NSThread sleepForTimeInterval:0.1];
	
	GHAssertFalse(successBlockCalled, nil);
	GHAssertTrue(errorBlockCalled, nil);
}

-(void) testSendPostWithRequestBody {
	
	Method newMethod = class_getClassMethod([self class], @selector(sendPostWithBodyRequest:returningResponse:error:));
	IMP newImp = method_getImplementation(newMethod);
	method_setImplementation(oldMethod, newImp);
	
	id<SIJsonAware> body = [SIHttpBody httpBodyWithStatus:SIHttpStatusError message:@"abc"];

	bodyPresent = NO;
	bodyCorrect = NO;

	[connection sendRESTRequest:@"/def"
								method:SIHttpMethodPost
						 requestBody:body
				 responseBodyClass:[SIHttpBody class]
						successBlock:^(id<SIJsonAware> bodyObj) {

							DC_LOG(@"Success block with %@", bodyObj);
							successBlockCalled = YES;
						
						}
						  errorBlock:^(id<SIJsonAware> bodyObj, NSError *error) {
							  DC_LOG(@"Error block");
							  errorBlockCalled = YES;
						  }];
	
	[NSThread sleepForTimeInterval:0.1];
	
	GHAssertTrue(successBlockCalled, nil);
	GHAssertFalse(errorBlockCalled, nil);
	GHAssertTrue(bodyPresent, nil);
	GHAssertTrue(bodyCorrect, nil);
}

#pragma mark - Swizzled methods

static const char * successJson = "{\"status\":\"0\"}";
static const char * corruptJson = "abc";

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
					  returningResponse:(NSURLResponse **)response
									  error:(NSError **)error {
	DC_LOG(@"Swizzled sendSynchronousRequest:returnResponse:error:");
	return [NSData dataWithBytes:successJson length:strlen(successJson)];
}

+ (NSData *)errorFromRequest:(NSURLRequest *)request
			  returningResponse:(NSURLResponse **)response
							  error:(NSError **)error {
	DC_LOG(@"Swizzled errorFromRequest:returnResponse:error:");
	DC_DEALLOC(*error);
	*error = [NSError errorWithDomain:@"Domain" code:1 userInfo:nil];
	return nil;
}

+ (NSData *)errorFromInvalidReponseWithRequest:(NSURLRequest *)request
									  returningResponse:(NSURLResponse **)response
													  error:(NSError **)error{
	DC_LOG(@"Swizzled errorFromInvalidReponseWithRequest:returnResponse:error:");
	return [NSData dataWithBytes:corruptJson length:strlen(corruptJson)];
}

+ (NSData *)sendPostWithBodyRequest:(NSURLRequest *)request
					  returningResponse:(NSURLResponse **)response
									  error:(NSError **)error {
	
	DC_LOG(@"Swizzled sendPostWithBodyRequest:returnResponse:error:");
	NSData *body = [request HTTPBody];
	DC_LOG(@"Received body: '%@'", DC_DATA_TO_STRING(body));
	NSString *expecting = @"{\"status\":1,\"message\":\"abc\"}";
	DC_LOG(@"Checking with: '%@'", expecting);
	bodyPresent = body != nil;
	bodyCorrect = [expecting isEqualToString:DC_DATA_TO_STRING(body)];

	return [NSData dataWithBytes:successJson length:strlen(successJson)];
}



@end
