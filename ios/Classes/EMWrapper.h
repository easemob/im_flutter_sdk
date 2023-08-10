//
//  EMWrapper.h
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import <Flutter/Flutter.h>
#import <HyphenateChat/HyphenateChat.h>
NS_ASSUME_NONNULL_BEGIN

#define EMChannelName(name) [NSString stringWithFormat:@"com.chat.im/%@", name]


@interface EMWrapper : NSObject <FlutterPlugin>

@property(nonatomic, strong) FlutterMethodChannel *channel;
@property(nonatomic, strong) NSObject<FlutterPluginRegistrar> *flutterPluginRegister;

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar> *)registrar;


- (void)wrapperCallBack:(FlutterResult)result
            channelName:(NSString *)aChannelName
                  error:(EMError *__nullable)error
                 object:(NSObject *__nullable)aObj;


- (void)unRegisterEaseListener;


@end

NS_ASSUME_NONNULL_END
