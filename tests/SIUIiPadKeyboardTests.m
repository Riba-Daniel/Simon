//
//  SIUIiPadKeyboardTests.m
//  Simon
//
//  Created by Derek Clarkson on 18/03/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SIUIiPadKeyboard.h"
#import "AbstractTestWithControlsOnView.h"


@interface SIUIiPadKeyboardTests : AbstractTestWithControlsOnView

@end

@implementation SIUIiPadKeyboardTests

/*
-(void) testSimpleText {
	SIUIiPadKeyboard *keyboard = [[[SIUIiPadKeyboard alloc] initWithView:nil] autorelease];
	[keyboard enterText:@"Hello"];
}
*/

-(void) testCheckPrivateApis {
	SITapView(@"//UITextField[@tag='110']");
	SIPauseFor(1);
	SIPrintCurrentWindowTree();

	UIWindow *effectsWindow = [(UIWindow *)[UIApplication sharedApplication].windows objectAtIndex:1];
	UIView *hostView = (UIView *) [effectsWindow.subviews objectAtIndex:0];
	UIView *keyboardAuto = (UIView *) [hostView.subviews objectAtIndex:0];
	UIView *kbImpl = (UIView *) [keyboardAuto.subviews objectAtIndex:0];
	UIView *kbLayout = (UIView *) [kbImpl.subviews objectAtIndex:0];

	dispatch_queue_t mainQueue = dispatch_get_main_queue();
	dispatch_sync(mainQueue, ^{
		id returnObj = [kbLayout simulateTouchForCharacter:@"a" errorVector:CGPointMake(10,10) shouldTypeVariants:NO baseKeyForVariants:NO];
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; 
		 returnObj = [kbLayout simulateTouchForCharacter:@"b" errorVector:CGPointMake(10,10) shouldTypeVariants:NO baseKeyForVariants:NO];
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; 
		returnObj = [kbLayout simulateTouchForCharacter:@"C" errorVector:CGPointMake(10,10) shouldTypeVariants:NO baseKeyForVariants:NO];
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; 
		returnObj = [kbLayout simulateTouchForCharacter:@"D" errorVector:CGPointMake(10,10) shouldTypeVariants:NO baseKeyForVariants:NO];
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; 
		returnObj = [kbLayout simulateTouchForCharacter:@"!" errorVector:CGPointMake(10,10) shouldTypeVariants:NO baseKeyForVariants:NO];
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; 
		returnObj = [kbLayout simulateTouchForCharacter:@" " errorVector:CGPointMake(10,10) shouldTypeVariants:NO baseKeyForVariants:NO];
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; 
		returnObj = [kbLayout simulateTouchForCharacter:@"\n" errorVector:CGPointMake(10,10) shouldTypeVariants:NO baseKeyForVariants:NO];
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; 
		returnObj = [kbLayout simulateTouchForCharacter:@"á" errorVector:CGPointMake(10,10) shouldTypeVariants:YES baseKeyForVariants:NO];
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; 
		returnObj = [kbLayout simulateTouchForCharacter:@"!" errorVector:CGPointMake(10,10) shouldTypeVariants:NO baseKeyForVariants:NO];
	});
	[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]; 
	
	//UIView *kbPlane = (UIView *) [kbLayout.subviews objectAtIndex:1];
	//UIView *kbView = (UIView *) [kbPlane.subviews objectAtIndex:0];
	SIPauseFor(1);
}
//- (id)simulateTouchForCharacter:(id)arg1 errorVector:(struct CGPoint { float x1; float x2; })arg2 shouldTypeVariants:(BOOL)arg3 baseKeyForVariants:(BOOL)arg4;

@end
