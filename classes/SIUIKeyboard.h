//
//  SIUIKeyboard.h
//  Simon
//
//  Created by Derek Clarkson on 17/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Class which handles the keyboard and sends key strokes to it. To use, simply pass the text you want it to type.
 */
@interface SIUIKeyboard : NSObject

-(void) enterText:(NSString *) text keyRate:(NSTimeInterval) keyRate;

@end
