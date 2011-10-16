
#import "SISimon.h"
#import "NSString+Simon.h"

@interface MacroStoryImplementations : NSObject {
	BOOL gotThere;
}
@end

@implementation MacroStoryImplementations

SIMapStepToSelector(@"reset test flags", setUp)
-(void) setUp {
	gotThere = NO;
}

SIMapStepToSelector(@"check the flags", checkFlags)
-(void) checkFlags {
	SIAssertTrue(gotThere, nil);
}


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
		// Get the step mapping from the associated object storage.
		SIStepMapping *mapping = (SIStepMapping *)objc_getAssociatedObject(self, SI_INSTANCE_STEP_MAPPING_REF_KEY);
		// Check the step mapping for an exception.	
		SIAssertNotNil(mapping, nil);
		
		// Clear the static exception that the fail would have created.
		[SIStepMapping cacheException:nil];
	}
}

SIMapStepToSelector(@"calling SIAssertNil with nil should work", doSIAssertNilShouldPassNilOk)
-(void) doSIAssertNilShouldPassNilOk {
	@try {
		SIAssertNil(nil, nil);
		// This is good.
		gotThere = YES;
	}
	@finally {
		if (! gotThere) {
			SIFail(@"Should not have got to here");
		}
	}
}

@end
