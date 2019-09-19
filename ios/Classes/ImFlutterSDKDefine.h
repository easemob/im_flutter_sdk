//
//  ImFlutterSDKDefine.h
//  
//
//  Created by 杜洁鹏 on 2019/9/12.
//

#import <Foundation/Foundation.h>

static NSString *EMMethodKeyInit = @"init";
static NSString *EMMethodKeyConnect = @"connect";
static NSString *EMMethodKeyDisconnect = @"disconnect";
static NSString *RCMethodKeyConfig = @"config";
static NSString *RCMethodKeySendMessage = @"sendMessage";
static NSString *RCMethodKeyRefreshUserInfo = @"refreshUserInfo";
static NSString *RCMethodKeyJoinChatRoom = @"joinChatRoom";
static NSString *RCMethodKeyQuitChatRoom = @"quitChatRoom";
static NSString *RCMethodKeyGetHistoryMessage = @"getHistoryMessage";
static NSString *RCMethodKeyGetMessage = @"GetMessage";
static NSString *RCMethodKeyGetConversationList = @"getConversationList";
static NSString *RCMethodKeyGetChatRoomInfo = @"getChatRoomInfo";
static NSString *RCMethodKeyClearMessagesUnreadStatus = @"clearMessagesUnreadStatus";
static NSString *RCMethodKeySetServerInfo = @"setServerInfo";
static NSString *RCMethodKeySetCurrentUserInfo = @"setCurrentUserInfo";
static NSString *RCMethodKeyInsertIncomingMessage = @"insertIncomingMessage";
static NSString *RCMethodKeyInsertOutgoingMessage = @"insertOutgoingMessage";
static NSString *RCMethodKeyGetTotalUnreadCount = @"getTotalUnreadCount";
static NSString *RCMethodKeyGetUnreadCountTargetId = @"getUnreadCountTargetId";
static NSString *RCMethodKeyGetUnreadCountConversationTypeList = @"getUnreadCountConversationTypeList";
static NSString *RCMethodKeySetConversationNotificationStatus = @"setConversationNotificationStatus";
static NSString *RCMethodKeyGetConversationNotificationStatus = @"getConversationNotificationStatus";
static NSString *RCMethodKeyRemoveConversation = @"RemoveConversation";
static NSString *RCMethodKeyDeleteMessages = @"DeleteMessages";
static NSString *RCMethodKeyDeleteMessageByIds = @"DeleteMessageByIds";
static NSString *RCMethodKeyAddToBlackList = @"AddToBlackList";
static NSString *RCMethodKeyRemoveFromBlackList = @"RemoveFromBlackList";
static NSString *RCMethodKeyGetBlackListStatus = @"GetBlackListStatus";
static NSString *RCMethodKeyGetBlackList = @"GetBlackList";