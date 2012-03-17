//
//  SIUITapGenerator.h
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIUIAbstractEventGenerator.h"

/**
 Generates a tap on the specified view.
 */
@interface SIUITapGenerator : SIUIAbstractEventGenerator 

/// Where the tap should occur. If this is equal to {CGFLOAT_MAX, CGFLOAT_MAX} then the tap will occur at the exact center of the view.
@property (nonatomic) CGPoint tapPoint;

@end
