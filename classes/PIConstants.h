//
//  PIConstants.h
//  Simon
//
//  Created by Derek Clarkson on 3/09/12.
//  Copyright (c) 2012. All rights reserved.
//

/// Error domain for NSError's that Pieman generates.
#define PIEMAN_ERROR_DOMAIN @"PIError"

// Heartbeat
#define SIMON_HEARTBEAT_QUEUE_NAME "au.com.derekclarkson.pieman.heartbeat"
#define HEARTBEAT_FREQUENCY 2.0
#define HEARTBEAT_MAX_ATTEMPTS 5
#define HEARTBEAT_TIMEOUT 1.0

// Simulator control.
#define TERMINATION_CHECK_PERIOD 1.0
#define FORCE_TERMINATE_AFTER 5.0
#define SESSION_TIMEOUT 10.0

#define SIMULATOR_CONTENT_PATH @"~/Library/Application Support/iPhone Simulator/%@"
#define APPLE_SIMULATOR_BUNDLE_ID @"com.apple.iphonesimulator"

/// The various families of devices we can simulate.
typedef enum {
	PIDeviceFamilyiPhone = 1,
	PIDeviceFamilyiPad
} PIDeviceFamily;