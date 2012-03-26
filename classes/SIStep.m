//
//  Step.m
//  Simon
//
//  Created by Derek Clarkson on 5/30/11.
//  Copyright 2011. All rights reserved.
//

#import "SIStep.h"
#import <dUsefulStuff/DCCommon.h>
#import "NSString+Simon.h"
#import <dUsefulStuff/NSObject+dUsefulStuff.h>

@interface SIStep()
-(NSError *) errorForException;
@end

@implementation SIStep

@synthesize keyword = keyword_;
@synthesize command = command_;
@synthesize stepMapping = stepMapping_;
@synthesize exception = exception_;
@synthesize executed = executed_;

-(void) dealloc {
	self.command = nil;
	self.stepMapping = nil;
	self.exception = nil;
	[super dealloc];
}

-(id) initWithKeyword:(SIKeyword) aKeyword command:(NSString *) theCommand {
	self = [super init];
	if (self) {
		keyword_ = aKeyword;
		self.command = theCommand;
	}
	return self;
}

-(void) findMappingInList:(NSArray *) mappings {
	for (SIStepMapping * mapping in mappings) {
		if ([mapping canMapToStep:self.command]) {
			DC_LOG(@"Found mapping for step %@", self.command);
			self.stepMapping = mapping;
			return;
		}
	}
}

-(BOOL) isMapped {
	return self.stepMapping != nil;
}

-(BOOL) invokeWithObject:(id) object error:(NSError **) error {
	@try {
		BOOL success = [self.stepMapping invokeWithCommand:self.command object:object error:error];
		self.executed = YES;
		return success;
	}
	@catch (NSException *thrownException) {
		self.exception = thrownException;
		DC_LOG(@"Caught exception: %@", [self.exception reason]);
		*error = [self errorForException];
		return NO;
	}
}

-(NSError *) errorForException {
	
	if ([self.exception.name isEqualToString:@"NSUnknownKeyException"]) {
		return [self errorForCode:SIErrorUnknownProperty 
						  errorDomain:SIMON_ERROR_DOMAIN 
					shortDescription:@"Unknown property" 
						failureReason:[NSString stringWithFormat:@"Unknown property: %@",[self.exception reason]]];
	} 
	return [self errorForCode:SIErrorExceptionCaught 
					  errorDomain:SIMON_ERROR_DOMAIN 
				shortDescription:@"Exception caught"
					failureReason:[NSString stringWithFormat:@"Exception caught: %@",[self.exception reason]]];
}


@end
