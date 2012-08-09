//
//  GHTestCase+GHTestCase_TestUtils.h
//  Simon
//
//  Created by Derek Clarkson on 9/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <Simon/SIConstants.h>

@interface GHTestCase (GHTestCase_TestUtils)

-(NSNotification *) createMockedNotification:(NSString *) name forStoryStatus:(SIStoryStatus) status;

@end
