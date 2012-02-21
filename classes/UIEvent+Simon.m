//
//  UIEvent+Simon.m
//  Simon
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

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
   /*
    CGPoint location = [touch locationInView:touch.window];
   gsEventProxy->x = location.x;
   gsEventProxy->y = location.y;
   gsEventProxy->x1 = location.x + 10;
   gsEventProxy->y1 = location.y + 10;
   gsEventProxy->x2 = location.x + 10;
   gsEventProxy->y2 = location.y + 10;
   gsEventProxy->x3 = location.x;
   gsEventProxy->y3 = location.y;
   gsEventProxy->sizeX = 1.0;
   gsEventProxy->sizeY = 1.0;
   gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
   gsEventProxy->type = 3001;       
   */
	// On SDK versions 3.0 and greater, we need to reallocate as a
	// UITouchesEvent.
   //[self release];
	//Class touchesEventClass = objc_getClass("UITouchesEvent");
   //self = [touchesEventClass alloc];
	self = [self _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
	if (self != nil)
	{
      // following line is inserted to support gesture recognizer  
      //DC_LOG(@"Adding gesture recognizers");
      [self _addGestureRecognizersForView:touch.view toTouch:touch currentTouchMap:nil newTouchMap:nil];
	}
	return self;
}

-(void) updateTimeStamp {
   [self _setTimestamp:[NSDate timeIntervalSinceReferenceDate]];
}


@end
