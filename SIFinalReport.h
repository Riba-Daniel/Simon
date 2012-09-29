//
//  SIFinalReport.h
//  Simon
//
//  Created by Derek Clarkson on 27/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpPayload.h>

@interface SIFinalReport : SIHttpPayload

@property (nonatomic, assign) NSUInteger notRun;
@property (nonatomic, assign) NSUInteger successful;
@property (nonatomic, assign) NSUInteger notMapped;
@property (nonatomic, assign) NSUInteger ignored;
@property (nonatomic, assign) NSUInteger failed;

@end
