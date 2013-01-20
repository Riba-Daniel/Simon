//
//  SIUIConstants.h
//  Simon
//
//  Created by Derek Clarkson on 18/02/12.
//  Copyright (c) 2012. All rights reserved.
//

#define IPAD_HEADER_INDENT 55
#define IPHONE_HEADER_INDENT 20

/// Defines the 4 main directions a swipe can go.
typedef enum {
   SIUISwipeDirectionUp,
   SIUISwipeDirectionDown,
   SIUISwipeDirectionRight,
   SIUISwipeDirectionLeft
} SIUISwipeDirection;

/// Macro used to control the log actions functionality.
#define SI_LOG_ACTION(msg, ...) \
	if (self.logActions) { \
		NSLog(msg, ##__VA_ARGS__); \
	}


