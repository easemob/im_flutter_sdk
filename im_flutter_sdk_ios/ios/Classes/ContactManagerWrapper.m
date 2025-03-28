//
//  EMContactManagerWrapper.m
//
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ContactManagerWrapper.h"
#import "MethodKeys.h"
#import "ListenerHandle.h"
#import "ContactHelper.h"
#import "CursorResultHelper.h"

@interface ContactManagerWrapper () <EMContactManagerDelegate>

@end

@implementation ContactManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [EMClient.sharedClient.contactManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

- (void)unRegisterEaseListener {
    [EMClient.sharedClient.contactManager removeDelegate:self];
}


#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([ChatAddContact isEqualToString:call.method]) {
        [self addContact:call.arguments
             channelName:call.method
                  result:result];
    } else if ([ChatDeleteContact isEqualToString:call.method]) {
        [self deleteContact:call.arguments
                channelName:call.method
                     result:result];
    } else if ([ChatGetAllContactsFromServer isEqualToString:call.method]) {
        [self getAllContactsFromServer:call.arguments
                           channelName:call.method
                                result:result];
    } else if ([ChatGetAllContactsFromDB isEqualToString:call.method]) {
        [self getAllContactsFromDB:call.arguments
                       channelName:call.method
                            result:result];
    } else if ([ChatAddUserToBlockList isEqualToString:call.method]) {
        [self addUserToBlockList:call.arguments
                     channelName:call.method
                          result:result];
    } else if ([ChatRemoveUserFromBlockList isEqualToString:call.method]) {
        [self removeUserFromBlockList:call.arguments
                          channelName:call.method
                               result:result];
    } else if ([ChatGetBlockListFromServer isEqualToString:call.method]) {
        [self getBlockListFromServer:call.arguments
                         channelName:call.method
                              result:result];
    } else if ([ChatGetBlockListFromDB isEqualToString:call.method]){
        [self getBlockListFromDB:call.arguments
                     channelName:call.method
                          result:result];
    } else if ([ChatAcceptInvitation isEqualToString:call.method]) {
        [self acceptInvitation:call.arguments
                   channelName:call.method
                        result:result];
    } else if ([ChatDeclineInvitation isEqualToString:call.method]) {
        [self declineInvitation:call.arguments
                    channelName:call.method
                         result:result];
    } else if ([ChatGetSelfIdsOnOtherPlatform isEqualToString:call.method]) {
        [self getSelfIdsOnOtherPlatform:call.arguments
                            channelName:call.method
                                 result:result];
    } else if ([ChatGetAllContacts isEqualToString:call.method]) {
        [self getAllContacts:call.arguments
                            channelName:call.method
                                 result:result];
    } else if ([ChatSetContactRemark isEqualToString:call.method]) {
        [self setContactRemark:call.arguments
                            channelName:call.method
                                 result:result];
    } else if ([ChatGetContact isEqualToString:call.method]) {
        [self getContact:call.arguments
                            channelName:call.method
                                 result:result];
    } else if ([ChatFetchAllContacts isEqualToString:call.method]) {
        [self fetchAllContacts:call.arguments
                            channelName:call.method
                                 result:result];
    } else if ([ChatFetchContacts isEqualToString:call.method]) {
        [self fetchContacts:call.arguments
                            channelName:call.method
                                 result:result];
    } else {
        [super handleMethodCall:call result:result];
    }
}


#pragma mark - Actions
- (void)addContact:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *reason = param[@"reason"];
    [EMClient.sharedClient.contactManager addContact:username
                                             message:reason
                                          completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aUsername];
    }];
}

- (void)deleteContact:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    BOOL keepConversation = [param[@"keepConversation"] boolValue];
    [EMClient.sharedClient.contactManager deleteContact:username
                                   isDeleteConversation:keepConversation
                                             completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aUsername];
    }];
}

- (void)getAllContactsFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)getAllContactsFromDB:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSArray *aList = EMClient.sharedClient.contactManager.getContacts;
    [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:nil
                       object:aList];
}


- (void)addUserToBlockList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager addUserToBlackList:username
                                                  completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aUsername];
    }];
}

