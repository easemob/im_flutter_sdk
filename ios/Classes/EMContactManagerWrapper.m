//
//  EMContactManagerWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMContactManagerWrapper.h"
#import "EMSDKMethod.h"

typedef enum : NSUInteger {
    CONTACT_ADD = 0,
    CONTACT_DELETE,
    INVITED,
    INVITATION_ACCEPTED,
    INVITATION_DECLINED
} EMContactEvent;

@interface EMContactManagerWrapper () <EMContactManagerDelegate>

@end

@implementation EMContactManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                                   registrar:registrar]) {
        
        [EMClient.sharedClient.contactManager addDelegate:self delegateQueue:nil];
    }
    return self;
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

       if ([EMMethodKeyAddContact isEqualToString:call.method]) {
           [self addContact:call.arguments result:result];
       }
       if ([EMMethodKeyDeleteContact isEqualToString:call.method]) {
           [self deleteContact:call.arguments result:result];
       }
       if ([EMMethodKeyGetAllContactsFromServer isEqualToString:call.method]) {
           [self getAllContactsFromServer:call.arguments result:result];
       }
       if ([EMMethodKeyAddUserToBlackList isEqualToString:call.method]) {
           [self addUserToBlackList:call.arguments result:result];
       }
       if ([EMMethodKeyRemoveUserFromBlackList isEqualToString:call.method]) {
           [self removeUserFromBlackList:call.arguments result:result];
       }
       if ([EMMethodKeyGetBlackListFromServer isEqualToString:call.method]) {
           [self getBlackListFromServer:call.arguments result:result];
       }
       if ([EMMethodKeySaveBlackList isEqualToString:call.method]) {
           [self saveBlackList:call.arguments result:result];
       }
       if ([EMMethodKeyAcceptInvitation isEqualToString:call.method]) {
           [self acceptInvitation:call.arguments result:result];
       }
       if ([EMMethodKeyDeclineInvitation isEqualToString:call.method]) {
           [self deleteContact:call.arguments result:result];
       } if ([EMMethodKeyGetSelfIdsOnOtherPlatform isEqualToString:call.method]) {
           [self getSelfIdsOnOtherPlatform:call.arguments result:result];
       } if ([EMMethodKeyOnContactChanged isEqualToString:call.method]) {
           [self onContactChanged:call.arguments result:result];
       } else {
           [super handleMethodCall:call result:result];
       }
}


#pragma mark - Actions
- (void)addContact:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    NSString *reason = param[@"reason"];
    [EMClient.sharedClient.contactManager addContact:userName
                                             message:reason
                                          completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                        error:aError
                     userInfo:aUsername];
    }];
}

- (void)deleteContact:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    BOOL keepConversation = [param[@"keepConversation"] boolValue];
    [EMClient.sharedClient.contactManager deleteContact:userName
                                   isDeleteConversation:keepConversation
                                             completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                        error:aError
                     userInfo:aUsername];
    }];
}

- (void)getAllContactsFromServer:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                        error:aError
                     userInfo:aList];
    }];
}

- (void)addUserToBlackList:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    [EMClient.sharedClient.contactManager addUserToBlackList:userName
                                                  completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                        error:aError
                     userInfo:aUsername];
    }];
}

- (void)removeUserFromBlackList:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    [EMClient.sharedClient.contactManager removeUserFromBlackList:userName
                                                       completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
           error:aError
        userInfo:aUsername];
    }];
                            
}

- (void)getBlackListFromServer:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:aList];
    }];
}

//??
- (void)saveBlackList:(NSDictionary *)param result:(FlutterResult)result {
    [self wrapperCallBack:result
                    error:nil
                 userInfo:nil];
}

- (void)acceptInvitation:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    [EMClient.sharedClient.contactManager approveFriendRequestFromUser:userName
                                                            completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                            error:aError
        userInfo:userName];
    }];
}

- (void)declineInvitation:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *userName = param[@"userName"];
    [EMClient.sharedClient.contactManager declineFriendRequestFromUser:userName
                                                            completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:userName];
    }];
}

- (void)getSelfIdsOnOtherPlatform:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getSelfIdsOnOtherPlatformWithCompletion:^(NSArray *aList, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                            error:aError
                         userInfo:aList];
    }];
}

// ??
- (void)onContactChanged:(NSDictionary *)param result:(FlutterResult)result {
    
}

#pragma mark - EMContactManagerDelegate

- (void)friendshipDidAddByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(CONTACT_ADD),
        @"userName":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(CONTACT_DELETE),
        @"userName":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage {
    NSDictionary *map = @{
        @"type":@(INVITED),
        @"userName":aUsername,
        @"reason":aMessage
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendRequestDidApproveByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(INVITATION_ACCEPTED),
        @"userName":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(INVITATION_DECLINED),
        @"userName":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

@end
