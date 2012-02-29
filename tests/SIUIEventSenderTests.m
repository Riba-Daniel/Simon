//
//  SIUIEventCannonTests.m
//  Simon
//
//  Created by Derek Clarkson on 22/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "AbstractTestWithControlsOnView.h"
#import "SIUIBackgroundThreadSender.h"
#import "SIUIMainThreadSender.h"
#import "SIUIEventSender.h"
#import "SIUITapGenerator.h"
#import "SIUISwipeGenerator.h"

@interface SIUIEventSenderTests : AbstractTestWithControlsOnView

@end

@implementation SIUIEventSenderTests {
@private
   dispatch_queue_t background;
   dispatch_queue_t main;
}

-(void) setUpClass {
   [super setUpClass];
   background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   main = dispatch_get_main_queue();
}

-(void) testBackgroundSenderIsCreated {
   __block SIUIEventSender *sender;
   dispatch_sync(background, ^{
      sender = [[SIUIEventSender sender] retain];
   });
   [sender autorelease];
   GHAssertTrue([sender isKindOfClass: [SIUIBackgroundThreadSender class]], @"Incorrect class");
}

-(void) testMainThreadSenderIsCreated {
   __block SIUIEventSender *sender;
   dispatch_sync(main, ^{
      sender = [[SIUIEventSender sender] retain];
   });
   [sender autorelease];
   GHAssertTrue([sender isKindOfClass: [SIUIMainThreadSender class]], @"Incorrect class");
}

-(void) testSendEvent {
   dispatch_sync(background, ^{
      self.testViewController.tappedButton = 0;
      SIUITapGenerator *tapGenerator = [[[SIUITapGenerator alloc] initWithView:self.testViewController.button1] autorelease];
      [tapGenerator sendEvents];
   });
   [NSThread sleepForTimeInterval:0.1];
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Button not tapped");
}

@end
