//
//  SIFinalReport.h
//  Simon
//
//  Created by Derek Clarkson on 27/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpPayload.h>

/**
 This class contains information for producing the final report on a test run.
 */
@interface SIFinalReport : SIHttpPayload

/// @name Properties

/// How many stories where not run.
@property (nonatomic, assign) NSUInteger notRun;

/// How many stories ran successfully.
@property (nonatomic, assign) NSUInteger successful;

/// How many stories were not fully mapped and therefore could not be run.
@property (nonatomic, assign) NSUInteger notMapped;

/// How many stories were not run because they had been flagged to be ignored.
@property (nonatomic, assign) NSUInteger ignored;

/// How many stories were run, but had some error occur.
@property (nonatomic, assign) NSUInteger failed;

@end
