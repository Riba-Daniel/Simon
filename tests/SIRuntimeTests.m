
#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>
#import <Simon/SIStoryRunner.h>
#import <Simon/SIRuntime.h>
#import <Simon/SIStepMapping.h>


@interface SIRuntimeTests : GHTestCase {
@private
}
@end

@implementation SIRuntimeTests

-(void) testFindsAllMappings {
	
	SIRuntime * runtime = [[[SIRuntime alloc] init] autorelease];
	NSArray * mappings = [runtime allMappingMethodsInRuntime];

	GHAssertEquals([mappings count], (NSUInteger)3, @"incorrect number of classes returned");

}

@end