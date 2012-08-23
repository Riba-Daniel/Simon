//
//  SIUIButtonHandler.m
//  Simon
//
//  Created by Derek Clarkson on 11/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIUIButtonHandler.h>

@implementation SIUIButtonHandler

-(NSDictionary *) kvcAttributes {

	// Get parent attributes.
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	[attributes addEntriesFromDictionary:[super kvcAttributes]];

	UIButton *button = (UIButton *) self.view;
	if (button.titleLabel.text != nil) {
		[attributes setObject:button.titleLabel.text forKey:@"titleLabel.text"];
	}	
	if (button.currentTitle != nil) {
		[attributes setObject:button.currentTitle forKey:@"currentTitle"];
	}	
	return [attributes count] > 0 ? attributes : nil;
}

@end
