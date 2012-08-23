//
//  SIUILabelHandler.m
//  Simon
//
//  Created by Derek Clarkson on 11/03/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIUILabelHandler.h>

@implementation SIUILabelHandler

-(NSDictionary *) kvcAttributes {
	
	// Get parent attributes.
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	[attributes addEntriesFromDictionary:[super kvcAttributes]];
	
	UILabel *label = (UILabel *) self.view;
	if (label.text != nil) {
		[attributes setObject:label.text forKey:@"text"];
	}	
	return [attributes count] > 0 ? attributes : nil;

}

@end
