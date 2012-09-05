/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

@class DTiPhoneSimulatorApplicationSpecifier, DTiPhoneSimulatorSystemRoot, NSArray, NSDictionary, NSFileHandle, NSNumber, NSString;

@interface DTiPhoneSimulatorSessionConfig : NSObject <NSCopying>
{
	NSString *_localizedClientName;
	DTiPhoneSimulatorSystemRoot *_simulatedSystemRoot;
	NSNumber *_simulatedDeviceFamily;
	DTiPhoneSimulatorApplicationSpecifier *_applicationToSimulateOnStart;
	NSArray *_simulatedApplicationLaunchArgs;
	NSDictionary *_simulatedApplicationLaunchEnvironment;
	BOOL _simulatedApplicationShouldWaitForDebugger;
	NSString *_simulatedApplicationStdOutPath;
	NSString *_simulatedApplicationStdErrPath;
}

+ (id)displayNameForDeviceFamily:(id)arg1;
@property(copy) NSString *simulatedApplicationStdErrPath; // @synthesize simulatedApplicationStdErrPath=_simulatedApplicationStdErrPath;
@property(copy) NSString *simulatedApplicationStdOutPath; // @synthesize simulatedApplicationStdOutPath=_simulatedApplicationStdOutPath;
@property BOOL simulatedApplicationShouldWaitForDebugger; // @synthesize simulatedApplicationShouldWaitForDebugger=_simulatedApplicationShouldWaitForDebugger;
@property(copy) NSDictionary *simulatedApplicationLaunchEnvironment; // @synthesize simulatedApplicationLaunchEnvironment=_simulatedApplicationLaunchEnvironment;
@property(copy) NSArray *simulatedApplicationLaunchArgs; // @synthesize simulatedApplicationLaunchArgs=_simulatedApplicationLaunchArgs;
@property(copy) DTiPhoneSimulatorApplicationSpecifier *applicationToSimulateOnStart; // @synthesize applicationToSimulateOnStart=_applicationToSimulateOnStart;
@property(copy) NSNumber *simulatedDeviceFamily; // @synthesize simulatedDeviceFamily=_simulatedDeviceFamily;
@property(copy) DTiPhoneSimulatorSystemRoot *simulatedSystemRoot; // @synthesize simulatedSystemRoot=_simulatedSystemRoot;
@property(copy) NSString *localizedClientName; // @synthesize localizedClientName=_localizedClientName;
- (id)description;
- (void)dealloc;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)init;

@end

