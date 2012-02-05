
//
//  StoryImplementations.m
//  Simon
//
//  Created by Derek Clarkson on 7/23/11.
//  Copyright 2011. All rights reserved.
//
#import "SISimon.h"

@interface StoryImplementations : NSObject {
}
@end

@implementation StoryImplementations

SIMapStepToSelector(@"Given the interface is up", givenTheInterfaceIsUp)
-(void) givenTheInterfaceIsUp {
   
   @try {
      // Verify we are on the first view.
      SIFindView(@"//UILabel[@text='First View']");
   }
   @catch (NSException *exception) {
      // Try switching to the first view and verify again.
      SITapTabBarButtonWithLabel(@"First");
      //SITapControl(@"//UITabBarButton[0]");
      SIFindView(@"//UILabel[@text='First View']");
   }
   
}

SIMapStepToSelector(@"Then I execute a log UI tree", executePrintUITree)
-(void) executePrintUITree {
   SIPrintCurrentWindowTree();
}

SIMapStepToSelector(@"and it should execute on the main thread", executedOnMainThread)
-(void) executedOnMainThread {
   //STAssertTrue([[NSThread currentThread] isMainThread], @"not on main thread");
}

SIMapStepToSelector(@"then I can switch to the second view", clickTheSecondView)
-(void) clickTheSecondView {
   SITapTabBarButtonWithLabel(@"Second");
}

SIMapStepToSelector(@"and see the view labelled (.*)", verifyTheViewIsVisible:)
-(void) verifyTheViewIsVisible:(NSString *) viewName {
   NSString *query = [NSString stringWithFormat:@"//UILabel[@text='%@']", viewName];
   SIFindView(query);
}

@end
