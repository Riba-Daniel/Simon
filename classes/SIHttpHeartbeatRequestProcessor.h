//
//  SIHttpHeartbeatRequestProcessor.h
//  Simon
//
//  Created by Derek Clarkson on 27/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SICoreHttpRequestProcessor.h>

/**
 Simple heard beat request processor which the Pieman calls to detect hung testing.
 */
@interface SIHttpHeartbeatRequestProcessor : SICoreHttpRequestProcessor

@end
