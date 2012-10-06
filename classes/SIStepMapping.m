//
//  SIClassSelector.m
//  Simon
//
//  Created by Derek Clarkson on 6/19/11.
//  Copyright 2011. All rights reserved.
//
#import <objc/runtime.h>

#import <Simon/SIStepMapping.h>
#import "NSString+Simon.h"
#import <dUsefulStuff/DCCommon.h>
#import <dUsefulStuff/NSObject+dUsefulStuff.h>
#import <Simon/SIConstants.h>

@interface SIStepMapping()
-(NSInvocation *) createInvocationForMethod:(Method) method withCommand:(NSString *) command;
-(BOOL) populateInvocationParameters:(NSInvocation *) invocation 
								  withMethod:(Method) method 
									  command:(NSString *) command 
										 error:(NSError **) error;
-(BOOL) setValue:(NSString *) value 
			 ofType:(char) type 
	 onInvocation:(NSInvocation *) invocation 
		atArgIndex:(NSInteger) index
			  error:(NSError **) error;
@end

@implementation SIStepMapping

@synthesize regex = regex_;
@synthesize selector = selector_;
@synthesize targetClass = targetClass_;
@synthesize mapped = mapped_;

-(void) dealloc {
	self.targetClass = nil;
	self.regex = nil;
	self.selector = nil;
	[super dealloc];
}

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
	unsigned int nbrArgs = method_getNumberOfArguments(method) - 2;
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
	BOOL canMap = ! DC_EQUALS_NOT_FOUND_RANGE(rangeOfFirstMatch);
	if (canMap) {
		self.mapped = YES;
	}
	return canMap;
}

-(BOOL) invokeWithCommand:(NSString *) command object:(id) object error:(NSError **) error {
	
	// Inject a reference to the step mapping so it can be accessed for data. Note we assign so we don't have 
	// to worry about retains. This is fine as the story will be around longer than the test class.
	objc_setAssociatedObject(object, SI_INSTANCE_STEP_MAPPING_REF_KEY, self, OBJC_ASSOCIATION_ASSIGN);
	
	// Create the invocation.
	Method method = class_getInstanceMethod(self.targetClass, self.selector);
	NSInvocation *invocation = [self createInvocationForMethod:method withCommand:command];
	if (![self populateInvocationParameters:invocation 
										  withMethod:method 
											  command:command 
												 error:error]) {
		return NO;		
	}
	
	// Now perform the invocation.
	DC_LOG(@"Invoking methods on class");
	invocation.target = object;
	[invocation invoke];
	return YES;
}

-(void) reset {
	DC_LOG(@"Resetting");
	// Nothing doing at this time.
}

-(NSInvocation *) createInvocationForMethod:(Method) method 
										  withCommand:(NSString *) command {
	DC_LOG(@"Creating invocation for %@::%@", NSStringFromClass(self.targetClass), NSStringFromSelector(self.selector));
	NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.selector = self.selector;
	return invocation;
}

-(BOOL) populateInvocationParameters:(NSInvocation *) invocation 
								  withMethod:(Method)method  
									  command:(NSString *) command 
										 error:(NSError **) error {
	
	// Get the data values from the passed command.	
	NSArray *matches = [self.regex matchesInString:command options:0 range:NSMakeRange(0, [command length])];
	NSTextCheckingResult * match = [matches objectAtIndex:0];
	
	// Populate the invocation with the data from the command. Remember to allow for the first three
	// Arguments being the return type, class and selector.
	NSInteger nbrArgs = (NSInteger)method_getNumberOfArguments(method) - 2;
	for (NSInteger i = 0; i < nbrArgs; i++) {
		
		// Values will be from regex groups after group 0 which is he complete match.
		NSString *value = [command substringWithRange:[match rangeAtIndex:(NSUInteger)i + 1]];
		DC_LOG(@"Adding value to invocation: %@", value);
		
		// This can probably be done better using the argument functions on the signature.
		char argType = *method_copyArgumentType(method, (unsigned)i + 2);
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
		atArgIndex:(NSInteger) index 
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
				unichar charValue = [value characterAtIndex:0];
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
		 shortDescription:[NSString stringWithFormat:@"Cannot handle selector %@, argument %li, type %c", NSStringFromSelector(self.selector), (long)index - 2, type]
			 failureReason:[NSString stringWithFormat:@"Selector %@ has an argument type of %c at parameter %li, I cannot handle that type at this time.",
								 NSStringFromSelector(self.selector), type, (long)index - 2]];
			return NO;
	}
	return YES;
}

@end


