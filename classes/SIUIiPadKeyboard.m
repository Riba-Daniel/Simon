//
//  SIUIiPadKeyboard.m
//  Simon
//
//  Created by Derek Clarkson on 17/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIUIiPadKeyboard.h"

// Contains the types of keys.
typedef enum {
	SIUIKeyboardKeyTypeNormal, // Normal keys.
	SIUIKeyboardKeyTypeBackspace,
	SIUIKeyboardKeyTypeShiftLeft, // Up arrow, 123, #+=
	SIUIKeyboardKeyTypeShiftRight, // Up arrow, 123, #+=
	SIUIKeyboardKeyTypeSearch,
	SIUIKeyboardKeyTypeUndo,
	SIUIKeyboardKeyTypeRedo,
	SIUIKeyboardKeyTypeHide,
	SIUIKeyboardKeyTypeAlphaNumericSwitchLeft, // ABC, .?123
	SIUIKeyboardKeyTypeAlphaNumericSwitchRight // ABC, .?123
} SIUIKeyboardKeyType;

// Used to control state of the state engine and decide how to change.
typedef enum {
	SIUIKeyboardStateNormal = 1 << 0,
	SIUIKeyboardStateNumeric = 1 << 1,
	SIUIKeyboardStateSymbol = 1 << 2
} SIUIKeyboardState;

// Defines all aspects of a key on the keyboard.
typedef struct {
	SIUIKeyboardKeyType keyType;
	unichar character;
	BOOL shifted;
	SIUIKeyboardState state;
	int portraitX;
	int portraitY;
	int landscapeX;
	int landscapeY;
} key;

// Defines the rules for state changes.
typedef struct {
	SIUIKeyboardState fromState;
	SIUIKeyboardState toState;
	int sequence[];
} stateChange;

#define KEY_ARRAY_LENGTH 106

// Portrait vertical centers.
#define ROW_1_PVC 36
#define ROW_2_PVC 100
#define ROW_3_PVC 164
#define ROW_4_PVC 228

// Portrait horizontal centers.
#define PR1K1 35
#define PR1K2 104
#define PR1K3 173
#define PR1K4 243
#define PR1K5 313
#define PR1K6 383
#define PR1K7 453
#define PR1K8 522
#define PR1K9 590
#define PR1K10 660
#define PR1K11 732

#define PR2K1 64
#define PR2K2 134
#define PR2K3 204
#define PR2K4 274
#define PR2K5 344
#define PR2K6 414
#define PR2K7 478
#define PR2K8 546
#define PR2K9 614
#define PR2K10 710

#define PR3K1 35
#define PR3K2 102
#define PR3K3 172
#define PR3K4 237
#define PR3K5 306
#define PR3K6 373
#define PR3K7 442
#define PR3K8 509
#define PR3K9 577
#define PR3K10 646
#define PR3K11 723

// Undo/redo
#define PR3K12 139

#define PR4K1 102
#define PR4K2 419
#define PR4K3 657
#define PR4K4 734


// Landscape vertical centers.
#define ROW_1_LVC 48
#define ROW_2_LVC 134
#define ROW_3_LVC 220
#define ROW_4_LVC 306

// Landscape horizontal centers.
#define LR1K1 48
#define LR1K2 141
#define LR1K3 233
#define LR1K4 326
#define LR1K5 419
#define LR1K6 512
#define LR1K7 605
#define LR1K8 697
#define LR1K9 790
#define LR1K10 883
#define LR1K11 977

#define LR2K1 84
#define LR2K2 176
#define LR2K3 268
#define LR2K4 360
#define LR2K5 452
#define LR2K6 545
#define LR2K7 636
#define LR2K8 727
#define LR2K9 820
#define LR2K10 948

#define LR3K1 48
#define LR3K2 138
#define LR3K3 228
#define LR3K4 319
#define LR3K5 409
#define LR3K6 499
#define LR3K7 589
#define LR3K8 680
#define LR3K9 770
#define LR3K10 861
#define LR3K11 966

