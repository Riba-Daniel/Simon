//
//  SIInAppReporter.m
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryInAppReporter.h"

@interface SIStoryInAppReporter()
-(void) displayReportOnStories:(NSArray *) stories andMappings:(NSArray *) mappings;
@end


@implementation SIStoryInAppReporter

-(void) reportOnStories:(NSArray *) stories andMappings:(NSArray *) mappings {
	// Refire on the main thread.
	dispatch_queue_t mainQ = dispatch_get_main_queue();
	dispatch_async(mainQ, ^{
		[self displayReportOnStories:stories andMappings:mappings];
	});

}

-(void) displayReportOnStories:(NSArray *) stories andMappings:(NSArray *) mappings {
	
}

@end
