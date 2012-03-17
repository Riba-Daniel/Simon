//
//  SIUIViewDescriptionVisitor.m
//  Simon
//
//  Created by Derek Clarkson on 9/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIViewDescriptionVisitor.h"
#import "UIView+Simon.h"

@interface SIUIViewDescriptionVisitor (_private)

// Private method which does the work.
-(void) visitView:(UIView *) view
		  indexPath:(NSIndexPath *) indexPath
	  siblingNames:(NSMutableArray *) siblingNames;
@end

@implementation SIUIViewDescriptionVisitor

// Main initialiser.
-(id) initWithDelegate:(NSObject<SIUIViewDescriptionVisitorDelegate> *) aDelegate {
	self = [super init];
	if (self) {
		delegate = aDelegate;
	}
	return self;
}

// Entry point method.
-(void) visitView:(UIView *) view {
	
	// Create the initial index path and sibling array. 
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:0];
	NSMutableArray *siblingNames = [NSMutableArray array];
	
	// Call the main processing method.
	[self visitView:view indexPath:indexPath siblingNames:siblingNames];
}

-(void) visitAllWindows {

	// Create the initial index path and sibling array. 
	NSMutableArray *siblingNames = [NSMutableArray array];
	
	// Get the window list.
	NSArray *windows = [UIApplication sharedApplication].windows;
	for (int i = 0;i < [windows count];i++) {
		UIWindow *window = [windows objectAtIndex:i];
		[self visitView:window indexPath:[NSIndexPath indexPathWithIndex:i] siblingNames:siblingNames];
	}
}


// Main processing method.
-(void) visitView:(UIView *) view
		  indexPath:(NSIndexPath *) indexPath
	  siblingNames:(NSMutableArray *) siblingNames {
	
	// Get the sibling count.
	NSString *viewDescription = view.dnName;
	__block int siblingCount = 0;
	[siblingNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([viewDescription isEqualToString: obj]) {
			siblingCount++;
		}
	}];
	
	// Now add the description to the sibling list.
	[siblingNames addObject:viewDescription];
	
	// Tell the delegate we are being visited.
	[delegate visitedView:view 
				 description:viewDescription 
				  attributes:[view kvcAttributes]
					indexPath:indexPath
					  sibling:siblingCount];
	
	// Loop through subviews and visit each one.
	int idx = 0;
	NSMutableArray *subNodeSiblings = [NSMutableArray array];
	for(UIView *subView in view.subviews) {
		NSIndexPath *subNodeIndexPath = [indexPath indexPathByAddingIndex:idx];
		[self visitView: subView indexPath:subNodeIndexPath siblingNames:subNodeSiblings];
		idx++;
	}
	
}

@end
