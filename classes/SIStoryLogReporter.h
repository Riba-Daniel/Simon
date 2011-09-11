//
//  SIStoryLogReporter.h
//  Simon
//
//  Created by Derek Clarkson on 6/28/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIStoryReporter.h"

/**
 An instance of the SIStoryReporter protocol that logs a report to the console via NSLog(...) commands.
 */
@interface SIStoryLogReporter : NSObject<SIStoryReporter>

@end
