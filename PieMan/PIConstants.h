//
//  PIConstants.h
//  Simon
//
//  Created by Derek Clarkson on 3/09/12.
//  Copyright (c) 2012. All rights reserved.
//

/// Error domain for NSError's that Pieman generates.
#define PIEMAN_ERROR_DOMAIN @"PIError"

/// The various families of devices we can simulate.
typedef enum {
	PIDeviceFamilyiPhone = 1,
	PIDeviceFamilyiPad
} PIDeviceFamily;