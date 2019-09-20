//
//  ImFlutterSDKLog.h
//  
//
//  Created by 杜洁鹏 on 2019/9/20.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImFlutterSDKLog : NSObject<FlutterPlugin>

+ (ImFlutterSDKLog *)registrar:(NSObject<FlutterPluginRegistrar>*)registrar;

+ (void)logD:(NSString *)aLog;
+ (void)logE:(NSString *)aLog;
@end

NS_ASSUME_NONNULL_END