// Undo/redo
#define LR3K12 184

#define LR4K1 138
#define LR4K2 555
#define LR4K3 874
#define LR4K4 979

@interface SIUIiPadKeyboard (_private)
@end

@implementation SIUIiPadKeyboard

static key keyData[KEY_ARRAY_LENGTH] = {
	{SIUIKeyboardKeyTypeNormal, 'a', NO, SIUIKeyboardStateNormal, PR2K1, ROW_2_PVC, LR2K1, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'b', NO, SIUIKeyboardStateNormal, PR3K6, ROW_3_PVC, LR3K6, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'c', NO, SIUIKeyboardStateNormal, PR3K4, ROW_3_PVC, LR3K4, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'd', NO, SIUIKeyboardStateNormal, PR2K3, ROW_2_PVC, LR2K3, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'e', NO, SIUIKeyboardStateNormal, PR1K3, ROW_1_PVC, LR1K3, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'f', NO, SIUIKeyboardStateNormal, PR2K4, ROW_2_PVC, LR2K4, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'g', NO, SIUIKeyboardStateNormal, PR2K5, ROW_2_PVC, LR2K5, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'h', NO, SIUIKeyboardStateNormal, PR2K6, ROW_2_PVC, LR2K6, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'i', NO, SIUIKeyboardStateNormal, PR1K8, ROW_1_PVC, LR1K8, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'j', NO, SIUIKeyboardStateNormal, PR2K7, ROW_2_PVC, LR2K7, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'k', NO, SIUIKeyboardStateNormal, PR2K8, ROW_2_PVC, LR2K8, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'l', NO, SIUIKeyboardStateNormal, PR2K9, ROW_2_PVC, LR2K9, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'm', NO, SIUIKeyboardStateNormal, PR3K8, ROW_3_PVC, LR3K8, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'n', NO, SIUIKeyboardStateNormal, PR3K7, ROW_3_PVC, LR3K7, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'o', NO, SIUIKeyboardStateNormal, PR1K9, ROW_1_PVC, LR1K9, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'p', NO, SIUIKeyboardStateNormal, PR1K10, ROW_1_PVC, LR1K10, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'q', NO, SIUIKeyboardStateNormal, PR1K1, ROW_1_PVC, LR1K1, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'r', NO, SIUIKeyboardStateNormal, PR1K4, ROW_1_PVC, LR1K4, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 's', NO, SIUIKeyboardStateNormal, PR2K2, ROW_2_PVC, LR2K2, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 't', NO, SIUIKeyboardStateNormal, PR1K5, ROW_1_PVC, LR1K5, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'u', NO, SIUIKeyboardStateNormal, PR1K7, ROW_1_PVC, LR1K7, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'v', NO, SIUIKeyboardStateNormal, PR3K5, ROW_3_PVC, LR3K5, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'w', NO, SIUIKeyboardStateNormal, PR1K2, ROW_1_PVC, LR1K2, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'x', NO, SIUIKeyboardStateNormal, PR3K3, ROW_3_PVC, LR3K3, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'y', NO, SIUIKeyboardStateNormal, PR1K6, ROW_1_PVC, LR1K6, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'z', NO, SIUIKeyboardStateNormal, PR3K2, ROW_3_PVC, LR3K2, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'A', YES, SIUIKeyboardStateNormal, PR2K1, ROW_2_PVC, LR2K1, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'B', YES, SIUIKeyboardStateNormal, PR3K6, ROW_3_PVC, LR3K6, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'C', YES, SIUIKeyboardStateNormal, PR3K4, ROW_3_PVC, LR3K4, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'D', YES, SIUIKeyboardStateNormal, PR2K3, ROW_2_PVC, LR2K3, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'E', YES, SIUIKeyboardStateNormal, PR1K3, ROW_1_PVC, LR1K3, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'F', YES, SIUIKeyboardStateNormal, PR2K4, ROW_2_PVC, LR2K4, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'G', YES, SIUIKeyboardStateNormal, PR2K5, ROW_2_PVC, LR2K5, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'H', YES, SIUIKeyboardStateNormal, PR2K6, ROW_2_PVC, LR2K6, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'I', YES, SIUIKeyboardStateNormal, PR1K8, ROW_1_PVC, LR1K8, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'J', YES, SIUIKeyboardStateNormal, PR2K7, ROW_2_PVC, LR2K7, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'K', YES, SIUIKeyboardStateNormal, PR2K8, ROW_2_PVC, LR2K8, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'L', YES, SIUIKeyboardStateNormal, PR2K9, ROW_2_PVC, LR2K9, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'M', YES, SIUIKeyboardStateNormal, PR3K8, ROW_3_PVC, LR3K8, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'N', YES, SIUIKeyboardStateNormal, PR3K7, ROW_3_PVC, LR3K7, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'O', YES, SIUIKeyboardStateNormal, PR1K9, ROW_1_PVC, LR1K9, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'P', YES, SIUIKeyboardStateNormal, PR1K10, ROW_1_PVC, LR1K10, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'Q', YES, SIUIKeyboardStateNormal, PR1K1, ROW_1_PVC, LR1K1, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'R', YES, SIUIKeyboardStateNormal, PR1K4, ROW_1_PVC, LR1K4, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'S', YES, SIUIKeyboardStateNormal, PR2K2, ROW_2_PVC, LR2K2, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 'T', YES, SIUIKeyboardStateNormal, PR1K5, ROW_1_PVC, LR1K5, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'U', YES, SIUIKeyboardStateNormal, PR1K7, ROW_1_PVC, LR1K7, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'V', YES, SIUIKeyboardStateNormal, PR3K5, ROW_3_PVC, LR3K5, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'W', YES, SIUIKeyboardStateNormal, PR1K2, ROW_1_PVC, LR1K2, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'X', YES, SIUIKeyboardStateNormal, PR3K3, ROW_3_PVC, LR3K3, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, 'Y', YES, SIUIKeyboardStateNormal, PR1K6, ROW_1_PVC, LR1K6, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, 'Z', YES, SIUIKeyboardStateNormal, PR3K2, ROW_3_PVC, LR3K2, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, '0', NO, SIUIKeyboardStateNumeric, PR1K10, ROW_1_PVC, LR1K10, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '1', NO, SIUIKeyboardStateNumeric, PR1K1, ROW_1_PVC, LR1K1, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '2', NO, SIUIKeyboardStateNumeric, PR1K2, ROW_1_PVC, LR1K2, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '3', NO, SIUIKeyboardStateNumeric, PR1K3, ROW_1_PVC, LR1K3, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '4', NO, SIUIKeyboardStateNumeric, PR1K4, ROW_1_PVC, LR1K4, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '5', NO, SIUIKeyboardStateNumeric, PR1K5, ROW_1_PVC, LR1K5, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '6', NO, SIUIKeyboardStateNumeric, PR1K6, ROW_1_PVC, LR1K6, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '7', NO, SIUIKeyboardStateNumeric, PR1K7, ROW_1_PVC, LR1K7, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '8', NO, SIUIKeyboardStateNumeric, PR1K8, ROW_1_PVC, LR1K8, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '9', NO, SIUIKeyboardStateNumeric, PR1K9, ROW_1_PVC, LR1K9, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, ',', NO, SIUIKeyboardStateNumeric, PR3K5, ROW_3_PVC, LR3K5, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, '.', NO, SIUIKeyboardStateNumeric, PR3K4, ROW_3_PVC, LR3K4, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, '!', NO, SIUIKeyboardStateNumeric, PR3K7, ROW_3_PVC, LR3K7, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, '?', NO, SIUIKeyboardStateNumeric, PR3K6, ROW_3_PVC, LR3K6, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, '-', NO, SIUIKeyboardStateNumeric, PR2K1, ROW_2_PVC, LR2K1, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '/', NO, SIUIKeyboardStateNumeric, PR2K2, ROW_2_PVC, LR2K2, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, ':', NO, SIUIKeyboardStateNumeric, PR2K3, ROW_2_PVC, LR2K3, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, ';', NO, SIUIKeyboardStateNumeric, PR2K4, ROW_2_PVC, LR2K4, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '(', NO, SIUIKeyboardStateNumeric, PR2K5, ROW_2_PVC, LR2K5, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, ')', NO, SIUIKeyboardStateNumeric, PR2K6, ROW_2_PVC, LR2K6, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '$', NO, SIUIKeyboardStateNumeric, PR2K7, ROW_2_PVC, LR2K7, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '&', NO, SIUIKeyboardStateNumeric, PR2K8, ROW_2_PVC, LR2K8, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '@', NO, SIUIKeyboardStateNumeric, PR2K9, ROW_2_PVC, LR2K9, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '\'', NO, SIUIKeyboardStateSymbol, PR3K8, ROW_3_PVC, LR3K8, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, '\"', NO, SIUIKeyboardStateSymbol, PR3K9, ROW_3_PVC, LR3K9, ROW_3_LVC},
	{SIUIKeyboardKeyTypeNormal, '[', NO, SIUIKeyboardStateSymbol, PR1K1, ROW_1_PVC, LR1K1, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, ']', NO, SIUIKeyboardStateSymbol, PR1K2, ROW_1_PVC, LR1K2, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '{', NO, SIUIKeyboardStateSymbol, PR1K3, ROW_1_PVC, LR1K3, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '}', NO, SIUIKeyboardStateSymbol, PR1K4, ROW_1_PVC, LR1K4, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '#', NO, SIUIKeyboardStateSymbol, PR1K5, ROW_1_PVC, LR1K5, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '%', NO, SIUIKeyboardStateSymbol, PR1K6, ROW_1_PVC, LR1K6, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '^', NO, SIUIKeyboardStateSymbol, PR1K7, ROW_1_PVC, LR1K7, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '*', NO, SIUIKeyboardStateSymbol, PR1K8, ROW_1_PVC, LR1K8, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '+', NO, SIUIKeyboardStateSymbol, PR1K9, ROW_1_PVC, LR1K9, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '=', NO, SIUIKeyboardStateSymbol, PR1K10, ROW_1_PVC, LR1K10, ROW_1_LVC},
	{SIUIKeyboardKeyTypeNormal, '_', NO, SIUIKeyboardStateSymbol, PR2K1, ROW_2_PVC, LR2K1, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '\\', NO, SIUIKeyboardStateSymbol, PR2K2, ROW_2_PVC, LR2K2, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '|', NO, SIUIKeyboardStateSymbol, PR2K3, ROW_2_PVC, LR2K3, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '~', NO, SIUIKeyboardStateSymbol, PR2K4, ROW_2_PVC, LR2K4, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '<', NO, SIUIKeyboardStateSymbol, PR2K5, ROW_2_PVC, LR2K5, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, '>', NO, SIUIKeyboardStateSymbol, PR2K6, ROW_2_PVC, LR2K6, ROW_2_LVC},
	{SIUIKeyboardKeyTypeNormal, 0x20AC, SIUIKeyboardStateSymbol, PR2K7, ROW_2_PVC, LR2K7, ROW_2_LVC}, // €
	{SIUIKeyboardKeyTypeNormal, 0x00A3, SIUIKeyboardStateSymbol, PR2K8, ROW_2_PVC, LR2K8, ROW_2_LVC}, // £
	{SIUIKeyboardKeyTypeNormal, 0x00A5, SIUIKeyboardStateSymbol, PR2K9, ROW_2_PVC, LR2K9, ROW_2_LVC}, // ¥
	{SIUIKeyboardKeyTypeNormal, ' ', NO, SIUIKeyboardStateNormal, PR4K2, ROW_4_PVC, LR4K2, ROW_4_LVC}, // space bar
	{SIUIKeyboardKeyTypeBackspace, ' ', NO, SIUIKeyboardStateNormal, PR1K11, ROW_1_PVC, LR1K11, ROW_1_LVC},
	{SIUIKeyboardKeyTypeSearch, ' ', NO, SIUIKeyboardStateNormal, PR2K10, ROW_2_PVC, LR2K10, ROW_2_LVC},
	{SIUIKeyboardKeyTypeHide, ' ', NO, SIUIKeyboardStateNormal, PR4K4, ROW_4_PVC, LR4K4, ROW_4_LVC},
	{SIUIKeyboardKeyTypeShiftLeft, ' ', NO, SIUIKeyboardStateNormal, PR3K1, ROW_3_PVC, LR3K1, ROW_3_LVC}, // Index 100
	{SIUIKeyboardKeyTypeShiftRight, ' ', NO, SIUIKeyboardStateNormal, PR3K11, ROW_3_PVC, LR3K11, ROW_3_LVC}, // Index 101
	{SIUIKeyboardKeyTypeAlphaNumericSwitchLeft, ' ', NO, SIUIKeyboardStateNormal, PR4K1, ROW_4_PVC, LR4K1, ROW_4_LVC}, // Index 102
	{SIUIKeyboardKeyTypeAlphaNumericSwitchRight, ' ', NO, SIUIKeyboardStateNormal, PR4K3, ROW_4_PVC, LR4K3, ROW_4_LVC}, // Index 103
	{SIUIKeyboardKeyTypeUndo, ' ', NO, SIUIKeyboardStateNumeric, PR3K12, ROW_3_PVC, LR3K12, ROW_3_LVC}, // Index 104
	{SIUIKeyboardKeyTypeRedo, ' ', NO, SIUIKeyboardStateSymbol, PR3K12, ROW_3_PVC, LR3K12, ROW_3_LVC} // Index 105
};

