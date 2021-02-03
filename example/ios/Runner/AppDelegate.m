#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "EMCallPlugin.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    // 必须写在im sdk plugin register 之后。
    [EMCallPlugin registerWithRegistrar:[self registrarForPlugin:@"EMCallPlugin"]];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
