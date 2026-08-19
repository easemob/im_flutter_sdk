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

@implementation UserInfoManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    
    if(self = [super initWithChannelName:aChannelName
                           registrar:registrar]) {
        [EMClient.sharedClient.userInfoManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

- (void)unRegisterEaseListener {
    [EMClient.sharedClient.userInfoManager removeDelegate:self];
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
    
    // 4.22.0
    if ([call.method isEqualToString:ChatSubscribeUsersInfo]) {
        [self subscribeUsersInfo:call.arguments
                     channelName:call.method
                          result:result];
    }
    
    if ([call.method isEqualToString:ChatUnsubscribeUsersInfo]) {
        [self unsubscribeUsersInfo:call.arguments
                       channelName:call.method
                            result:result];
    }
    
    if ([call.method isEqualToString:ChatFetchSubscribedUsers]) {
        [self fetchSubscribedUsers:call.arguments
                       channelName:call.method
                            result:result];
    }
    
    if ([call.method isEqualToString:ChatGetLocalUserInfoByIds]) {
        [self getLocalUserInfoByIds:call.arguments
                        channelName:call.method
                             result:result];
    }
    
}


- (void)updateOwnUserInfo:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *usenrame = EMClient.sharedClient.currentUsername;
    if (usenrame == nil) {
        EMError *error = [EMError errorWithDescription:@"User not login" code:EMErrorUserNotLogin];
        [weakSelf wrapperCallBack:result channelName:aChannelName error:error object:nil];
        return;
    }
    
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
        NSDictionary *objDic = [aUserInfo toJson];
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


#pragma mark - 4.22.0

- (void)subscribeUsersInfo:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSArray *userIds = param[@"userIds"];
    [EMClient.sharedClient.userInfoManager subscribeUsersInfo:userIds
                                                   completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)unsubscribeUsersInfo:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSArray *userIds = param[@"userIds"];
    [EMClient.sharedClient.userInfoManager unsubscribeUsersInfo:userIds
                                                     completion:^(EMError * _Nullable aError) {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}

- (void)fetchSubscribedUsers:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.userInfoManager fetchSubscribedUsers:^(NSArray<EMUserInfo *> * _Nullable users, EMError * _Nullable aError) {
        NSMutableArray *userList = [NSMutableArray array];
        for (EMUserInfo *userInfo in users) {
            [userList addObject:[userInfo toJson]];
        }
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:@{@"users": userList}];
    }];
}

- (void)getLocalUserInfoByIds:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSArray *userIds = param[@"userIds"];
    NSDictionary *userInfos = [EMClient.sharedClient.userInfoManager getUserInfoByIds:userIds];
    NSMutableDictionary *dic = NSMutableDictionary.new;
    [userInfos enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        dic[key] = [(EMUserInfo *)obj toJson];
    }];
    [self wrapperCallBack:result
              channelName:aChannelName
                    error:nil
                   object:[dic copy]];
}

#pragma mark - EMUserInfoManagerDelegate

- (void)onSelfUserInfoUpdate:(EMUserInfo *)aUserInfo {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onSelfUserInfoUpdate",
            @"userInfo":[aUserInfo toJson]
        };
        [weakSelf.channel invokeMethod:ChatOnUserInfoChanged arguments:map];
    }];
}

- (void)onUserInfoUpdate:(NSDictionary<NSString *, EMUserInfo *> *)aUserInfos {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSMutableArray *userList = [NSMutableArray array];
        for (EMUserInfo *userInfo in aUserInfos.allValues) {
            [userList addObject:[userInfo toJson]];
        }
        NSDictionary *map = @{
            @"type":@"onUserInfoUpdate",
            @"userInfos":userList
        };
        [weakSelf.channel invokeMethod:ChatOnUserInfoChanged arguments:map];
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
