//
//  SIUISwipeGenerator.h
//  Simon
//
//  Created by Derek Clarkson on 24/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIUIEventGenerator.h"
#import "SIUIConstants.h"

/**
 Generates the series of events which simulate a swipe event. To do this we need to know how far to swipe, how long in time to take to do it, and how many events to generate per second. This last is specified by the eps value.
 */
@interface SIUISwipeGenerator : NSObject<SIUIEventGenerator>

/// @name Properties

/// The view that will be tapped.
@property (nonatomic, retain) UIView *view;

/// The distance to swipe in display points. Defaults to 60.
@property(nonatomic) NSUInteger distance;

/// How many frames per second to generate events at. Defaults to 48.
@property(nonatomic) NSUInteger eps;

/// How long in seconds the swipe will be. Defaults to 0.25
@property(nonatomic) NSTimeInterval duration;

/// THe direction of the swipe. Defaults to left.
@property(nonatomic) SIUISwipeDirection swipeDirection;

/// @name INitialiser

/**
 Default initialiser.
 
 @param view the view we are going to tap.
 */
-(id) initWithView:(UIView *) view;

@end
