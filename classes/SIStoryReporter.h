//
//  SIStoryReporter.h
//  Simon
//
//  Created by Derek Clarkson on 6/28/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 Classes which implement this protocol can be used to report on story runs.
 */
@protocol SIStoryReporter <NSObject>

/**
 This method is called after the run has finished. It is passed an NSArray of the SIStory objects that took part in the run. These objects contain all the information necessary to report on the run.
 
 @param storySources an NSArray containing the SIStorySource objects.
 @param mappings an NSArray containing all the SIStepMapping objects found by the SIRuntime class.
 */
-(void) reportOnStorySources:(NSArray *) sources andMappings:(NSArray *) mappings;

@end
