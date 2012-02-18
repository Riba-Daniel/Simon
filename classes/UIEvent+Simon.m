//
//  UIEvent+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "UIEvent+Simon.h"
#import "GSEventProxy.h"

//
// PublicEvent
//
// A dummy class used to gain access to UIEvent's private member variables.
// If UIEvent changes at all, this will break.
//
/*
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
*/


@interface UIEvent (_private)
//-(void) _addGestureRecognizersForView:(UIView *) view toTouch:(UITouch *) touch;
- (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12;

@end

@implementation UIEvent (Simon)

- (id)initWithTouch:(UITouch *)touch
{
	//CGPoint location = [touch locationInView:touch.window];
	GSEventProxy *gsEventProxy = [[[GSEventProxy alloc] init] autorelease];
	//gsEventProxy->x1 = location.x;
	//gsEventProxy->y1 = location.y;
	//gsEventProxy->x2 = location.x;
	//gsEventProxy->y2 = location.y;
	//gsEventProxy->x3 = location.x;
	//gsEventProxy->y3 = location.y;
	//gsEventProxy->sizeX = 1.0;
	//gsEventProxy->sizeY = 1.0;
   /*
   switch ([touch phase]) {
      case UITouchPhaseEnded:
         gsEventProxy->flags = 0x1010180;
         break;

      case UITouchPhaseMoved:
         gsEventProxy->flags = 0x2010180;
         break;
         
      default:
         // Started
         gsEventProxy->flags = 0x3010180;
         break;
   }

	gsEventProxy->type = 3001;	
	*/
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
      //[self _addGestureRecognizersForView:touch.view toTouch:touch];  
	}
	return self;
}

@end
