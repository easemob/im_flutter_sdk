//
//  EMWrapper.h
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMWrapper : NSObject <FlutterPlugin>
@property (strong, nonatomic) FlutterMethodChannel *channel;
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar;
@end

NS_ASSUME_NONNULL_END
