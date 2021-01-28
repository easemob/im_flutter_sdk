//
//  EMOptions+Flutter.m
//  im_flutter_sdk
//
//  Created by 杜洁鹏 on 2020/10/12.
//

#import "EMOptions+Flutter.h"
#import <HyphenateLite/EMOptions+PrivateDeploy.h>

@implementation EMOptions (Flutter)
- (NSDictionary *)toJson {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"appKey"] = self.appkey;
    data[@"autoLogin"] = @(self.isAutoLogin);
    data[@"debugModel"] = @(self.enableConsoleLog);
    data[@"requireAck"] = @(self.enableRequireReadAck);
    data[@"requireDeliveryAck"] = @(self.enableDeliveryAck);
    data[@"sortMessageByServerTime"] = @(self.sortMessageByServerTime);
    data[@"acceptInvitationAlways"] = @(self.isAutoAcceptFriendInvitation);
    data[@"autoAcceptGroupInvitation"] = @(self.isAutoAcceptGroupInvitation);
    data[@"deleteMessagesAsExitGroup"] = @(self.isDeleteMessagesWhenExitGroup);
    data[@"deleteMessagesAsExitChatRoom"] = @(self.isDeleteMessagesWhenExitChatRoom);
    data[@"isAutoDownload"] = @(self.isAutoDownloadThumbnail);
    data[@"isChatRoomOwnerLeaveAllowed"] = @(self.isChatroomOwnerLeaveAllowed);
    data[@"serverTransfer"] = @(self.isAutoTransferMessageAttachments);
    data[@"usingHttpsOnly"] = @(self.usingHttpsOnly);
    data[@"pushConfig"] = @{@"pushConfig": @{@"apnsCertName": self.apnsCertName}};
    data[@"enableDNSConfig"] = @(self.enableDnsConfig);
    data[@"imPort"] = @(self.chatPort);
    data[@"imServer"] = self.chatServer;
    data[@"restServer"] = self.restServer;
    data[@"dnsUrl"] = self.dnsURL;
    
    return data;
}
+ (EMOptions *)fromJson:(NSDictionary *)aJson {
    EMOptions *options = [EMOptions optionsWithAppkey:aJson[@"appKey"]];
    options.isAutoLogin = [aJson[@"autoLogin"] boolValue];
    options.enableConsoleLog = [aJson[@"debugModel"] boolValue];
    options.enableRequireReadAck = [aJson[@"requireAck"] boolValue];
    options.enableDeliveryAck = [aJson[@"requireDeliveryAck"] boolValue];
    options.sortMessageByServerTime = [aJson[@"sortMessageByServerTime"] boolValue];
    options.isAutoAcceptFriendInvitation = [aJson[@"acceptInvitationAlways"] boolValue];
    options.isAutoAcceptGroupInvitation = [aJson[@"autoAcceptGroupInvitation"] boolValue];
    options.isDeleteMessagesWhenExitGroup = [aJson[@"deleteMessagesAsExitGroup"] boolValue];
    options.isDeleteMessagesWhenExitChatRoom = [aJson[@"deleteMessagesAsExitChatRoom"] boolValue];
    options.isAutoDownloadThumbnail = [aJson[@"isAutoDownload"] boolValue];
    options.isChatroomOwnerLeaveAllowed = [aJson[@"isChatRoomOwnerLeaveAllowed"] boolValue];
    options.isAutoTransferMessageAttachments = [aJson[@"serverTransfer"] boolValue];
    options.usingHttpsOnly = [aJson[@"usingHttpsOnly"] boolValue];
    options.pushKitCertName = aJson[@"pushConfig"][@"apnsCertName"];
    options.enableDnsConfig = [aJson[@"enableDNSConfig"] boolValue];
    options.chatPort = [aJson[@"imPort"] intValue];
    options.chatServer = aJson[@"imServer"];
    options.restServer = aJson[@"restServer"];
    options.dnsURL = aJson[@"dnsURL"];
    
    return options;
}
@end
