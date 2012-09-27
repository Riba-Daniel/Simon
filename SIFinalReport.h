//
//  SIFinalReport.h
//  Simon
//
//  Created by Derek Clarkson on 27/09/12.
//  Copyright (c) 2012 Sensis. All rights reserved.
//

#import <Simon/SIHttpPayload.h>

#define FINAL_REPORT_JSON_KEY_NOT_RUN @"notRun"
#define FINAL_REPORT_JSON_KEY_SUCCESSFUL @"successful"
#define FINAL_REPORT_JSON_KEY_NOT_MAPPED @"notMapped"
#define FINAL_REPORT_JSON_KEY_IGNORED @"ignored"
#define FINAL_REPORT_JSON_KEY_FAILED @"failed"

@interface SIFinalReport : SIHttpPayload

@property (nonatomic, assign) NSUInteger notRun;
@property (nonatomic, assign) NSUInteger successful;
@property (nonatomic, assign) NSUInteger notMapped;
@property (nonatomic, assign) NSUInteger ignored;
@property (nonatomic, assign) NSUInteger failed;

@end
