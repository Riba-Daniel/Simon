//
//  PIReporter.h
//  Simon
//
//  Created by Derek Clarkson on 8/10/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIStory.h>
#import <Simon/SIFinalReport.h>

#define PI_STORY_FINISHED_NOTIFICATION @"PISimonStoryFinished"
#define PI_RUN_FINISHED_NOTIFICATION @"PISimonRunFinished"

#define PI_USERINFO_KEY_STORY @"story"
#define PI_USERINFO_KEY_RESULTS @"results"

/**
 All classes which want to report on results from Simon should extend this class. Simply create an instance of your class to exanble the reporting to occur.
*/

@interface PIReporter : NSObject

/**
 Called when a test result is received from Simon.
 
 @param story the story that was just executed.
 */
-(void) storyFinished:(SIStory *) story;

/**
 Called after all tests have been run.
 */
-(void) runFinished:(SIFinalReport *) report;


@end
