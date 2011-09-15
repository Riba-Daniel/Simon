//
//  UIView+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dNodi/DNNode.h>

/**
 This category hooks into any UIVIew class and adds the methods dNodi
 needs to interrogate the UI object graph. The implementations call out to 
 the SIUIHandlerFactory to create a handler for the class that is being queried. Then
 the method call is forwarded to the handler which also implements the DNNode protocol. This allows the handler factory to be able to generate an apprpriate handler for the class o the UI instance. 
 */
@interface UIView (Simon) <DNNode>

@end
