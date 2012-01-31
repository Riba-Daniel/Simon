
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
	SIAssertTrue(gotThere);
}


SIMapStepToSelector(@"call the SIFail macro", doSIFail)
-(void) doSIFail {
	@try {
		SIFail();
	}
	@finally {
		// Get the step mapping.
		SIStepMapping *mapping = (SIStepMapping *)objc_getAssociatedObject(self, SI_INSTANCE_STEP_MAPPING_REF_KEY);
		// Check the step mapping for an exception.	
		SIAssertNotNil(mapping);
		
	}
}

SIMapStepToSelector(@"call the SIFail macro with a message", doSIFailWithMessage)
-(void) doSIFailWithMessage {
	@try {
		SIFailM(@"Hello this is the SIFailM macro");
	}
	@finally {
		// Get the step mapping from the associated object storage.
      
		SIStepMapping *mapping = SIRetrieveFromStory(SI_INSTANCE_STEP_MAPPING_REF_KEY); 
      //= (SIStepMapping *)objc_getAssociatedObject(self, SI_INSTANCE_STEP_MAPPING_REF_KEY);
      
		// Check the step mapping for an exception.	
		SIAssertNotNil(mapping);
      SIAssertNotNil(mapping.exception);
      SIAssertObjectEquals(mapping.exception, @"");
      
      // Clear the exception so we don't fail the test.
      mapping.exception = nil;
   }
}

SIMapStepToSelector(@"calling SIAssertNil with nil should work", doSIAssertNilShouldPassNilOk)
-(void) doSIAssertNilShouldPassNilOk {
	@try {
		SIAssertNil(nil);
		// This is good.
		gotThere = YES;
	}
	@finally {
		if (! gotThere) {
			SIFail();
		}
	}
}

@end
