//
//  UIView+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dNodi/DNNode.h>
#import <Simon/SIUIViewInfo.h>

/**
 This category hooks into any UIVIew class and adds the methods dNodi
 needs to interrogate the UI object graph. The implementations call out to 
 the SIUIViewHandlerFactory to create a handler for the class that is being queried. 
 Then the method call is forwarded to the handler which also implements the DNNode protocol. 
 This allows the handler factory to be able to generate an apprpriate handler for the class on the UI instance. 
 */
@interface UIView (Simon) <DNNode,  SIUIViewInfo>

/// @name Tasks

/**
 Convert a point within the view to the matching co-orinates within the window.
 
 @param pointInView a CGPoint specifying the point within the we want converted.
 @return a CGPoint containing the same points in the windows co-ordinates.
 */
-(CGPoint) pointInWindowFromPointInView:(CGPoint) pointInView;

@end
