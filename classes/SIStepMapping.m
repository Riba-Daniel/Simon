//
//  SIClassSelector.m
//  Simon
//
//  Created by Derek Clarkson on 6/19/11.
//  Copyright 2011. All rights reserved.
//
#import <objc/runtime.h>

#import "SIStepMapping.h"
#import "NSObject+Utils.h"
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSobject+dUsefulStuff.h>
#import "SIConstants.h"

@interface SIStepMapping()
-(NSInvocation *) createInvocationForMethod:(Method) method;
-(BOOL) populateInvocationParameters:(NSInvocation *) invocation withMethod:(Method) method error:(NSError **) error;
-(BOOL) setValue:(NSString *) value 
			 ofType:(char) type 
	 onInvocation:(NSInvocation *) invocation 
		atArgIndex:(NSUInteger) index 
			  error:(NSError **) error;
-(NSError *) errorForException;
@end

@implementation SIStepMapping

@synthesize regex = regex_;
@synthesize selector = selector_;
@synthesize targetClass = targetClass_;
@synthesize executed = executed_;
@synthesize exception = exception_;
@synthesize command = command_;

-(id) init {
	self = [super init];
	if (self) {
		self.exception = nil;
	}
	return self;
}

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! HACK
// Static to tempoary store an exception so we can pass it from implementation code back to the mapping that is executing it. This will no longer be needed when Apple fixes NSInvocation.
static NSException * passedException = nil;
+(void) cacheException:(NSException *) exception {
	passedException = [exception retain];
}
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! HACK

+(SIStepMapping *) stepMappingWithClass:(Class) theClass selector:(SEL) aSelector regex:(NSString *) theRegex error:(NSError **) error {
	SIStepMapping * mapping = [[[SIStepMapping alloc] init] autorelease];
	mapping.targetClass = theClass;
	mapping.selector = aSelector;
	mapping.regex = [NSRegularExpression regularExpressionWithPattern:theRegex 
																				 options:NSRegularExpressionCaseInsensitive
																					error:error];
	if (mapping.regex == nil) {
		
		// Look for regular expression errors so we can provide a better message.
		if ([*error code] == 2048) {
			*error = [self errorForCode:SIErrorInvalidRegularExpression 
								 errorDomain:SIMON_ERROR_DOMAIN 
						  shortDescription:@"Invalid regular expression"
							  failureReason:
						 [NSString stringWithFormat:@"The passed regular expression \"%@\" is invalid.", theRegex]];
		} 
		return nil;
	}
	
	// Validate that the method exists.
	Method method = class_getInstanceMethod(theClass, aSelector);
	if (method == nil) {
		[self setError:error 
					 code:SIErrorUnknownSelector 
			errorDomain:SIMON_ERROR_DOMAIN 
	 shortDescription:@"Selector not found"
		 failureReason:[NSString stringWithFormat:@"The passed selector %@ was not found in class %@", NSStringFromSelector(aSelector), NSStringFromClass(theClass)]];
		return NO;
	}
	
	// Validate that the the regex's number of capture groups match the number of selector arguments.
	int nbrArgs = method_getNumberOfArguments(method) - 2;
	if ([mapping.regex numberOfCaptureGroups] != nbrArgs) {
		[self setError:error 
					 code:SIErrorRegularExpressionWillNotMatchSelector 
			errorDomain:SIMON_ERROR_DOMAIN 
	 shortDescription:@"Regular expression and selector mis-match."
		 failureReason:[NSString stringWithFormat:@"The passed regular expression \"%@\" has a different number of arguments to the selector %@"
							 , theRegex, NSStringFromSelector(aSelector)]];
		return nil;
	}	
	
	// Everything is good.
	return mapping;
}

-(BOOL) canMapToStep:(NSString *) step {
	NSRange rangeOfFirstMatch = [self.regex rangeOfFirstMatchInString:step options:0 range:NSMakeRange(0, [step length])];
	return ! NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0));
}

