
#import "SISimon.h"
#import <Simon-core/NSString+Simon.h>

@interface MacroStoryImplementations : NSObject {
	BOOL gotThere;
}
@end

@implementation MacroStoryImplementations

SIMapStepToSelector(@"reset test flags", setUp);
-(void) setUp {
   gotThere = NO;
}

SIMapStepToSelector(@"check the flags", checkFlags);
-(void) checkFlags {
	SIAssertTrue(gotThere);
}

SIMapStepToSelector(@"call the SIFail macro$", doSIFail);
-(void) doSIFail {
	@try {
		SIFail();
	}
	@catch (NSException *e) {
		SIAssertObjectEquals(@"-[MacroStoryImplementations doSIFail](25) SIFail executed, throwing failure exception.", e.reason);
	}
}

SIMapStepToSelector(@"call the SIFail macro with a message", doSIFailWithMessage);
-(void) doSIFailWithMessage {
   @try {
      SIFailM(@"Hello this is the SIFailM macro");
      SIFail();
   }
   @catch (NSException *e) {
      SIAssertObjectEquals(@"-[MacroStoryImplementations doSIFailWithMessage](35) Hello this is the SIFailM macro", e.reason);
   }
   
}

SIMapStepToSelector(@"calling SIAssertNil with nil should work", doSIAssertNilShouldPassNilOk);
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
