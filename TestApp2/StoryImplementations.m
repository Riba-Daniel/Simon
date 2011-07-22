//
//  StoryImplementations.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011 Sensis. All rights reserved.
//
#import "SISimon.h"

@interface StoryImplementations : NSObject{
}
@end

@implementation StoryImplementations

SIMapStepToSelector(@"Given the interface is up", givenTheInterfaceIsUp)

-(void) givenTheInterfaceIsUp {
	
}

SIMapStepToSelector(@"then I can switch to the second view", clickTheSecondView)
-(void) clickTheSecondView {
	
}

SIMapStepToSelector(@"and see the view", verifyTheViewIsVisible)
-(void) verifyTheViewIsVisible {
	
}

@end
