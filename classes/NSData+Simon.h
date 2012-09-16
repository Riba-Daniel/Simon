//
//  NSData+Simon.h
//  Simon
//
//  Created by Derek Clarkson on 17/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon/SIJsonAware.h>

@interface NSData (Simon)

/**
 Used as a factory method to create an instance of the class from the passed JSON stored in a NSData object.
 */
-(id<SIJsonAware>) jsonToObject;

@end
