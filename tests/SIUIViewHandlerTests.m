//
//  SIUIActionTests.m
//  Simon
//
//  Created by Derek Clarkson on 10/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIUIViewHandler.h"
#import <dUsefulStuff/DCCommon.h>
#import "AbstractTestWithControlsOnView.h"
#import "UIView+Simon.h"


@interface SIUIViewHandlerTests : AbstractTestWithControlsOnView {
@private 
	SIUIViewHandler *handler;

}
-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position;
@end

@implementation SIUIViewHandlerTests

-(void) setUpClass {
   [super setUpClass];
   [self setupTestView];
}

-(void) tearDownClass {
   [self removeTestView];
   [super tearDownClass];
}

-(void) setUp {
	[super setUp];
	handler  = [[SIUIViewHandler alloc] init];
}

-(void) tearDown {
	DC_DEALLOC(handler);
	[super tearDown];	
}

#pragma mark - DNNode test

-(void) testName {
	handler.view = self.testViewController.button1;
	GHAssertEqualStrings(handler.name, @"UIRoundedRectButton", @"Incorrect node returned");
}

-(void) testParentName {
	handler.view = self.testViewController.button1;
	GHAssertEquals(handler.parentNode, self.testViewController.view, @"Incorrect name returned");
}

-(void) testAttributeQueryFailsWithInvalidPropertyName {
	handler.view = self.testViewController.button1;
	GHAssertThrowsSpecificNamed([handler hasAttribute:@"xyz" withValue:nil], NSException, @"NSUnknownKeyException", @"Handler should have failed request.");
}

-(void) testAttributeQueryMatchesPropertyValue {
	handler.view = self.testViewController.button1;
	GHAssertTrue([handler hasAttribute:@"alpha" withValue:[NSNumber numberWithInt:1]], @"Handler fails to match attribute data");
}

-(void) testAttributeQueryMatchesNestedPropertyValue {
	handler.view = self.testViewController.button1;
	GHAssertTrue([handler hasAttribute:@"titleLabel.text" withValue:@"Button 1"], @"Handler fails to match attribute data");
}

-(void) testSubnodes {
   SIPrintCurrentWindowTree();
   handler.view = self.testViewController.view;
	NSArray *subNodes = handler.subNodes;
	GHAssertEquals([subNodes count], (NSUInteger) 5, @"Should be one sub view");
	GHAssertEquals([subNodes objectAtIndex:0], self.testViewController.button1, @"Returned node was not button 1.");
	GHAssertEquals([subNodes objectAtIndex:1], self.testViewController.button2, @"Returned node was not button 2.");
	GHAssertEquals([subNodes objectAtIndex:2], self.testViewController.tabBar, @"Returned node was not the tab bar.");
	GHAssertEquals([subNodes objectAtIndex:3], self.testViewController.slider, @"Returned node was not the slider.");
	GHAssertEquals([subNodes objectAtIndex:4], self.testViewController.tableView, @"Returned node was not the tableView.");
}

#pragma mark - SIUIAction tests

-(void) testButtonTap {
	
   handler.view = self.testViewController.button1;
	[handler tap];
	
   GHAssertEquals(self.testViewController.tappedButton, 1, @"Tap did not occur as expected");
}

-(void) testTableViewTappingRowSelects {
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:0 atScrollPosition:UITableViewScrollPositionTop];

   handler.view = self.testViewController.tableView;
   [handler tap];
	
   GHAssertEquals(self.testViewController.selectedRow, (NSInteger) 1, @"Row not selected");
}

-(void) testSliderSwipingRight {
   handler.view = self.testViewController.slider;
   [handler swipe:SIUISwipeDirectionRight distance:60];
	GHAssertEquals(round(self.testViewController.slider.value), round(8), @"Swipe did not occur as expected");
}

-(void) testSliderSwipingLeft {
   handler.view = self.testViewController.slider;
   [handler swipe:SIUISwipeDirectionLeft distance:60];
	GHAssertEquals(round(self.testViewController.slider.value), round(2), @"Swipe did not occur as expected");
}


-(void) testTableViewSwipingUp {
   handler.view = self.testViewController.slider;
   [handler swipe:SIUISwipeDirectionUp distance:60];
	GHAssertEquals(round(self.testViewController.slider.value), round(1), @"Swipe did not occur as expected");
}

-(void) testTableViewSwipingDown {
   
   self.testViewController.selectedRow = 0;
   [self scrollTableViewToIndex:9 atScrollPosition:UITableViewScrollPositionBottom];
   
   handler.view = self.testViewController.tableView;
   //[handler swipe:SIUISwipeDirectionDown distance:60];
   [handler tap];
	GHAssertEquals(self.testViewController.selectedRow, (NSInteger)8, @"Row not selected");
}

#pragma mark - Helpers
-(void) scrollTableViewToIndex:(int) index atScrollPosition:(UITableViewScrollPosition) position {
   dispatch_queue_t mainQ = dispatch_get_main_queue();
   dispatch_sync(mainQ, ^{
      [self.testViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:position animated:NO];
      [[NSRunLoop currentRunLoop] runUntilDate: [NSDate date]];
   });
   
}


@end
