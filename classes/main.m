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

#define ARG_HELP @"-?"
#define ARG_REPORT_DIR @"-report-dir"

// Function declarations.
int processCmdArgs(PIPieman *pieman, int argc, const char * argv[]);
int getPort(NSString *portArg, int *argIdx, int argc, const char *argv[]);
int portFromValue(NSString *value, const char *portName);
void printHelp(void);

int main(int argc, const char * argv[]) {
	
	int exitCode = EXIT_SUCCESS;
	@autoreleasepool {
		
		// Check for help.
		if ([[NSProcessInfo processInfo] isArgumentPresentWithName:ARG_HELP]) {
			printHelp();
			return EXIT_SUCCESS;
		}
		
		PIPieman *pieman = [[[PIPieman alloc] init] autorelease];
		
		// Process arguments.
		if (processCmdArgs(pieman, argc, argv) == EXIT_FAILURE) {
			printf("Exiting\n");
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
		
		// Ignore help.
		if ([arg isEqualToString: ARG_HELP]) {
			continue;
		}
		
		// Check for the pieman port.
		if ([arg isEqualToString: ARG_PIEMAN_PORT]) {
			int port = getPort(ARG_PIEMAN_PORT, &i, argc, argv);
			pieman.piemanPort = port;
			continue;
		}
		
		// Check for Simon port.
		if ([arg isEqualToString: ARG_PIEMAN_PORT]) {
			int port = getPort(ARG_PIEMAN_PORT, &i, argc, argv);
			pieman.simonPort = port;
			continue;
		}
		
		// If the arg starts with '-' is an unknown arg.
		if ([arg hasPrefix:@"-"]) {
			printf("Error: Unknown argument %s", argv[i]);
			return EXIT_FAILURE;
		}
		
		// Finally it must be the app file name.
		pieman.appPath = [arg stringByExpandingTildeInPath];
		if (![[NSFileManager defaultManager] fileExistsAtPath:pieman.appPath]) {
			printf("Error: App file '%s' does not exist.", [pieman.appPath UTF8String]);
			return EXIT_FAILURE;
		}
		appArgFound = YES;
		
	}
	
	// Set the args.
	pieman.appArgs = appArguments;
	
	return EXIT_SUCCESS;
	
}

int getPort(NSString *portArg, int *argIdx, int argc, const char *argv[]) {
	
	// Error if no more args.
	if (*argIdx >= argc) {
		printf("Error: expected a port value for %s", [portArg UTF8String]);
		return EXIT_FAILURE;
	}
	
	// Error if value is another argument.
	const char *portValue = argv[*argIdx + 1];
	char first = portValue[0];
	if (first == '-') {
		printf("Error: expected a port value for %s but found another argument instead.", [portArg UTF8String]);
		return EXIT_FAILURE;
	}
	
	int port = atoi(portValue);
	
	// error if it's not a number.
	if (port == 0) {
		printf("Error: Passed %s port is not a valid integer.", [portArg UTF8String]);
		return EXIT_FAILURE;
	}
	
	// increment index and return.
	*argIdx = *argIdx + 1;
	return port;
}

void printHelp() {
	
	const char *piemanArg = [[NSString stringWithFormat:@"%@ n", ARG_PIEMAN_PORT] UTF8String];
	const char *simonArg = [[NSString stringWithFormat:@"%@ n", ARG_SIMON_PORT] UTF8String];
	const char *reportDirArg = [[NSString stringWithFormat:@"%@ path", ARG_REPORT_DIR] UTF8String];
	
	printf("The Pieman - Simon's mentor\n");
	printf("===========================\n\n");
	
	printf("The Pieman's job is to start and manage Simon test suites running in an iOS simulator.\n");
	printf("This is particularly useful when running on a Continuous Integeration (CI) machine which\n");
	printf("builds and runs software on a regular basis. \n");
	
	printf("\nSyntax: pieman [%1$s] [%2$s] [%3$s] [%4$s] app-file app-args...\n",
			 [ARG_HELP UTF8String],
			 piemanArg,
			 simonArg,
			 reportDirArg);
	
	printf("\nArguments\n");
	printf("---------\n\n");
	
	printf("%1$-18s Prints this help information.\n\n", [ARG_HELP UTF8String]);
	
	printf("%1$-18s Overrides the default HTTP port that the Pieman is listening\n", piemanArg);
	printf("%2$-18s for test results from Simon on. Defaults to %1$i\n\n", HTTP_PIEMAN_PORT, "");
	
	printf("%1$-18s Overrides the default HTTP port that Smon is listening on for\n", simonArg);
	printf("%2$-18s instructions from the Pieman on. Defaults to %1$i\n\n", HTTP_SIMON_PORT, "");
	
	printf("%1$-18s Sets the output path where test reports are written to.\n\n", reportDirArg);
	
	printf("%1$-18s The previously compiled .app file which contains your app.\n", "app-file");
	printf("%1$-18s This must have Simon's static librarystory files and implementation\n", "");
	printf("%1$-18s code included for the test run to work.\n\n", "");
	
	printf("%1$-18s Any args that should be passed to the app when it is started.\n", "app-args...");
	
}
