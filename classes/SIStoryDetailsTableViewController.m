//
//  SIStoryDetailsTableViewController.m
//  Simon
//
//  Created by Derek Clarkson on 24/10/11.
//  Copyright (c) 2011 Sensis. All rights reserved.
//

#import "SIStoryDetailsTableViewController.h"

@interface SITraceLineData : NSObject

@property (nonatomic, retain) NSString *line;
@property (nonatomic, assign) NSRange sourceRange;
@property (nonatomic, assign) NSRange addressRange;
@property (nonatomic, assign) NSRange methodRange;

@end

@implementation SITraceLineData

@synthesize line = line_;
@synthesize sourceRange = sourceRange_;
@synthesize addressRange = addressRange_;
@synthesize methodRange = methodRange_;

-(void) dealloc {
   self.line = nil;
   [super dealloc];
}

@end

@interface SIStoryDetailsTableViewController()
-(NSString *) storyText;
-(void) processTrace;
@property (nonatomic, retain) NSString *trace;
@property (nonatomic, retain) UIFont *reportFont;
@property (nonatomic, retain) UIFont *traceFont;
@end

@implementation SIStoryDetailsTableViewController

@synthesize source = source_;
@synthesize story = story_;
@synthesize trace = trace_;
@synthesize reportFont = reportFont_;
@synthesize traceFont = traceFont_;

-(void) dealloc {
   self.story = nil;
   self.source = nil;
   self.traceFont = nil;
   self.reportFont = nil;
   self.trace = nil;
   [super dealloc];
}

#pragma mark - UIView methods

-(void) viewDidLoad {
   self.tableView.backgroundColor = [UIColor clearColor];
   self.tableView.backgroundView = nil;
   self.tableView.separatorColor = [UIColor lightGrayColor];
   self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
   self.reportFont = [UIFont systemFontOfSize:14.0f];
   self.traceFont = [UIFont fontWithName:@"Courier" size:12];
   
   // If there is a trace we need to process it.
   if (self.story.mappingWithError.exception != nil) {
      [self processTrace];
   }
}

#pragma mark - Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   switch (indexPath.section) {
      case 0:
         return [self.story.steps count] * self.reportFont.lineHeight + 12.0f;
         
      case 1:
         if (indexPath.row == 2) {
            DC_LOG(@"Working out height for trace");
            CGSize size = [self.trace sizeWithFont:self.traceFont constrainedToSize:CGSizeMake(580, CGFLOAT_MAX)];
            return size.height + 12;
         }
         break;
         
      default:
         break;
   }
   return 45;
}

#pragma mark - Data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   switch (section) {
      case 0:
         return 1;
         break;
         
      default:
         return 3;
         break;
   }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
   UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReportDetailsCell"];
   
   if (cell == nil) { 
      // Create one.
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"ReportDetailsCell"] autorelease];
      cell.detailTextLabel.font = self.reportFont;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
   }
   
   switch (indexPath.section) {
      case 0:
         cell.textLabel.text = @"Story";
         cell.detailTextLabel.text = [self storyText];
         cell.detailTextLabel.numberOfLines = 0;
         break;
         
      default:
         switch (indexPath.row) {
            case 0:
               cell.textLabel.text = @"Story file";
               cell.detailTextLabel.text = [self.source.source lastPathComponent];
               break;
            case 1:
               cell.textLabel.text = @"Error";
               cell.detailTextLabel.text = [self.story.error localizedDescription];
               cell.detailTextLabel.numberOfLines = 0;
               break;
            case 2:
               cell.textLabel.text = @"Error details";
               cell.textLabel.numberOfLines = 0;
               cell.detailTextLabel.text = self.trace;
               cell.detailTextLabel.numberOfLines = 0;
               cell.detailTextLabel.font = [UIFont fontWithName:@"Courier" size:12];
               break;
            default:
               break;
         }
   }
   
   return cell;
}

#pragma mark - Private methods

-(NSString *) storyText {
   NSMutableString *text = [NSMutableString string];
   [self.story.steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
      [text appendFormat:@"%@%@", (NSString *) idx > 0 ? @"\n" : @"",((SIStep *)obj).command];
   }];
   return text;
}

-(void) processTrace {
   // Now work out the format of the trace results.
   NSError *error = nil;
   NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+ +(.+?)\\s+(0x[\\da-f]+) (.+) \\+" 
                                                                          options:NSRegularExpressionCaseInsensitive
                                                                            error:&error];
   // Read in the data from the stack trace.
   NSMutableArray *traceLines = [NSMutableArray array];
   NSArray *callStackSymbols = [self.story.mappingWithError.exception callStackSymbols];
   [callStackSymbols enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      
      // Create an object to store the trace line.
      SITraceLineData *lineData = [[SITraceLineData alloc] init];
      lineData.line = obj;
      
      // Check for the expected layout
      NSTextCheckingResult *match = [regex firstMatchInString:obj
                                                      options:0
                                                        range:NSMakeRange(0, [obj length])];
      if (match) {
         // Store the locations we are interested.
         lineData.addressRange = [match rangeAtIndex:2];
         lineData.sourceRange = [match rangeAtIndex:1];
         lineData.methodRange = [match rangeAtIndex:3];
      } 
      
      // Add the data to the list of trace lines.
      DC_LOG(@"Adding trace line: %@", lineData.line);
      [traceLines addObject:lineData];
      [lineData release];
   }];
   
   // Find longest source string.
   __block NSUInteger maxSourceLength = 0;
   DC_LOG(@"FInding max source text length");
   [traceLines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      SITraceLineData *lineData = (SITraceLineData *) obj;
      if (! DC_EQUALS_NOT_FOUND_RANGE(lineData.sourceRange)) {
         if (lineData.sourceRange.length > maxSourceLength) {
            maxSourceLength = lineData.sourceRange.length;
         }
      }
   }];
   
   // Now format the lines.
   NSMutableString *stackTrace = [NSMutableString string];
   NSString *lineFormatString = [NSString stringWithFormat:@"\n%%i %%-%i@ %%@ %%@", maxSourceLength];
   DC_LOG(@"Format string is %@", lineFormatString);
   for (int i = 0; i < [traceLines count]; i++) {
      SITraceLineData *lineData = [traceLines objectAtIndex: i];
      if (! DC_EQUALS_NOT_FOUND_RANGE(lineData.sourceRange)) {
         [stackTrace appendFormat:@"\n%3i %-17s %15@ %@", i, 
          [[lineData.line substringWithRange:lineData.sourceRange] UTF8String],
          [lineData.line substringWithRange:lineData.addressRange],
          [lineData.line substringWithRange:lineData.methodRange]
          ];
      } else {
         [stackTrace appendString:lineData.line];
      }
    }
   DC_LOG(@"Formatted trace: %@", stackTrace);
   
   self.trace = [NSString stringWithFormat:@"%@%@", [self.story.error localizedFailureReason], stackTrace];
   
}

#pragma mark - View rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return YES;
}

@end

