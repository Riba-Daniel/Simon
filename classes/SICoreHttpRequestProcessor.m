
#import "SICoreHttpRequestProcessor.h"

@implementation SICoreHttpRequestProcessor

-(BOOL) canProcessPath:(NSString *) path withMethod:(SIHttpMethod) method {
	return NO;
}

-(NSObject<HTTPResponse> *) processPath:(NSString *) path withMethod:(SIHttpMethod) method andBody:(NSString *) body {
	return nil;
}

-(BOOL) expectingHttpBody {
	return NO;
}

@end
