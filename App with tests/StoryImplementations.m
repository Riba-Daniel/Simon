
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
   
   NSError *error = nil;
   
   UILabel *firstViewLabel = (UILabel *) SIFindView(@"//UILabel[@text='First View']", &error);
   
   // If the first view is not found, click the tab for it and try again.
   if (firstViewLabel == nil) {

      // Reset error and tap the first view tab.
      error = nil;
      SITapControl(@"//UITabBarButton[0]", &error);
      firstViewLabel = (UILabel *) SIFindView(@"//UILabel[@text='First View']", &error);
      
      // Still not visible so exit.
      if (firstViewLabel == nil) {
         SIFailM(@"Error: %@", [error localizedFailureReason]);
      }
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
   SIPrintCurrentWindowTree();
   NSError *error = nil;
   SITapControl(@"//UITabBarButton[1]", &error);
}

SIMapStepToSelector(@"and see the view labelled (.*)", verifyTheViewIsVisible:)
-(void) verifyTheViewIsVisible:(NSString *) viewName {
   NSError *error = nil;
   NSString *query = [NSString stringWithFormat:@"//UILabel[@text='%@']", viewName];
   UILabel *firstViewLabel = (UILabel *) SIFindView(query, &error);
   if (firstViewLabel == nil) {
      SIFailM(@"Error: %@", [error localizedFailureReason]);
   }
}

@end
