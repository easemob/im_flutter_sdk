//
//  EMWrapper.h
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import <Flutter/Flutter.h>
#import <Hyphenate/Hyphenate.h>

NS_ASSUME_NONNULL_BEGIN

# define NSLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface EMWrapper : NSObject <FlutterPlugin>
@property (strong, nonatomic) FlutterMethodChannel *channel;
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar;



- (void)wrapperCallBack:(FlutterResult)result
                    error:(EMError *__nullable)error
                 userInfo:(NSObject *__nullable)userInfo;

@end



NS_ASSUME_NONNULL_END
