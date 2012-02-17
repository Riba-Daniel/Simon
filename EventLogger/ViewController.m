//
//  ViewController.m
//  EventLogger
//
//  Created by Derek Clarkson on 15/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "ViewController.h"
#import <dUsefulStuff/DCCommon.h>
#import <objc/runtime.h>

@interface ViewController(private)
-(void) swizzle;
-(void) swizzleSelector:(SEL) selector intoClass:(Class) targetClass;
@end

@implementation ViewController

-(void) viewDidLoad {
   [self swizzle];
}

@synthesize buttonA = buttonA_;
@synthesize buttonB = buttonB_;
-(IBAction) buttonATapped:(id) sender {
   DC_LOG(@"Button A tapped");
}
-(IBAction) buttonBTapped:(id) sender {
   DC_LOG(@"Button B tapped");
}

// Implementations to be swizzled in.

-(void) swizzle {
   [self swizzleSelector: @selector(touchesBegan:withEvent:) intoClass:[self.buttonA class]];
   [self swizzleSelector: @selector(touchesEnded:withEvent:) intoClass:[self.buttonA class]];
   [self swizzleSelector: @selector(touchesMoved:withEvent:) intoClass:[self.buttonA class]];
   [self swizzleSelector: @selector(touchesCancelled:withEvent:) intoClass:[self.buttonA class]];
}

-(void) swizzleSelector:(SEL) selector intoClass:(Class) targetClass {
   Method method = class_getInstanceMethod([self class], selector);
   IMP swizzleImp = class_getMethodImplementation([self class], selector);
   class_replaceMethod(targetClass, selector, swizzleImp, method_getTypeEncoding(method));
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   [ViewController logEvent:event source:@"Began"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   [ViewController logEvent:event source:@"Moved"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   [ViewController logEvent:event source:@"Ended"];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
   [ViewController logEvent:event source:@"Cancelled"];
}

+(void) logEvent:(UIEvent *) event source:(NSString *) source {
   NSMutableString *touchString = [NSMutableString string];
   int index = 0;
   for (UITouch *touch in [event allTouches]) {
      CGPoint pos = [touch locationInView:touch.view];
      [touchString appendFormat:@" [%i] v:%i %ix%i", index, touch.view.tag, (int)pos.x, (int)pos.y];
      index++;
   }
   DC_LOG(@"%@ T:%i ST:%i touches:%i%@", source, event.type, event.subtype, [[event allTouches] count], touchString);
}


@end
