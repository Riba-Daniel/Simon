//
//  SIInAppReporter.h
//  Simon
//
//  Created by Derek Clarkson on 9/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIStoryReporter.h"
#import "SIStoryReportTableViewController.h"

@interface SIStoryInAppReporter : NSObject<SIStoryReporter> {
	@private 
	UINavigationController *navController;
}

@end
