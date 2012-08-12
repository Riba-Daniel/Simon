//
//  SIState.h
//  Simon
//
//  Created by Derek Clarkson on 5/08/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import "SIStory.h"

/**
 This data object tracks the state and data necessary to ensure that Simon knows what it has been instructed to do between runs and displays.
 */
@interface SIState : NSObject

/// @name Properties

/// The search terms entered by the user in the UI.
@property (nonatomic, retain) NSString *searchTerms;

/// If not nil, then the UI should return to viewing the details of this story next time it is displayed.
@property (nonatomic, retain) SIStory *viewStory;

@end
