
#import "SISimon.h"

@interface MacroStoryImplementations : NSObject {
}
@end

@implementation MacroStoryImplementations

SIMapStepToSelector(@"call the SIFail macro", doSIFail)
-(void) doSIFail {
	SIFail(@"SIFail triggered exception");
}

SIMapStepToSelector(@"check that the exception was recorded", checkSIFailWorked)
-(void) checkSIFailWorked {
}

@end
