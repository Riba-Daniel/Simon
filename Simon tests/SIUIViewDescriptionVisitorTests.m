//
//  SIUIViewDescriptionVisitorTests.m
//  Simon
//
//  Created by Derek Clarkson on 9/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIUIViewDescriptionVisitor.h>
#import <Simon/SIUIViewDescriptionVisitorDelegate.h>
#import <OCMock/OCMock.h>

@interface SIUIViewDescriptionVisitorTests : GHTestCase {
@private 
}

@end

@implementation SIUIViewDescriptionVisitorTests

-(void) testVisitsSingleNode {
	
	UIView *testView = [[[UIView alloc] init] autorelease];
	NSIndexPath *testNodeIndexPath = [NSIndexPath indexPathWithIndex:0];
	
	id mockDelegate = [OCMockObject mockForProtocol:@protocol(SIUIViewDescriptionVisitorDelegate)];
	[[mockDelegate expect] visitView:testView description:@"UIView" attributes:nil indexPath:testNodeIndexPath sibling:0];
	
	SIUIViewDescriptionVisitor *visitor = [[[SIUIViewDescriptionVisitor alloc] initWithDelegate:mockDelegate] autorelease];
	[visitor visitView:testView];
	
	[mockDelegate verify];
	
}

-(void) testVisits2SubNodesNonSiblings {
	
	// Parent
	UIView *testView = [[[UIView alloc] init] autorelease];
	NSIndexPath *testNodeIndexPath = [NSIndexPath indexPathWithIndex:0];

	// Child nodes
	UIView *testSubView1 = [[[UIView alloc] init] autorelease];
	NSIndexPath *testSubViewIndexPath1 = [testNodeIndexPath indexPathByAddingIndex:0];
	[testView addSubview:testSubView1];

	UIView *testSubView2 = [[[UILabel alloc] init] autorelease];
	NSIndexPath *testSubViewIndexPath2 = [testNodeIndexPath indexPathByAddingIndex:1];
	[testView addSubview:testSubView2];

	// Mock delegate
	id mockDelegate = [OCMockObject mockForProtocol:@protocol(SIUIViewDescriptionVisitorDelegate)];
	[[mockDelegate expect] visitView:testView description:@"UIView" attributes:nil indexPath:testNodeIndexPath sibling:0];
	[[mockDelegate expect] visitView:testSubView1 description:@"UIView" attributes:nil indexPath:testSubViewIndexPath1 sibling:0];
	[[mockDelegate expect] visitView:testSubView2 description:@"UILabel" attributes:nil indexPath:testSubViewIndexPath2 sibling:0];
	
	SIUIViewDescriptionVisitor *visitor = [[[SIUIViewDescriptionVisitor alloc] initWithDelegate:mockDelegate] autorelease];
	[visitor visitView:testView];
	
	[mockDelegate verify];
	
}

-(void) testDetectsSiblings {
	
	// Parent
	UIView *testView = [[[UIView alloc] init] autorelease];
	NSIndexPath *testNodeIndexPath = [NSIndexPath indexPathWithIndex:0];
	
	// Siblings
	UIView *testSubView1 = [[[UIView alloc] init] autorelease];
	NSIndexPath *testSubViewIndexPath1 = [testNodeIndexPath indexPathByAddingIndex:0];
	[testView addSubview:testSubView1];
	
	UIView *testSubView2 = [[[UIView alloc] init] autorelease];
	NSIndexPath *testSubViewIndexPath2 = [testNodeIndexPath indexPathByAddingIndex:1];
	[testView addSubview:testSubView2];
	
	// Mock delegate
	id mockDelegate = [OCMockObject mockForProtocol:@protocol(SIUIViewDescriptionVisitorDelegate)];
	[[mockDelegate expect] visitView:testView description:@"UIView" attributes:nil indexPath:testNodeIndexPath sibling:0];
	[[mockDelegate expect] visitView:testSubView1 description:@"UIView" attributes:nil indexPath:testSubViewIndexPath1 sibling:0];
	[[mockDelegate expect] visitView:testSubView2 description:@"UIView" attributes:nil indexPath:testSubViewIndexPath2 sibling:1];
	
	SIUIViewDescriptionVisitor *visitor = [[[SIUIViewDescriptionVisitor alloc] initWithDelegate:mockDelegate] autorelease];
	[visitor visitView:testView];
	
	[mockDelegate verify];
	
}

@end