// State change sequences.
static key stateChangeKeys[12] = {
	{SIUIKeyboardStateNormal, SIUIKeyboardStateNumeric, 102, -1},
	{SIUIKeyboardStateNormal, SIUIKeyboardStateSymbol, 102, 100},
	{SIUIKeyboardStateNumeric, SIUIKeyboardStateNormal, 102, -1},
	{SIUIKeyboardStateNumeric, SIUIKeyboardStateSymbol, 100, -1},
	{SIUIKeyboardStateSymbol, SIUIKeyboardStateNormal, 102, -1},
	{SIUIKeyboardStateSymbol, SIUIKeyboardStateNumeric, 100, -1}
};

-(void) dealloc {
	DC_DEALLOC(view);
	free(keyData);
	[super dealloc];
}

-(id) initWithView:(UIView *) aView {
	self = [super init];
	if (self) {
		view = [aView retain];
		keyboardState = SIUIKeyboardStateNormal;
	}
	return self;
}

-(void) enterText:(NSString *) text {
	for (int i = 0; i < [text length]; i++) {
		
		// Get the next char.
		unichar nextChar = [text characterAtIndex:i];
		
		// Find it in the array.
		key charData;
		for (int keyIdx = 0; keyIdx < KEY_ARRAY_LENGTH; keyIdx++) {
			if (keyData[keyIdx].character == nextChar) {
				DC_LOG(@"Found %C", keyData[keyIdx].character);
				charData = keyData[keyIdx];
				break;
			}
		}
		
		DC_LOG(@"Testing %C => %i x %i'", charData.character, charData.portraitX, charData.portraitY);
	}
}

-(NSArray *) lastKeySequence {
	return nil;
}

@end
