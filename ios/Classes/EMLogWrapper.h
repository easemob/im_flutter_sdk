//
//  EMLogWrapper.h
//  
//
//  Created by 杜洁鹏 on 2019/10/14.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMLogWrapper : NSObject <FlutterPlugin>

+ (EMLogWrapper *)registrar:(NSObject<FlutterPluginRegistrar>*)registrar;

+ (void)logD:(NSString *)aLog;
+ (void)logE:(NSString *)aLog;
@end

NS_ASSUME_NONNULL_END
