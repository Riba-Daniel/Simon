//
//  SIUIiPadKeyboard.h
//  Simon
//
//  Created by Derek Clarkson on 17/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIUIKeyboard.h"


@interface SIUIiPadKeyboard : NSObject<SIUIKeyboard> {
	@private 
	UIView *view;
	int keyboardState;
}

-(id) initWithView:(UIView *) aView;

-(NSArray *) lastKeySequence;

@end
