
#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import "SIStoryRunner.h"
#import "SIRuntime.h"
#import "SIStepMapping.h"


@interface SIRuntimeTests : GHTestCase {
@private
}
@end

@implementation SIRuntimeTests

-(void) testFindsAllMappings {
	
	SIRuntime * runtime = [[[SIRuntime alloc] init] autorelease];
	NSArray * mappings = [runtime allMappingMethodsInRuntime];

	GHAssertEquals([mappings count], (NSUInteger)6, @"incorrect number of classes returned");

}

@end