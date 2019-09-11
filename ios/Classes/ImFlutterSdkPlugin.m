#import "ImFlutterSdkPlugin.h"

@implementation ImFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"im_flutter_sdk"
            binaryMessenger:[registrar messenger]];
  ImFlutterSdkPlugin* instance = [[ImFlutterSdkPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // ??
  if ([@"EMClient.getInstance().init()" isEqualToString:call.method]) {
    result(@"");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
