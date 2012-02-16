//
//  TestButton.m
//  Simon
//
//  Created by Derek Clarkson on 16/02/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "TestButton.h"
#import <dUsefulStuff/DCCommon.h>

@implementation TestButton
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   DC_LOG(@"began");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   DC_LOG(@"moved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   DC_LOG(@"ended");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
   DC_LOG(@"cancelled");
}
@end
