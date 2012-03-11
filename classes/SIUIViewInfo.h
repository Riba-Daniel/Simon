//
//  SIUIViewInfo.h
//  Simon
//
//  Created by Derek Clarkson on 11/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This protocol contains methods for getting information about a view.
 */
@protocol SIUIViewInfo <NSObject>

/**
 Returns a dictionary containing the KVC attributes that we should log in print statements.

 @return a NSDictionary.
 */
-(NSDictionary *) kvcAttributes;

@end
