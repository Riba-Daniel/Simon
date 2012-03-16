//
//  BDDImplementations.m
//  Simon
//
//  Created by Derek Clarkson on 5/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SISimon.h"

@interface BDDImplementations : NSObject
@end

@implementation BDDImplementations

SIMapStepToSelector(@"Given we are on the first page", firstScreen)
-(void) firstScreen {
}

SIMapStepToSelector(@"Then goto the second page", gotoSecondScreen)
-(void) gotoSecondScreen {
   SITapTabBarButtonWithLabel(@"Second");
SIPauseFor(0.5);

}

@end
