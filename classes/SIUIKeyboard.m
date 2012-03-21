
#import "SIUIKeyboard.h"
#import <dUsefulStuff/DCCommon.h>

// We need access to the layout class.
@interface UIKeyboardLayout : UIView
- (id)simulateTouchForCharacter:(id)arg1 errorVector:(CGPoint)arg2 shouldTypeVariants:(BOOL)arg3 baseKeyForVariants:(BOOL)arg4;
@end

@implementation SIUIKeyboard

-(void) enterText:(NSString *) text keyRate:(NSTimeInterval) keyRate {
	
	// First navigate the keyboard hierarchy to the keyboard layout.
	
	
	NSArray *windows = [UIApplication sharedApplication].windows;
	UIWindow *effectsWindow = [windows objectAtIndex:1];
	UIView *hostView = (UIView *) [effectsWindow.subviews objectAtIndex:0];
	UIView *keyboardAuto = (UIView *) [hostView.subviews objectAtIndex:0];
	UIView *kbImpl = (UIView *) [keyboardAuto.subviews objectAtIndex:0];
	UIKeyboardLayout *kbLayout = (UIKeyboardLayout *) [kbImpl.subviews objectAtIndex:0];

	// Loop and send each character.
	dispatch_queue_t mainQueue = dispatch_get_main_queue();
	dispatch_sync(mainQueue, ^{
		id sentChar = [kbLayout simulateTouchForCharacter:@"a" errorVector:CGPointMake(10,10) shouldTypeVariants:YES baseKeyForVariants:NO];
		DC_LOG(@"Sent character %@", sentChar);
	});
} 

@end


