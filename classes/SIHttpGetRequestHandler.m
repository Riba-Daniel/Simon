
#import "SIHttpGetRequestHandler.h"
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSError+dUsefulStuff.h>
#import <Simon/SIHttpBody.h>

@interface SIHttpGetRequestHandler () {
	RequestReceivedBlock _requestReceivedBlock;
}

-(id<SIJsonAware>) responseBodyObjectWithRequestBody:(NSData *) body;
-(NSObject<HTTPResponse> *) httpResponseWithBody:(id<SIJsonAware>) body;

@end

@implementation SIHttpGetRequestHandler

@synthesize path = _path;

#pragma mark - Lifecycle

-(void) dealloc {
	self.path = nil;
	Block_release(_requestReceivedBlock);
	[super dealloc];
}

-(id) initWithPath:(NSString *) path process:(RequestReceivedBlock) requestReceivedBlock {
	self = [super init];
	if (self) {
		self.path = path;
		_requestReceivedBlock = Block_copy(requestReceivedBlock);
	}
	return self;
}

#pragma mark - Interface methods

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return method == SIHttpMethodGet && [path isEqualToString:self.path];
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path andBody:(NSData *) body {
	id<SIJsonAware> responseBodyObj = [self responseBodyObjectWithRequestBody:body];
	DC_LOG(@"Request %@, returning response", path);
	return [self httpResponseWithBody:responseBodyObj];
}

-(BOOL) expectingHttpBody {
	return NO;
}

-(id<SIJsonAware>) bodyObjectFromBody:(NSData *) body {
	return nil;
}

#pragma mark - Helper methods

-(id<SIJsonAware>) responseBodyObjectWithRequestBody:(NSData *) body {

	if (_requestReceivedBlock != NULL) {
		id<SIJsonAware> bodyObj = [self bodyObjectFromBody:body];
		return _requestReceivedBlock(bodyObj);
	}
	
	return [SIHttpBody httpBodyWithStatus:SIHttpStatusOk message:nil];
}

-(NSObject<HTTPResponse> *) httpResponseWithBody:(id<SIJsonAware>) body {
	
	NSData *data = nil;
	NSError *error = nil;
	data = [NSJSONSerialization dataWithJSONObject:[body jsonDictionary] options:0 error:&error];
	if (data == nil)  {
		return [self responseForError:error];
	}
	
	DC_LOG(@"Returning HTTP response with body: %@", DC_DATA_TO_STRING(data));
	return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
	
}

-(NSObject<HTTPResponse> *) responseForError:(NSError *) error {
	
	// Attempt to create a JSON response.
	NSString *msg = [error localizedErrorMessage];
	DC_LOG(@"Creating response for error: %@", msg);
	SIHttpBody *body = [SIHttpBody httpBodyWithStatus:SIHttpStatusError message:msg];
	
	NSError *jsonError = nil;
	NSData *data = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
	if (data == nil) {
		// And if that fails, just send the text.
		return [[[HTTPDataResponse alloc] initWithData:DC_STRING_TO_DATA(msg)] autorelease];
	}
	
	return [[[HTTPDataResponse alloc] initWithData:data] autorelease];
}

@end
