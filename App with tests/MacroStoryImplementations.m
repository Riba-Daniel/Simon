
#import "SISimon.h"

@interface MacroStoryImplementations : NSObject {
}
@end

@implementation MacroStoryImplementations

SIMapStepToSelector(@"call the SIFail macro", doSIFail)
-(void) doSIFail {
	@try {
		SIFail(nil);
	}
	@finally {
		// Get the step mapping.
		SIStepMapping *mapping = (SIStepMapping *)objc_getAssociatedObject(self, SI_INSTANCE_STEP_MAPPING_REF_KEY);
		// Check the step mapping for an exception.	
		SIAssertNotNil(mapping, nil);
		
		// Clear the static exception that the fail would have created.
		[SIStepMapping cacheException:nil];
	}
}

SIMapStepToSelector(@"call the SIFail macro with a message", doSIFailWithMessage)
-(void) doSIFailWithMessage {
	@try {
		SIFail(@"This is the message and value: %@", @"abc");
	}
	@finally {
		// Get the step mapping.
		SIStepMapping *mapping = (SIStepMapping *)objc_getAssociatedObject(self, SI_INSTANCE_STEP_MAPPING_REF_KEY);
		// Check the step mapping for an exception.	
		SIAssertNotNil(mapping, nil);
		
		// Clear the static exception that the fail would have created.
		[SIStepMapping cacheException:nil];
	}
}

@end
