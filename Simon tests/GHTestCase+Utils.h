//
//  GHTestCase+GHTestCase_TestUtils.h
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SICore.h>

@interface GHTestCase (Utils)

-(NSNotification *) createMockedNotification:(NSString *) name forStoryStatus:(SIStoryStatus) status;

@end