-(BOOL) invokeWithObject:(id) object error:(NSError **) error {
	
	// flag that we have been called.
	self.executed = YES;
	
	// Inject a reference to the step mapping so it can be accessed for data. Note we assign so we don't have 
	// to worry about retains. This is fine as the story will be around longer than the test class.
	objc_setAssociatedObject(object, SI_INSTANCE_STEP_MAPPING_REF_KEY, self, OBJC_ASSOCIATION_ASSIGN);
	
	// Create the invocation.
	Method method = class_getInstanceMethod(self.targetClass, self.selector);
	NSInvocation *invocation = [self createInvocationForMethod:method];
	if (![self populateInvocationParameters:invocation withMethod:method error:error]) {
		return NO;		
	}
	
	// No perform the invocation.
	DC_LOG(@"Invoking methods on class");
	
	@try {
		invocation.target = object;
		[invocation invoke];
	}
	@catch (NSException *thrownException) {
		self.exception = thrownException;
		DC_LOG(@"Caught exception: %@", [self.exception reason]);
		*error = [self errorForException];
		return NO;
	}
	
	// !!!!!!!!!!!!!!!!!!!!!!!!!!! Exception handling HACK.
	if (passedException != nil) {
		self.exception = passedException;
		*error = [self errorForException];
		DC_DEALLOC(passedException);
		return NO;
	}

	return YES;
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

-(NSInvocation *) createInvocationForMethod:(Method) method {
	DC_LOG(@"Creating invocation for %@::%@", NSStringFromClass(self.targetClass), NSStringFromSelector(self.selector));
	NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.selector = self.selector;
	return invocation;
}

-(BOOL) populateInvocationParameters:(NSInvocation *) invocation withMethod:(Method)method error:(NSError **) error {
	
	// Get the data values from the passed command.	
	NSArray *matches = [self.regex matchesInString:self.command options:0 range:NSMakeRange(0, [self.command length])];
	NSTextCheckingResult * match = [matches objectAtIndex:0];
	
	// Populate the invocation with the data from the command. Remember to allow for the first three
	// Arguments being the return type, class and selector.
	int nbrArgs = method_getNumberOfArguments(method) - 2;
	for (int i = 0; i < nbrArgs; i++) {
		
		// Values will be from regex groups after group 0 which is he complete match.
		NSString *value = [self.command substringWithRange:[match rangeAtIndex:i + 1]];
		DC_LOG(@"Adding value to invocation: %@", value);
		
		// This can probably be done better using the argument functions on the signature.
		char argType = *method_copyArgumentType(method, i + 2);
		if (![self setValue:value ofType:argType onInvocation:invocation atArgIndex:i + 2 error:error]) {
			return NO;
		}
	}
	
	return YES;
}

/**
 * Helper method which sorts out how to pass the value to the invocation.
 */
-(BOOL) setValue:(NSString *) value 
			 ofType:(char) type 
	 onInvocation:(NSInvocation *) invocation 
		atArgIndex:(NSUInteger) index 
			  error:(NSError **) error {
	
	DC_LOG(@"Arg type = %c", type);
	switch (type) {
		case 'C':
		case 'c': {
			// char, BOOL or boolean.
			// First check for Boolean values.
			NSString * upper = [value uppercaseString];
			if ([upper isEqualToString:@"YES"] 
				 || [upper isEqualToString:@"NO"]
				 || [upper isEqualToString:@"TRUE"]
				 || [upper isEqualToString:@"FALSE"]) {
				// It's a boolean value.
				BOOL boolValue = [value boolValue];
				[invocation setArgument:&boolValue atIndex:index];
			} else {
				// Its a char.
				char charValue = [value characterAtIndex:0];
				[invocation setArgument:&charValue atIndex:index];
			}
			break;
		}
		case 'i': {
			// Integer.
			int intValue = [value intValue];
			[invocation setArgument:&intValue atIndex:index];
			break;
		}
		case 'I': {
			// NSInteger
			NSInteger integerValue = [value integerValue];
			[invocation setArgument:&integerValue atIndex:index];
			break;
		}
		case 'd': {
			// double.
			double doubleValue = [value doubleValue];
			[invocation setArgument:&doubleValue atIndex:index];
			break;
		}
		case 'f': {
			// float.
			float floatValue = [value floatValue];
			[invocation setArgument:&floatValue atIndex:index];
			break;
		}
		case '@':
			// Object expected.
			[invocation setArgument:&value atIndex:index];
			break;
			
		default:
			[self setError:error 
						 code:SIErrorCannotConvertArgumentToType 
				errorDomain:SIMON_ERROR_DOMAIN 
		 shortDescription:[NSString stringWithFormat:@"Cannot handle selector %@, argument %i, type %c", NSStringFromSelector(self.selector), index - 2, type]
			 failureReason:[NSString stringWithFormat:@"Selector %@ has an argument type of %c at parameter %i, I cannot handle that type at this time.",
								 NSStringFromSelector(self.selector), type, index - 2]];
			return NO;
	}
	return YES;
}


-(void) dealloc {
	self.targetClass = nil;
	self.command = nil;
	self.regex = nil;
	self.selector = nil;
	self.exception = nil;
	[super dealloc];
}

@end


