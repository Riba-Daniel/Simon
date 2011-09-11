//
//  TestUtils.h
//  Simon
//
//  Created by Derek Clarkson on 11/09/11.
//  Copyright (c) 2011. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

@interface AbstractTestWithControlsOnView : GHTestCase {
	UIView *view;
	UIButton *button;
	BOOL tapped;
}
-(void) addControls;
-(void) removeControls;
-(IBAction) buttonTapped:(id) sender;

@end
