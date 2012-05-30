

#import <UIKit/UIKit.h>

// If you are using the framework
#import <GHUnitIOS/GHUnitIOSAppDelegate.h>

int main(int argc, char *argv[]) {
  
  
 NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  // Register any special test case classes
  //[[GHTesting sharedInstance] registerClassName:@"GHSpecialTestCase"];  
  
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([GHUnitIOSAppDelegate class]));
  [pool release];
  return retVal;
}
