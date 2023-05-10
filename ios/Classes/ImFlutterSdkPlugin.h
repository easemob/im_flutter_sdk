#import <Flutter/Flutter.h>

@interface ImFlutterSdkPlugin : NSObject<FlutterPlugin>
- (void)sendDataToFlutter:(NSDictionary *)aData;
@end