- (void)removeUserFromBlockList:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager removeUserFromBlackList:username
                                                       completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aUsername];
    }];
    
}

- (void)getBlockListFromServer:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}

- (void)getBlockListFromDB:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    NSArray * list = [EMClient.sharedClient.contactManager getBlackList];
    [self wrapperCallBack:result channelName:aChannelName error:nil object:list];
}

- (void)acceptInvitation:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager approveFriendRequestFromUser:username
                                                            completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aUsername];
    }];
}

- (void)declineInvitation:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    [EMClient.sharedClient.contactManager declineFriendRequestFromUser:username
                                                            completion:^(NSString *aUsername, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aUsername];
    }];
}

- (void)getSelfIdsOnOtherPlatform:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getSelfIdsOnOtherPlatformWithCompletion:^(NSArray *aList, EMError *aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:aList];
    }];
}


- (void)getAllContacts:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    
    NSArray* contacts = [EMClient.sharedClient.contactManager getAllContacts];
    
    NSMutableArray *contactList = [NSMutableArray array];
    for (EMContact *contact in contacts) {
        [contactList addObject:[contact toJson]];
    }
    
    [self wrapperCallBack:result
              channelName:aChannelName
                    error:nil
                   object:contactList];
}

///
- (void)setContactRemark:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    
    NSString *userId = param[@"userId"];
    NSString *remark = param[@"remark"];
    
    [EMClient.sharedClient.contactManager setContactRemark:userId
                                                    remark:remark
                                                completion:^(EMContact * _Nullable contact, EMError * _Nullable aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:nil];
    }];
}


- (void)getContact:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    NSString *userId = param[@"userId"];
    EMContact *contact = [EMClient.sharedClient.contactManager getContact:userId];
    [self wrapperCallBack:result
              channelName:aChannelName
                    error:nil
                   object:[contact toJson]];
}

- (void)fetchAllContacts:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient.contactManager getAllContactsFromServerWithCompletion:^(NSArray<EMContact *> * _Nullable aList, EMError * _Nullable aError) {
        NSMutableArray *contactList = [NSMutableArray array];
        for (EMContact *contact in aList) {
            [contactList addObject:[contact toJson]];
        }
        
        [weakSelf wrapperCallBack:result
                  channelName:aChannelName
                        error:aError
                       object:contactList];
    }];
}


- (void)fetchContacts:(NSDictionary *)param channelName:(NSString *)aChannelName result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString *cursor = param[@"cursor"];
    int pageSize = [param[@"pageSize"] intValue];
    [EMClient.sharedClient.contactManager getContactsFromServerWithCursor:cursor
                                                                 pageSize:pageSize
                                                               completion:^(EMCursorResult<EMContact *> * _Nullable aResult, EMError * _Nullable aError)
     {
        [weakSelf wrapperCallBack:result
                      channelName:aChannelName
                            error:aError
                           object:[aResult toJson]];
    }];
}


#pragma mark - EMContactManagerDelegate

- (void)friendshipDidAddByUser:(NSString *)aUsername {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onContactAdded",
            @"username":aUsername
        };
        [weakSelf.channel invokeMethod:ChatOnContactChanged arguments:map];
    }];

}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onContactDeleted",
            @"username":aUsername
        };
        [weakSelf.channel invokeMethod:ChatOnContactChanged arguments:map];
    }];
}

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onContactInvited",
            @"username":aUsername,
            @"reason":aMessage
        };
        [weakSelf.channel invokeMethod:ChatOnContactChanged arguments:map];
    }];

}

- (void)friendRequestDidApproveByUser:(NSString *)aUsername {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onFriendRequestAccepted",
            @"username":aUsername
        };
        [weakSelf.channel invokeMethod:ChatOnContactChanged arguments:map];
    }];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername {
    __weak typeof(self) weakSelf = self;
    [ListenerHandle.sharedInstance addHandle:^{
        NSDictionary *map = @{
            @"type":@"onFriendRequestDeclined",
            @"username":aUsername
        };
        [weakSelf.channel invokeMethod:ChatOnContactChanged arguments:map];
    }];
}

@end
