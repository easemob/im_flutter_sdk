#import <Flutter/Flutter.h>

@interface ImFlutterSdkPlugin : NSObject<FlutterPlugin>
@property (strong, nonatomic) FlutterMethodChannel *channel;
- (instancetype)initWithChannel:(FlutterMethodChannel *)aChannel;
@end

@interface ImClientPlugin : ImFlutterSdkPlugin
@end

@interface ImChatManagerPlugin : ImFlutterSdkPlugin
@end

@interface ImContactManagerPlugin : ImFlutterSdkPlugin
@end

@interface ImGroupManagerPlugin : ImFlutterSdkPlugin
@end

@interface ImChatRoomManagerPlugin : ImFlutterSdkPlugin
@end

