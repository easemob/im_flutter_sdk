//
//  EMUserInfoManagerWrapper.m
//  im_flutter_sdk
//
//  Created by liujinliang on 2021/4/26.
//

#import "UserInfoManagerWrapper.h"
#import "ClientWrapper.h"
#import "MethodKeys.h"
#import "UserInfoHelper.h"
#import "ListenerHandle.h"

@interface UserInfoManagerWrapper () <EMUserInfoManagerDelegate>

@end

// Android 5.0 updateOwnInfoByAttribute 返回 JSON 字符串；iOS 原生返回 EMUserInfo。
static NSString *androidUserInfoTypeResult(EMUserInfo *userInfo) {
    NSDictionary *payload = @{
        @"gender": [NSString stringWithFormat:@"%ld", (long)userInfo.gender],
        @"nickname": userInfo.nickname ?: @"",
        @"sign": userInfo.sign ?: @"",
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload
                                                     options:NSJSONWritingSortedKeys
                                                       error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@implementation UserInfoManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    
    if(self = [super initWithChannelName:aChannelName
                           registrar:registrar]) {
        [EMClient.sharedClient.userInfoManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

#pragma mark - EMUserInfoManagerDelegate
- (void)onSelfUserInfoUpdate:(EMUserInfo * _Nonnull)aUserInfo {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        [weakSelf.channel invokeMethod:ChatOnSelfUserInfoUpdate arguments:[aUserInfo toJson]];
    }];
}

- (void)onUserInfoUpdate:(NSDictionary<NSString *, EMUserInfo *> * _Nonnull)aUserInfos {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSMutableArray *list = [NSMutableArray array];
        for (EMUserInfo *info in aUserInfos.allValues) {
            [list addObject:[info toJson]];
        }
        [weakSelf.channel invokeMethod:ChatOnUserInfoUpdate arguments:list];
    }];
}


#pragma mark - FlutterPlugin
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:ChatUpdateOwnUserInfo]) {
        [self updateOwnUserInfo:call.arguments channelName:call.method result:result];
    }
    
    if ([call.method isEqualToString:ChatUpdateOwnUserInfoWithType]) {
        [self updateOwnUserInfoWithType:call.arguments
                            channelName:call.method
                                 result:result];
    }
    
    if ([call.method isEqualToString:ChatFetchUserInfoById]) {
        [self fetchUserInfoById:call.arguments
                    channelName:call.method
                         result:result];
    }
    
    if ([call.method isEqualToString:ChatFetchUserInfoByIdWithType]) {
        [self fetchUserInfoByIdWithType:call.arguments
                            channelName:call.method
                                 result:result];
    }
    
    if ([call.method isEqualToString:ChatGetUserInfoWithUserId]) {
        [self getUserInfoWithUserId:call.arguments channelName:call.method result:result];
    }
    if ([call.method isEqualToString:ChatGetUserInfoWithUserIds]) {
        [self getUserInfoWithUserIds:call.arguments channelName:call.method result:result];
    }
    if ([call.method isEqualToString:ChatSubscribeUsersInfo]) {
        [self subscribeUsersInfo:call.arguments channelName:call.method result:result];
    }
    if ([call.method isEqualToString:ChatUnsubscribeUsersInfo]) {
        [self unsubscribeUsersInfo:call.arguments channelName:call.method result:result];
    }
    if ([call.method isEqualToString:ChatFetchSubscribedUsers]) {
        [self fetchSubscribedUsers:call.arguments channelName:call.method result:result];
    }
    
}


- (void)updateOwnUserInfo:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    // 【透传原生】不本地检查登录（原生处理）
    NSString *usenrame = EMClient.sharedClient.currentUsername;
    
    EMUserInfo *userInfo = [EMUserInfo fromJson:param];
    userInfo.userId = usenrame;
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
        __strong typeof (self)strongSelf = weakSelf;
        NSString *objDic = aError ? nil : androidUserInfoTypeResult(aUserInfo);
        [strongSelf wrapperCallBack:result
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
                          channelName:ChatFetchUserInfoByIdWithType
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


- (void)getUserInfoWithUserId:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSArray *userIds = @[param[@"userId"]];
    [EMClient.sharedClient.userInfoManager fetchUserInfoById:userIds completion:^(NSDictionary<NSString *,EMUserInfo *> * _Nullable aUserDatas, EMError * _Nullable aError) {
        EMUserInfo *info = aUserDatas[param[@"userId"]];
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:info ? [info toJson] : nil];
    }];
}

- (void)getUserInfoWithUserIds:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    // 对齐 names 表：本地批量获取 = getUserInfoByIds（不是服务端 fetchUserInfoById）
    __weak typeof(self) weakSelf = self;
    NSDictionary<NSString *, EMUserInfo *> *aUserDatas = [EMClient.sharedClient.userInfoManager getUserInfoByIds:param[@"userIds"]];
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    [aUserDatas enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EMUserInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        map[key] = [obj toJson];
    }];
    [weakSelf wrapperCallBack:result channelName:aChannelName error:nil object:map];
}

- (void)subscribeUsersInfo:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.userInfoManager subscribeUsersInfo:param[@"userIds"] completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:nil];
    }];
}

- (void)unsubscribeUsersInfo:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.userInfoManager unsubscribeUsersInfo:param[@"userIds"] completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result channelName:aChannelName error:aError object:nil];
    }];
}

- (void)fetchSubscribedUsers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [EMClient.sharedClient.userInfoManager fetchSubscribedUsers:^(NSArray<EMUserInfo *> * _Nullable users, EMError * _Nullable error) {
        NSMutableArray *list = [NSMutableArray array];
        for (EMUserInfo *info in users) {
            [list addObject:[info toJson]];
        }
        [weakSelf wrapperCallBack:result channelName:aChannelName error:error object:list];
    }];
}

@end
