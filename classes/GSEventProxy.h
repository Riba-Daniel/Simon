//
//  GSEventProxy.h
//  Simon
//
//  Created by Derek Clarkson on 17/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 GSEvent is an undeclared object. We don't need to use it ourselves but some
 Apple APIs (UIScrollView in particular) require the x and y fields to be present.
 
 It is based on the excellant work done by Matt Gallagher.
 */

@interface GSEventProxy : NSObject

@end
