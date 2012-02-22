//
//  SIUIViewHandler.h
//  Simon
//
//  Created by Derek Clarkson on 13/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIUIAction.h"
#import <dNodi/DNNode.h>
#import "SIUIConstants.h"
#import "SIUIEventCannon.h"

/**
 Handlers encompass all aspects of dealing with a particular UI widget. This class
 is he base class for handlers and provides the core infrastructure they need. Handlers are automatically allocated
 based on the class of the node dNodi is processing.
 */
@interface SIUIViewHandler : NSObject<DNNode, SIUIAction> 

/**
 The view that is being managed.
 */
@property (retain, nonatomic) UIView<DNNode> *view;

/**
 The event cannon that will be used to fire events at the applications UI.
 */
@property (retain, nonatomic) SIUIEventCannon *eventCannon;

@end
