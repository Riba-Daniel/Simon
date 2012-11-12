//
//  SIStoryTextFileSourceTests.m
//  Simon
//
//  Created by Derek Clarkson on 11/11/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <dUsefulStuff/DCCommon.h>

#import <Simon/SIStoryTextFileSource.h>
#import <Simon/SIStoryTextSourceDelegate.h>

#import <dUsefulStuff/NSObject+dUsefulStuff.h>

@interface SIStoryTextFileSourceTests : GHTestCase<SIStoryTextSourceDelegate> {
	@private
	NSMutableArray *stories;
	int linesRead;
	BOOL lineProcessedOk;
	NSError *lineError;
}

@end

@implementation SIStoryTextFileSourceTests

-(void) setUp {
	stories = [[NSMutableArray alloc] init];
	linesRead = 0;
	lineProcessedOk = YES;
}

-(void) tearDown {
	DC_DEALLOC(stories);
}

-(void) testReadingFiles {
	
	SIStoryTextFileSource *textFileSource = [[[SIStoryTextFileSource alloc] init] autorelease];
	textFileSource.delegate = self;
	NSError *error = NULL;
	GHAssertTrue([textFileSource startWithError:&error], nil);
	GHAssertTrue(error == NULL, nil);
	GHAssertEquals([stories count], (NSUInteger) 8, nil);
	GHAssertEquals(linesRead, 49, nil);
}

-(void) testLineError {
	
	SIStoryTextFileSource *textFileSource = [[[SIStoryTextFileSource alloc] init] autorelease];
	textFileSource.delegate = self;

	// Just say no.
	lineProcessedOk = NO;
	[self setError:&lineError
				 code:1
		errorDomain:@"domain"
 shortDescription:@"shortDescription"
	 failureReason:@"failureReason"];
	
	NSError *error = NULL;
	GHAssertFalse([textFileSource startWithError:&error], nil);

	GHAssertTrue(error != NULL, nil);
	GHAssertEquals([stories count], (NSUInteger) 1, nil);
	GHAssertEquals(linesRead, 1, nil);
	GHAssertEqualStrings([error localizedDescription], @"Line 1: shortDescription", nil);
}

#pragma mark - Delegate methods

-(BOOL) storyTextSource:(id<SIStoryTextSource>) textSource willReadFromSource:(NSString *) source error:(NSError **) error {
	if (![stories containsObject:source]) {
		[stories addObject:source];
	}
	return YES;
}

-(BOOL) storyTextSource:(id<SIStoryTextSource>) textSource readLine:(NSString *) line error:(NSError **) error {
	linesRead++;
	if (*error == NULL) {
		*error = lineError;
	}
	return lineProcessedOk;
}

-(BOOL) storyTextSource:(id<SIStoryTextSource>) textSource didReadFromSource:(NSString *) source error:(NSError **) error {
	return YES;
}


@end
