//
//  Step.m
//  Simon
//
//  Created by Derek Clarkson on 5/30/11.
//  Copyright 2011. All rights reserved.
//

#import <Simon/SIStep.h>
#import <dUsefulStuff/DCCommon.h>
#import "NSString+Simon.h"
#import <dUsefulStuff/NSObject+dUsefulStuff.h>

@interface SIStep()
-(NSError *) errorForException;
@end

@implementation SIStep

@synthesize keyword = _keyword;
@synthesize command = _command;
@synthesize stepMapping = _stepMapping;
@synthesize exception = _exception;
@synthesize executed = _executed;

-(void) dealloc {
	self.command = nil;
	self.stepMapping = nil;
	self.exception = nil;
	[super dealloc];
}

-(id) initWithKeyword:(SIKeyword) aKeyword command:(NSString *) theCommand {
	self = [super init];
	if (self) {
		_keyword = aKeyword;
		self.command = theCommand;
		[self reset];
	}
	return self;
}

-(id) initWithJsonDictionary:(NSDictionary *) data {
	self = [super init];
	if (self) {
		[self setValuesForKeysWithDictionary:data];
	}
	return self;
}

- (void)setNilValueForKey:(NSString *)key {
	[super setNilValueForKey:key];
}

-(void) setValue:(id)value forKeyPath:(NSString *)keyPath {
	[super setValue:value forKeyPath:keyPath];
}

-(void) setValue:(id)value forKey:(NSString *)key {
	if ([key isEqualToString:@"exception"]) {
		NSDictionary *dataDic = (NSDictionary *) value;
		self.exception = [NSException exceptionWithName:[dataDic valueForKey:@"name"] reason:[dataDic valueForKey:@"reason"] userInfo:nil];
	} else {
		[super setValue:value forKey:key];
	}
}

-(void) findMappingInList:(NSArray *) mappings {
	for (SIStepMapping * mapping in mappings) {
		if ([mapping canMapToStep:self.command]) {
			DC_LOG(@"Found mapping for step %@::%@ -> %@", NSStringFromClass(mapping.targetClass), NSStringFromSelector(mapping.selector),self.command);
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
		self.executed = YES;
		BOOL success = [self.stepMapping invokeWithCommand:self.command object:object error:error];
		return success;
	}
	@catch (NSException *thrownException) {
		self.exception = thrownException;
		DC_LOG(@"Caught exception: %@", [self.exception reason]);
		*error = [self errorForException];
		return NO;
	}
}

-(void) reset {
	DC_LOG(@"Resetting");
	self.executed = NO;
	self.exception = nil;
	[self.stepMapping reset];
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

-(NSDictionary *) jsonDictionary {
	return [self dictionaryWithValuesForKeys:@[@"keyword", @"command", @"executed", @"exception"]];
}

-(id) valueForKey:(NSString *)key {
	if ([key isEqualToString:@"exception"]) {
		return [self.exception dictionaryWithValuesForKeys:@[@"name", @"reason"]];
	}
	return [super valueForKey:key];
}

@end
