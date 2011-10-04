//
//  SIUIViewHandler.h
//  Simon
//
//  Created by Derek Clarkson on 13/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <dNodi/DNNode.h>
#import <UIKit/UIKit.h>
#import "SIUIAction.h"

/**
 Handlers encompass all aspects of dealing with a particular UI widget. This class
 is he base class for handlers and provides the core infrastructure they need. Handlers are automatically allocated
 based on the class of the node dNodi is processing.
 */
@interface SIUIViewHandler : NSObject <DNNode, SIUIAction>

@property (retain, nonatomic) UIView<DNNode> *view;

@end
