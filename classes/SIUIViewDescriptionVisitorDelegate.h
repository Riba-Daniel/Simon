//
//  SIUIViewDescriptionVisitorDelegate.h
//  Simon
//
//  Created by Derek Clarkson on 9/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This delegate is called whenever a UIView is visited by the SIUIViewDescriptionVisitor class.
 */
@protocol SIUIViewDescriptionVisitorDelegate <NSObject>

/**
 Called when a node is visited.
 
 @param view the UIView that is being visited.
 @param description the text description, usually the class name of the UIView.
 @param attributes a dictionary of any attribute we might want to display.
 @param indexPath the index path to the UIView in the UI tree.
 @param sibling the index of the UIView when there are prior views with the same description and parent. i.e. siblings.
 */
-(void) visitedView:(UIView *) view 
		  description:(NSString *) description 
			attributes:(NSDictionary *) attributes
			 indexPath:(NSIndexPath *) indexPath
				sibling:(int) siblingIndex;

@end
