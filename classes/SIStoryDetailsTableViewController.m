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
-(void) assembleStoryText;
-(void) processTrace;
@property (nonatomic, retain) NSString *storyText;
@property (nonatomic, retain) NSString *trace;
@property (nonatomic, retain) UIFont *reportFont;
@property (nonatomic, retain) UIFont *traceFont;
@end

@implementation SIStoryDetailsTableViewController

@synthesize source = source_;
@synthesize story = story_;
@synthesize trace = trace_;
@synthesize storyText = storyText_;
@synthesize reportFont = reportFont_;
@synthesize traceFont = traceFont_;

-(void) dealloc {
   self.story = nil;
	self.storyText = nil;
   self.source = nil;
   self.traceFont = nil;
   self.reportFont = nil;
   self.trace = nil;
   [super dealloc];
}

#pragma mark - UIView methods

-(void) viewDidLoad {
   self.reportFont = [UIFont systemFontOfSize:14.0f];
   self.traceFont = [UIFont fontWithName:@"Courier" size:12];
	
	[self assembleStoryText];
   
   if (self.story.stepWithError.exception != nil) {
      [self processTrace];
   }
}

#pragma mark - Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *text;
   switch (indexPath.row) {
      case 0:
         text = self.storyText;
			break;
         
      case 1:
			text = [self.source.source lastPathComponent];
         break;
		case 2:
			text = [self.story.error localizedFailureReason];
			break;
         
      default:
			text = self.trace;
         break;
   }
	
	if (text == nil) {
		text = @"X";
	}
	CGSize size = [text sizeWithFont:self.traceFont constrainedToSize:CGSizeMake(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 580 : 204, CGFLOAT_MAX)];
	return size.height + 12;
}

#pragma mark - Data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
   UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReportDetailsCell"];
   
   if (cell == nil) { 
      // Create one.
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"ReportDetailsCell"] autorelease];
      cell.detailTextLabel.font = self.reportFont;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
   }
   
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Story";
			cell.detailTextLabel.text = [self storyText];
			break;
		case 1:
			cell.textLabel.text = @"Story file";
			cell.detailTextLabel.text = [self.source.source lastPathComponent];
			break;
		case 2:
			cell.textLabel.text = @"Error";
			cell.detailTextLabel.text = [self.story.error localizedFailureReason];
			break;
		case 3:
			cell.textLabel.text = @"Stack trace";
			cell.detailTextLabel.text = self.trace;
			cell.detailTextLabel.font = [UIFont fontWithName:@"Courier" size:12];
			break;
		default:
			break;
	}
	
	cell.detailTextLabel.numberOfLines = 0;
	
   return cell;
}

#pragma mark - Private methods

-(void) assembleStoryText {
   NSMutableString *text = [NSMutableString string];
   [self.story.steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
      [text appendFormat:@"%@%@", (NSString *) idx > 0 ? @"\n" : @"",((SIStep *)obj).command];
   }];
   self.storyText = text;
}

-(void) processTrace {
   // Now work out the format of the trace results.
   NSError *error = nil;
   NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+ +(.+?)\\s+(0x[\\da-f]+) (.+) \\+" 
                                                                          options:NSRegularExpressionCaseInsensitive
                                                                            error:&error];
   // Read in the data from the stack trace.
   NSMutableArray *traceLines = [NSMutableArray array];
   NSArray *callStackSymbols = [self.story.stepWithError.exception callStackSymbols];
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
   DC_LOG(@"Finding max source text length");
   [traceLines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      SITraceLineData *lineData = (SITraceLineData *) obj;
      if (! DC_EQUALS_NOT_FOUND_RANGE(lineData.sourceRange)) {
         if (lineData.sourceRange.length > maxSourceLength) {
            maxSourceLength = lineData.sourceRange.length;
         }
      }
   }];
   
	// Work out the stack trace line.
	NSString *lineFormatString;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		lineFormatString = [NSString stringWithFormat:@"\n%%-3i %%-%is %%@ %%@", maxSourceLength];
	} else {
		lineFormatString = @"\n%@";
	}
	DC_LOG(@"Format string is %@", lineFormatString);
	
   // Now format the lines.
   NSMutableString *stackTrace = [NSMutableString string];
	SITraceLineData *lineData;
   for (int i = 0; i < [traceLines count]; i++) {
      
		lineData = [traceLines objectAtIndex: i];
      
		if (DC_EQUALS_NOT_FOUND_RANGE(lineData.sourceRange)) {
         [stackTrace appendString:lineData.line];
      } else {
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				[stackTrace appendFormat:lineFormatString, i, 
				 [[lineData.line substringWithRange:lineData.sourceRange] UTF8String],
				 [lineData.line substringWithRange:lineData.addressRange],
				 [lineData.line substringWithRange:lineData.methodRange]
				 ];
			} else {
				[stackTrace appendFormat:lineFormatString, [lineData.line substringWithRange:lineData.methodRange]];
			}
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

