//
//  SIHttpBackpack.h
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIAppBackpack.h>
#import <CocoaHTTPServer/HTTPServer.h>

/**
 SIHttpBackpack implementation which is used when Simon is running in CI mode and talking to a command line control program.
 */
@interface SIHttpAppBackpack : SIAppBackpack {
	@private
	HTTPServer *server;
}

@end
