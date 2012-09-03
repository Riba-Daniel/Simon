//
//  SIUITooManyViewsException.h
//  Simon
//
//  Created by Derek Clarkson on 13/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Simon/SIAbstractException.h>

/**
 Exception which is thrown when more UIViews than expected were found as a result of a search query on the UI tree.
 */
@interface SIUITooManyFoundException : SIAbstractException

@end
