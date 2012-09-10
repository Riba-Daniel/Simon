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

#define ARG_HELP "-?"
#define ARG_REPORT_DIR "-report-dir"

#define EXIT_HELP_PRINTED 999

// Function declarations.
int arguments(PIPieman *pieman, int argc, const char * argv[]);
int checkForPortArg(int argc, int *i, const char * argv[], const char *portName);
void printHelp(void);

int main(int argc, const char * argv[]) {
	
	int exitCode = EXIT_SUCCESS;
	@autoreleasepool {
		
		
		PIPieman *pieman = [[[PIPieman alloc] init] autorelease];
		
		// Process arguments.
		int continueRun = arguments(pieman, argc, argv);
		
		if (continueRun == EXIT_HELP_PRINTED) {
			return EXIT_SUCCESS;
		}
		if (continueRun != EXIT_SUCCESS) {
			printf("Exiting\n");
			return continueRun;
		}
		
		// Start the run.
		[pieman start];
		if (pieman.finished) {
			return pieman.finished;
		}
		
		NSRunLoop *loop = [NSRunLoop currentRunLoop];
		while (!pieman.finished && [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
			NSLog(@"Run loop cycling");
		};
		
		// get the final code.
		exitCode = pieman.exitCode;
		
	}
	return exitCode;
}

int arguments(PIPieman *pieman, int argc, const char * argv[]) {
	
	BOOL appArgFound = NO;
	NSMutableArray *args = [NSMutableArray array];
	for (int i = 1; i < argc; i++) {

		// Help
		if (strcmp(argv[i], ARG_HELP) == 0) {
			printHelp();
			return EXIT_HELP_PRINTED;
		}

		// Pieman port
		if (strcmp(argv[i], [ARG_PIEMAN_PORT UTF8String]) == 0) {
			pieman.piemanPort = checkForPortArg(argc, &i, argv, "Pieman");
			if (pieman.piemanPort == 0) {
				return EXIT_FAILURE;
			}
			continue;
		}

		// Simon port
		if (strcmp(argv[i], [ARG_SIMON_PORT UTF8String]) == 0) {
			pieman.simonPort = checkForPortArg(argc, &i, argv, "Simon");
			if (pieman.simonPort == 0) {
				return EXIT_FAILURE;
			}
			continue;
		}
		
		// If here then it must be the app.
		if (!appArgFound) {
			pieman.appPath = [[NSString stringWithUTF8String:argv[i]] stringByExpandingTildeInPath];
			appArgFound = YES;
			continue;
		} else {
			// It's an arg for the app.
			[args addObject:[NSString stringWithUTF8String:argv[i]]];
		}

	}
	
	// Set the args.
	pieman.appArgs = args;
	
	return EXIT_SUCCESS;
	
}

int checkForPortArg(int argc, int *i, const char *argv[], const char *portName) {
	if (*i + 1 == argc) {
		printf("Error - No %s port specified.", portName);
		return 0;
	}
	*i = *i + 1;
	int port = atoi(argv[*i]);
	if (port == 0) {
		printf("Error - Passed %s port is not a valid integer.", portName);
		return 0;
	}
	return port;
}

void printHelp() {
	
	const char *piemanArg = [[NSString stringWithFormat:@"%@ n", ARG_PIEMAN_PORT] UTF8String];
	const char *simonArg = [[NSString stringWithFormat:@"%@ n", ARG_SIMON_PORT] UTF8String];
	const char *reportDirArg = [[NSString stringWithFormat:@"%s path", ARG_REPORT_DIR] UTF8String];
	
	printf("The Pieman - Simon's mentor\n");
	printf("===========================\n\n");
	
	printf("The Pieman's job is to start and manage Simon test suites running in an iOS simulator.\n");
	printf("This is particularly useful when running on a Continuous Integeration (CI) machine which\n");
	printf("builds and runs software on a regular basis. \n");
	
	printf("\nSyntax: pieman [%1$s] [%2$s] [%3$s] [%4$s] app-file app-args...\n",
			 ARG_HELP,
			 piemanArg,
			 simonArg,
			 reportDirArg);
	
	printf("\nArguments\n");
	printf("---------\n\n");
	
	printf("%1$-18s Prints this help information.\n\n", ARG_HELP);
	
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
