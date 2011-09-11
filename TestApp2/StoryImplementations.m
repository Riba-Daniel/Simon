//
//  StoryImplementations.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//
#import "SISimon.h"

@interface StoryImplementations : NSObject{
}
@end

@implementation StoryImplementations

SIMapStepToSelector(@"Given the interface is up", givenTheInterfaceIsUp)
-(void) givenTheInterfaceIsUp {
	UILabel *firstViewLabel = SIFindView(@"UILabel[@text='First View']");
	
}

SIMapStepToSelector(@"Then I execute a log UI tree", executePrintUITree)
-(void) executePrintUITree {
}

SIMapStepToSelector(@"and it should execute on the main thread", executedOnMainThread)
-(void) executedOnMainThread {
}

SIMapStepToSelector(@"then I can switch to the second view", clickTheSecondView)
-(void) clickTheSecondView {
	
}

SIMapStepToSelector(@"and see the view", verifyTheViewIsVisible)
-(void) verifyTheViewIsVisible {
	SIPrintCurrentWindowTree();
}

@end
