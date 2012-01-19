//
//  Simon.h
//  Simon
//
//  Created by Derek Clarkson on 6/18/11.
//  Copyright 2011. All rights reserved.
//
#import <dUsefulStuff/DCCommon.h>
#import <objc/runtime.h>

#import "SIMacros.h"
#import "SIConstants.h"
#import "SIStepMapping.h"
#import "SIStory.h"
#import "SIAppBackpack.h"
#import "SIUIUtils.h"
#import "SIUIViewHandler.h"
#import "SIUIHandlerFactory.h"
#import "UIView+Simon.h"

#pragma mark Internals
/**
 * The prefix used to start the method names for the step definition.
 */
#define SI_STEP_METHOD_PREFIX __stepMap

/**
 These two are used to convert a sequence of chars to a string constant. We used this to convert a selector to a string constant within a macro when part of the macro name is the current line number macro __LINE__. Again we need that extra level of indirection to fix the translation of the parameter when stringification is involved.
 */
#define toNSString(chars) _toNSString(chars)
#define _toNSString(chars) @#chars




