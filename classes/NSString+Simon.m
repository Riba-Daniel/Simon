//
//  NSString+Utils.m
//  Simon
//
//  Created by Derek Clarkson on 6/18/11.
//  Copyright 2011. All rights reserved.
//

#import "NSString+Simon.h"

@implementation NSString (Simon)

-(NSString *) stringByRemovingQuotes {
	NSCharacterSet *quotes = [NSCharacterSet characterSetWithCharactersInString:@"'\""];
	return [self stringByTrimmingCharactersInSet:quotes];
}

+(NSString *) stringStatusWithStory:(SIStory *) story {
	
	switch (story.status) {
		case SIStoryStatusSuccess:
			return @"Success";
			break;
		case SIStoryStatusNotMapped:
			return @"Not mapped";
			break;
		case SIStoryStatusError:
			return [NSString stringWithFormat:@"Failed: %@", story.error.localizedFailureReason];
			break;
		case SIStoryStatusIgnored:
			return @"Ignored";
			break;
		default:
			return @"Not run";
			break;
	}
	
}

-(SIKeyword) keywordFromString {
	NSString * upper = [self uppercaseString];
	if ([@"STORY" isEqualToString:upper]) {
		return SIKeywordStory;
	} else if ([@"GIVEN" isEqualToString:upper]) {
		return SIKeywordGiven;
	} else if ([@"THEN" isEqualToString:upper]) {
		return SIKeywordThen;
	} else if ([@"AS" isEqualToString:upper]) {
		return SIKeywordAs;
	} else if ([@"AND" isEqualToString:upper]) {
		return SIKeywordAnd;
	}
	return SIKeywordUnknown;
}

+(NSString *) stringFromKeyword:(SIKeyword) keyword {
	switch (keyword) {
		case SIKeywordStartOfFile:
			return @"Start of file";
			break;
			
		case SIKeywordStory:
			return @"Story";
			break;
			
		case SIKeywordGiven:
			return @"Given";
			break;
			
		case SIKeywordThen:
			return @"Then";
			break;
			
		case SIKeywordAs:
			return @"As";
			break;
			
		case SIKeywordAnd:
			return @"And";
			break;
			
		default:
			return @"Unknown";
			break;
	}
}


@end
