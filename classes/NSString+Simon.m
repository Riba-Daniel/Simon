//
//  NSString+Utils.m
//  Simon
//
//  Created by Derek Clarkson on 6/18/11.
//  Copyright 2011. All rights reserved.
//

#import <Simon/NSString+Simon.h>
#import <Simon/SIConstants.h>

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

-(SIKeyword) siKeyword {
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

+(NSString *) stringFromSIKeyword:(SIKeyword) keyword {
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

-(BOOL) hasPrefix:(NSString *) prefix options:(NSStringCompareOptions) options {
	
	// Avoid out of range exceptions.
	if (self.length < [prefix length]) {
		return NO;
	}
	
	// Check using options.
	NSComparisonResult result = [self compare:prefix options:options range:NSMakeRange(0, [prefix length])];
	return result == NSOrderedSame;
}

+ (BOOL) isEmpty:(NSString *) value {
	return ([[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0);
}

-(SIHttpMethod) siHttpMethod {
	NSString * upper = [self uppercaseString];
	if ([@"POST" isEqualToString:upper]) {
		return SIHttpMethodPost;
	} else if ([@"GET" isEqualToString:upper]) {
		return SIHttpMethodGet;
	}
	return SIHttpMethodUnknown;
}


@end
