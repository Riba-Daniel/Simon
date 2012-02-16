//
//  UIEvent+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "UIEvent+Simon.h"

//
// GSEvent is an undeclared object. We don't need to use it ourselves but some
// Apple APIs (UIScrollView in particular) require the x and y fields to be present.
//
@interface GSEventProxy : NSObject
{
@public
	unsigned int flags;
	unsigned int type;
	unsigned int ignored1;
	float x1;
	float y1;
	float x2;
	float y2;
	unsigned int ignored2[10];
	unsigned int ignored3[7];
	float sizeX;
	float sizeY;
	float x3;
	float y3;
	unsigned int ignored4[3];
}
@end
@implementation GSEventProxy
@end

//
// PublicEvent
//
// A dummy class used to gain access to UIEvent's private member variables.
// If UIEvent changes at all, this will break.
//
@interface PublicEvent : NSObject
{
@public
   GSEventProxy           *_event;
   NSTimeInterval          _timestamp;
   NSMutableSet           *_touches;
   CFMutableDictionaryRef  _keyedTouches;
}
@end

@implementation PublicEvent
@end



@interface UIEvent (_private)

- (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12;

@end

@implementation UIEvent (Simon)

- (id)initWithTouch:(UITouch *)touch
{
	CGPoint location = [touch locationInView:touch.window];
	GSEventProxy *gsEventProxy = [[[GSEventProxy alloc] init] autorelease];
	gsEventProxy->x1 = location.x;
	gsEventProxy->y1 = location.y;
	gsEventProxy->x2 = location.x;
	gsEventProxy->y2 = location.y;
	gsEventProxy->x3 = location.x;
	gsEventProxy->y3 = location.y;
	gsEventProxy->sizeX = 1.0;
	gsEventProxy->sizeY = 1.0;
	gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
	gsEventProxy->type = 3001;	
	
	//
	// On SDK versions 3.0 and greater, we need to reallocate as a
	// UITouchesEvent.
	//
	Class touchesEventClass = objc_getClass("UITouchesEvent");
	if (touchesEventClass && ![[self class] isEqual:touchesEventClass])
	{
		DC_LOG(@"Reallocing as a UITouchesEvent");
		[self release];
		self = [touchesEventClass alloc];
	}
	
	self = [self _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
	if (self != nil)
	{
      // following line is inserted to support gesture recognizer  
      [self _addGestureRecognizersForView:touch.view toTouch:touch];  
	}
	return self;
}

@end
