//
//  EMUserInfoManagerWrapper.m
//  im_flutter_sdk
//
//  Created by liujinliang on 2021/4/26.
//

#import "EMUserInfoManagerWrapper.h"
#import "EMClientWrapper.h"
#import "EMSDKMethod.h"
#import "EMUserInfo+Flutter.h"

@interface EMUserInfoManagerWrapper ()

@end

@implementation EMUserInfoManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    
    if(self = [super initWithChannelName:aChannelName
                           registrar:registrar]) {
    }
    return self;
}


#pragma mark - FlutterPlugin
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:EMMethodKeyUpdateOwnUserInfo]) {
        [self updateOwnUserInfo:call.arguments channelName:call.method result:result];
    }
    
    if ([call.method isEqualToString:EMMethodKeyUpdateOwnUserInfoWithType]) {
        [self updateOwnUserInfoWithType:call.arguments
                            channelName:call.method
                                 result:result];
    }
    
    if ([call.method isEqualToString:EMMethodKeyFetchUserInfoById]) {
        [self fetchUserInfoById:call.arguments
                    channelName:call.method
                         result:result];
    }
    
    if ([call.method isEqualToString:EMMethodKeyFetchUserInfoByIdWithType]) {
        [self fetchUserInfoByIdWithType:call.arguments
                            channelName:call.method
                                 result:result];
    }
    
}


- (void)updateOwnUserInfo:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    EMUserInfo *userInfo = [EMUserInfo fromJson:param[@"userInfo"]];
    [EMClient.sharedClient.userInfoManager updateOwnUserInfo:userInfo completion:^(EMUserInfo *aUserInfo, EMError *aError) {
        NSDictionary *objDic = [aUserInfo toJson];

        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:objDic];
    }];
}


- (void)updateOwnUserInfoWithType:(NSDictionary *)param channelName:(NSString *)aChannelName  result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    
    int typeValue = [param[@"userInfoType"] intValue];
    EMUserInfoType userInfoType = [self userInfoTypeFromInt:typeValue];
    NSString *userInfoValue = param[@"userInfoValue"];

    
    [EMClient.sharedClient.userInfoManager updateOwnUserInfo:userInfoValue withType:userInfoType completion:^(EMUserInfo *aUserInfo, EMError *aError) {
        
        NSDictionary *objDic = [aUserInfo toJson];
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:objDic];
    }];
   
}


- (void)fetchUserInfoById:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSArray *userIds = param[@"userIds"];
    
    [EMClient.sharedClient.userInfoManager fetchUserInfoById:userIds completion:^(NSDictionary *aUserDatas, EMError *aError) {
        
        NSMutableDictionary *dic = NSMutableDictionary.new;
        [aUserDatas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            dic[key] = [(EMUserInfo *)obj toJson];
        }];
                
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[dic copy]];
    }];
        
}



- (void)fetchUserInfoByIdWithType:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSArray *userIds = param[@"userIds"];
    NSArray<NSNumber *> *userInfoTypes = param[@"userInfoTypes"];

    [EMClient.sharedClient.userInfoManager fetchUserInfoById:userIds type:userInfoTypes completion:^(NSDictionary *aUserDatas, EMError *aError) {
            
        NSMutableDictionary *dic = NSMutableDictionary.new;
        [aUserDatas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            dic[key] = [(EMUserInfo *)obj toJson];
        }];
        
        
            [weakSelf wrapperCallBack:result
                          channelName:EMMethodKeyFetchUserInfoByIdWithType
                                error:aError
                               object:dic];
    }];

}


- (EMUserInfoType)userInfoTypeFromInt:(int)typeValue {
    EMUserInfoType userInfoType;
    
    switch (typeValue) {
        case 0:
            userInfoType = EMUserInfoTypeNickName;
            break;
        case 1:
            userInfoType = EMUserInfoTypeAvatarURL;
            break;
        case 2:
            userInfoType = EMUserInfoTypePhone;
            break;
        case 3:
            userInfoType = EMUserInfoTypeMail;
            break;
        case 4:
            userInfoType = EMUserInfoTypeGender;
            break;
        case 5:
            userInfoType = EMUserInfoTypeSign;
            break;
        case 6:
            userInfoType = EMUserInfoTypeBirth;
            break;
        case 7:
            userInfoType = EMUserInfoTypeExt;
            break;
        default:
            userInfoType = EMUserInfoTypeNickName;
            break;
    }
    
    return userInfoType;
}

@end
