//
//  main.m
//  PieMan
//
//  Created by Derek Clarkson on 2/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <dUsefulStuff/DCCommon.h>

#import "PIPieman.h"
#import "SICore.h"
#import "PIConstants.h"
#import <Simon/NSProcessInfo+Simon.h>
#import "PISimulator.h"
#import "DTiPhoneSimulatorSystemRoot.h"

#define ARG_HELP @"-?"
#define ARG_JUNIT_DIR @"-junit-report-dir"
#define ARG_DEVICE @"-device"
#define ARG_SDK @"-sdk"
#define ARG_LIST_SDKS @"-list-sdks"


// Function declarations.
int processCmdArgs(PIPieman *pieman, int argc, const char * argv[]);
NSString *getArgValue(NSString *portArg, int *argIdx, int argc, const char *argv[]);
int getPort(NSString *portArg, int *argIdx, int argc, const char *argv[]);
int portFromValue(NSString *value, const char *portName);
void printSdks(void);
void printHelp(void);

int main(int argc, const char * argv[]) {
	
	int exitCode = EXIT_SUCCESS;
	@autoreleasepool {
		
		// Check for help.
		if ([[NSProcessInfo processInfo] isArgumentPresentWithName:ARG_HELP]) {
			printHelp();
			return EXIT_SUCCESS;
		}
		
		// Check for sdk listing.
		if ([[NSProcessInfo processInfo] isArgumentPresentWithName:ARG_LIST_SDKS]) {
			printSdks();
			return EXIT_SUCCESS;
		}
		
		PIPieman *pieman = [[[PIPieman alloc] init] autorelease];
		
		// Process arguments.
		if (processCmdArgs(pieman, argc, argv) == EXIT_FAILURE) {
			printf("\nExiting\n");
			return EXIT_FAILURE;
		}
		
		// Start the run.
		[pieman start];
		if (pieman.finished) {
			// Can happen if there is a problem starting.
			return pieman.finished;
		}
		
		NSRunLoop *loop = [NSRunLoop currentRunLoop];
		while (!pieman.finished && [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
#ifdef DC_DEBUG
			NSLog(@"Run loop cycling");
#endif
		};
		
		// get the final code.
		exitCode = pieman.exitCode;
		
	}
	printf("Exiting with exit code %i\n", exitCode);
	return exitCode;
}

int processCmdArgs(PIPieman *pieman, int argc, const char * argv[]) {
	
	BOOL appArgFound = NO;
	NSMutableArray *appArguments = [NSMutableArray array];
	for (int i = 0; i < argc; i++ ) {
		
		// Ignore the first arg because it will be the program name.
		if (i == 0) {
			continue;
		}
		
		NSString *arg = [NSString stringWithUTF8String:argv[i]];
		
		// if we have found the app argument then everything else is an argument for that and should be passed to the simulator.
		if (appArgFound) {
			[appArguments addObject:arg];
			continue;
		}
		
		// Device settings
		if ([arg isEqualToString:ARG_DEVICE]) {
			NSString *device = getArgValue(ARG_DEVICE, &i, argc, argv);
			if (device == nil) {
				return EXIT_FAILURE;
			}
			pieman.device = [device isEqualToString:@"iphone"] ? PIDeviceFamilyiPhone : PIDeviceFamilyiPad;
			continue;
		}
		
		// Check for the pieman port.
		if ([arg isEqualToString: ARG_PIEMAN_PORT]) {
			int port = getPort(ARG_PIEMAN_PORT, &i, argc, argv);
			if (port == EXIT_FAILURE) {
				return EXIT_FAILURE;
			}
			pieman.piemanPort = port;
			continue;
		}
		
		// Check for Simon port.
		if ([arg isEqualToString: ARG_PIEMAN_PORT]) {
			int port = getPort(ARG_PIEMAN_PORT, &i, argc, argv);
			if (port == EXIT_FAILURE) {
				return EXIT_FAILURE;
			}
			pieman.simonPort = port;
			continue;
		}
		
		// Check for sdk.
		if ([arg isEqualToString:ARG_SDK]) {
			NSString *sdk = getArgValue(ARG_SDK, &i, argc, argv);
			if (sdk == nil) {
				return EXIT_FAILURE;
			}
			pieman.sdk = sdk;
			continue;
		}
		
		// If the arg starts with '-' is an unknown arg.
		if ([arg hasPrefix:@"-"]) {
			printf("Error: Unknown argument %s\n", argv[i]);
			return EXIT_FAILURE;
		}
		
		// Finally it must be the app file name.
		pieman.appPath = [arg stringByExpandingTildeInPath];
		if (![[NSFileManager defaultManager] fileExistsAtPath:pieman.appPath]) {
			printf("Error: App file '%s' does not exist.\n", [pieman.appPath UTF8String]);
			return EXIT_FAILURE;
		}
		appArgFound = YES;
		
	}
	
	// Set the args.
	pieman.appArgs = appArguments;
	
	return EXIT_SUCCESS;
	
}

int getPort(NSString *portArg, int *argIdx, int argc, const char *argv[]) {
	
	// Get the arg.
	NSString *value = getArgValue(portArg, argIdx, argc, argv);
	if (value == nil) {
		return EXIT_FAILURE;
	}
	
	int port = [value intValue];
	
	// error if it's not a number.
	if (port == 0) {
		printf("Error: Passed %s port is not a valid integer.\n", [portArg UTF8String]);
		return EXIT_FAILURE;
	}
	
	return port;
}

NSString *getArgValue(NSString *arg, int *argIdx, int argc, const char *argv[]) {
	
	// Error if no more args.
	if (*argIdx >= argc) {
		printf("Error: expected a port value for %s\n", [arg UTF8String]);
		return nil;
	}
	
	// Error if value is another argument.
	const char *value = argv[*argIdx + 1];
	char first = value[0];
	if (first == '-') {
		printf("Error: expected a value for %s but found another argument instead.\n", [arg UTF8String]);
		return nil;
	}
	
	// increment index and return.
	*argIdx = *argIdx + 1;
	return [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
}

void printSdks() {
	
	PISimulator *simulator = [[PISimulator alloc] init];
	NSArray *sdks = [simulator availableSdkVersions];

	printf("Available Sdks:\n");
	
	[sdks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		DTiPhoneSimulatorSystemRoot *sdkRoot = obj;
		printf("\nName   : %s\n", [sdkRoot.sdkDisplayName UTF8String]);
		printf("Version: %s\n", [sdkRoot.sdkVersion UTF8String]);
		printf("Path   : %s\n", [sdkRoot.sdkRootPath UTF8String]);
	}];
	
	[simulator release];
	
}

void printHelp() {
	
	const char *piemanArg = [[NSString stringWithFormat:@"%@ n", ARG_PIEMAN_PORT] UTF8String];
	const char *simonArg = [[NSString stringWithFormat:@"%@ n", ARG_SIMON_PORT] UTF8String];
	const char *jUnitReportDirArg = [[NSString stringWithFormat:@"%@ [path]", ARG_JUNIT_DIR] UTF8String];
	const char *deviceArg = [[NSString stringWithFormat:@"%@ iphone|ipad", ARG_DEVICE] UTF8String];
	const char *sdkArg = [[NSString stringWithFormat:@"%@ version", ARG_SDK] UTF8String];
	
	printf("The Pieman - Simon's mentor\n");
	printf("===========================\n\n");
	
	printf("The Pieman's job is to start and manage Simon test suites running in an iOS simulator.\n");
	printf("This is particularly useful when running on a Continuous Integeration (CI) machine which\n");
	printf("builds and runs software on a regular basis. \n");
	
	printf("\nSyntax: pieman [%1$s] [%5$s] [%2$s] [%3$s] [%4$s] [%6$s] [%7$s] app-file app-args...\n",
			 [ARG_HELP UTF8String],
			 piemanArg,
			 simonArg,
			 jUnitReportDirArg,
			 deviceArg,
			 [ARG_LIST_SDKS UTF8String],
			 sdkArg
			 );
	
	printf("\nArguments\n");
	printf("---------\n\n");
	
#define argFmt "%1$-25"
	
	printf(argFmt "s Prints this help information.\n\n", [ARG_HELP UTF8String]);

	printf(argFmt "s The device to use. iPhone or iPad, defaults to iPhone.\n\n", deviceArg);

	printf(argFmt "s Overrides the default HTTP port that the Pieman is listening\n", piemanArg);
	printf(argFmt "s for test results from Simon on. Defaults to %2$i\n\n", "", HTTP_PIEMAN_PORT);
	
	printf(argFmt "s Overrides the default HTTP port that Smon is listening on for\n", simonArg);
	printf(argFmt "s instructions from the Pieman on. Defaults to %2$i\n\n", "", HTTP_SIMON_PORT);
	
	printf(argFmt "s Activates junit xml test reports and writes them to a directory.\n", jUnitReportDirArg);
	printf(argFmt "s If 'path' is specified, writes to that path.\n", "");
	printf(argFmt "s If 'path' is not specified, writes to <current-dir>/junit.\n\n", "");

	printf(argFmt "s Prints all installed simulator sdks.\n\n", [ARG_LIST_SDKS UTF8String]);

	printf(argFmt "s Sets the simulator to the specified sdk.\n\n", sdkArg);

	printf(argFmt "s The previously compiled .app file which contains your app.\n", "app-file");
	printf(argFmt "s This must have Simon's static librarystory files and implementation\n", "");
	printf(argFmt "s code included for the test run to work.\n\n", "");
	
	printf(argFmt "s Any args that should be passed to the app when it is started.\n", "app-args...");
	
}
