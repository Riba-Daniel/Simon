
#import "SIHttpGetRequestHandler.h"
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSError+dUsefulStuff.h>
#import <Simon/SIHttpPayload.h>
#import <Simon/SIHttpGetRequestHandler+Simon.h>

@interface SIHttpGetRequestHandler () {
	RequestReceivedBlock _requestReceivedBlock;
}

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
	DC_LOG(@"Request %@, returning response", path);
	id<SIJsonAware> responsePayload = [self runProcessWithRequestPayload:nil];
	return [self httpResponseWithPayload:responsePayload];
}

-(BOOL) expectingHttpBody {
	return NO;
}

-(id<SIJsonAware>) runProcessWithRequestPayload:(id<SIJsonAware>) payload {
	id<SIJsonAware> responsePayload = nil;
	if (_requestReceivedBlock != NULL) {
		responsePayload = _requestReceivedBlock(payload);
	}
	
	if (responsePayload == nil) {
		responsePayload = [SIHttpPayload httpPayloadWithStatus:SIHttpStatusOk message:nil];
	}
	return responsePayload;
}

@end
