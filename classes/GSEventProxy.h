//
//  GSEventProxy.h
//  Simon
//
//  Created by Derek Clarkson on 17/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 GSEvent is an undeclared object. We don't need to use it ourselves but some
 Apple APIs (UIScrollView in particular) require the x and y fields to be present.
 
 It is based on the excellant work done by Matt Gallagher.
 */

@interface GSEventProxy : NSObject
{
@public
   /*
   unsigned int flags;
   unsigned int type;
   unsigned int ignored1;
   float x;
   float y;
   float x1;
   float y1;
   float x2;
   float y2;
   unsigned int ignored2[24];
   unsigned int ignored3[7];
   float sizeX;
   float sizeY;
   float x3;
   float y3;
   unsigned int ignored4[3];
*/
}

@end
