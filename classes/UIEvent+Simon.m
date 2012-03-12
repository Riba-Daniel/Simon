//
//  UIEvent+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <objc/runtime.h>

#import "UIEvent+Simon.h"
#import "GSEventProxy.h"

@interface UIEvent (_private)
-(id) _initWithEvent:(GSEventProxy *)eventProxy touches:(NSSet *) touches;
-(BOOL) _addGestureRecognizersForView:(id)view toTouch:(id)touch currentTouchMap:(NSDictionary *)arg3 newTouchMap:(NSDictionary *)arg4;
-(void) _setTimestamp:(NSTimeInterval) timeStamp;
@end

@implementation UIEvent (Simon)

- (id)initWithTouch:(UITouch *)touch
{
   GSEventProxy *gsEventProxy = [[[GSEventProxy alloc] init] autorelease];

	// On SDK versions 3.0 and greater, we need to reallocate as a
	// UITouchesEvent.
   [self release];
	Class touchesEventClass = objc_getClass("UITouchesEvent");
   self = [touchesEventClass alloc];
	self = [self _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
	if (self != nil)
	{
      // following line is inserted to support gesture recognizer  
      [self _addGestureRecognizersForView:touch.view toTouch:touch currentTouchMap:nil newTouchMap:nil];
	}
	return self;
}

-(void) updateTimeStamp {
   [self _setTimestamp:[NSDate timeIntervalSinceReferenceDate]];
}


@end
