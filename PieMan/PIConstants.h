//
//  PIConstants.h
//  Simon
//
//  Created by Derek Clarkson on 3/09/12.
//  Copyright (c) 2012. All rights reserved.
//

/// Error domain for NSError's that Pieman generates.
#define PIEMAN_ERROR_DOMAIN @"PIError"

// Simulator control.
#define TERMINATION_CHECK_PERIOD 1.0
#define FORCE_TERMINATE_AFTER 5.0
#define SESSION_TIMEOUT 5.0
#define SIMULATOR_CONTENT_PATH @"~/Library/Application Support/iPhone Simulator/%@"
#define APPLE_SIMULATOR_BUNDLE_ID @"com.apple.iphonesimulator"

typedef void (^SimpleBlock)();

/// The various families of devices we can simulate.
typedef enum {
	PIDeviceFamilyiPhone = 1,
	PIDeviceFamilyiPad
} PIDeviceFamily;