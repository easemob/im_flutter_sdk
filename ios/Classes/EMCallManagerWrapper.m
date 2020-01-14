//
//  EMCallManagerWrapper.m
//  device_info
//
//  Created by easemob-DN0164 on 2020/1/14.
//

#import "EMCallManagerWrapper.h"
#import "EMSDKMethod.h"
#import "EM1v1CallViewController.h"
#import "DemoCallManager.h"

@implementation EMCallManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                           registrar:registrar]) {
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call
                  result:(FlutterResult)result {
    if ([EMMethodKeyStartCall isEqualToString:call.method]) {
        [self startCall:call.arguments result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}

- (void)startCall:(NSDictionary *)param result:(FlutterResult)result {
    EMCallType callType = [param[@"callType"] intValue];
    NSString *remoteName = param[@"remoteName"];
    BOOL isRecord = [param[@"record"] boolValue];
    BOOL isMerge = [param[@"mergeStream"] boolValue];
    NSString *ext = param[@"ext"];
    
    
    [[DemoCallManager sharedManager] _makeCallWithUsername:remoteName type:callType record:isRecord mergeStream:isMerge ext:ext isCustomVideoData:NO];
    
//    [[EMClient sharedClient].callManager startCall:callType
//                                        remoteName:remoteName
//                                            record:isRecord
//                                       mergeStream:isMerge
//                                               ext:ext
//                                        completion:^(EMCallSession *aCallSession, EMError *aError) {
//
//        [self wrapperCallBack:result
//                        error:aError
//                     userInfo:nil];
//    }];
}
@end
