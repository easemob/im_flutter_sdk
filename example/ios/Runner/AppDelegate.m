#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#import <im_flutter_sdk/ImFlutterSdkPlugin.h>

#import "EMCallPlugin.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    
    [EMCallPlugin registerWithRegistrar:[self registrarForPlugin:@"EMCallPlugin"]];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
