//
//  SIStoryGroupManager.h
//  Simon
//
//  Created by Derek Clarkson on 11/08/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Simon/SIStoryGroup.h>

/**
 Stores and manages the story sources.
 */
@interface SIStoryGroupManager : NSObject

/// All the story groups.
@property (nonatomic, readonly) NSArray *storyGroups;

/// Only the story groups which contain selected stories.
@property (nonatomic, readonly) NSArray *selectedStoryGroups;

/// Returns the text used as a criteria for selecting stories.
@property (nonatomic, readonly) NSString *selectionCriteria;

/// If not nil, indicates the index path to the story for individual viewing. Usually this is set and retrieved by the UI. Setting it does not effect selection. This is mainly a place to store this value between displays.
@property (nonatomic, retain) NSIndexPath *currentIndexPath;

/// @name Tasks

/**
 Adds a source to the list.
 
 @param source the source to be added.
 */
-(void) addStoryGroup:(SIStoryGroup *) storyGroup;

/**
 Selects sources and stores where the source file name or the story title match the passed prefix. If the source is selected then all the stories within it are automatically selected.
 
 @param prefix the prefix to use to match source file names and story titles.
 */
-(void) selectWithPrefix:(NSString *) prefix;

/// Selects all stories and therefore all sources. This automatically clears any search criteria.
-(void) selectAll;

@end
