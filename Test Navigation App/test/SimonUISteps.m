//
//  SimonUISteps.m
//  Simon
//
//  Created by Derek Clarkson on 7/16/11.
//  Copyright 2011 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SISimon.h"

@interface SimonUISteps : NSObject
-(void) logSubviewsOfView:(UIView *) view widthPrefix:(NSString *) prefix;
-(NSString *) getLogTextForView:(UIView *) view;
@end

@implementation SimonUISteps

SIMapStepToSelector(@"Given test app is ready", doNothing)
-(void) doNothing {
	
}

SIMapStepToSelector(@"Then display the view hirachy", displayHierachy)

-(void) displayHierachy {
	UIWindow * window = [UIApplication sharedApplication].keyWindow;
	[self logSubviewsOfView:window widthPrefix:@""];
}

// Helper methods.
-(void) logSubviewsOfView:(UIView *) view widthPrefix:(NSString *) prefix {
	DC_LOG(@"%@%@", prefix, [self getLogTextForView:view]);
	NSString * offset = [NSString stringWithFormat:@"%@%@", prefix, @"   "];
	for (UIView * subview in view.subviews) {
		[self logSubviewsOfView:subview widthPrefix:offset];
	}
}

-(NSString *) getLogTextForView:(UIView *) view {
	
	if ([view isKindOfClass:[UIButton class]]) {
		UIButton * button = (UIButton *) view;
		return [NSString stringWithFormat:@"[%@] (%i) %@", [button class], button.buttonType, button.currentTitle];
	} else
		if ([view isKindOfClass:[UILabel class]]) {
			UILabel * label = (UILabel *) view;
			return [NSString stringWithFormat:@"[%@] %@", [label class], label.text];
		}
	
	return [[view class] description];
}

@end
