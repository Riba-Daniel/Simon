//
//  JSONSerialisationTests.m
//  Simon
//
//  Created by Derek Clarkson on 26/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIStorySource.h>
#import <Simon/SIStory.h>
#import <Simon/SIStep.h>
#import <Simon/SIStepMapping.h>
#import <dUsefulStuff/DCCommon.h>

@interface JSONSerialisationTests : GHTestCase

@end

@implementation JSONSerialisationTests

-(void) testSerialisation {
	
	SIStepMapping *mapping = [[[SIStepMapping alloc] init] autorelease];
	mapping.selector = @selector(testSerialisation);
	mapping.targetClass = [self class];
	NSError *error = nil;
	mapping.regex = [[[NSRegularExpression alloc] initWithPattern:@"pattern" options:NSRegularExpressionCaseInsensitive error:&error] autorelease];
	
	SIStep *step = [[[SIStep alloc] initWithKeyword:SIKeywordGiven command:@"command"] autorelease];
	step.stepMapping = mapping;

	SIStory *story = [[[SIStory alloc] init] autorelease];
	story.title = @"title";
	story.steps = [NSArray arrayWithObjects:step, nil];
	
	SIStorySource *source = [[[SIStorySource alloc] init] autorelease];
	source.source = @"source";
	[source addStory:story];
	
	NSData *data = [NSJSONSerialization dataWithJSONObject:[source jsonDictionary] options:0 error:&error];
	
	DC_LOG(@"JSON: %@", DC_DATA_TO_STRING(data));
	
	GHAssertEqualStrings(DC_DATA_TO_STRING(data), @"{\"source\":\"source\",\"stories\":[{\"steps\":[{\"keyword\":3,\"command\":\"command\",\"executed\":false}],\"title\":\"title\",\"status\":4}]}", nil);
	
}

@end
