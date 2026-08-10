/**
 *  \~chinese
 *  @header EMMultiDevicesDelegate.h
 *  @abstract 多设备代理协议
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMMultiDevicesDelegate.h
 *  @abstract This protocol defined the callbacks of Multi-device
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMConversation.h"

/**
 *  \~chinese
 *  多设备登录事件类型。
 * 
 *  本枚举类以用户 A 同时登录设备 A1 和 设备 A2 为例，描述多设备登录各事件的触发时机。
 *
 *  \~english
 *  Multi-device event types.
 * 
 *  This enumeration takes user A logged into both device A1 and device A2 as an example to illustrate the various multi-device event types and when these events are triggered.
 */
typedef NS_ENUM(NSInteger, EMMultiDevicesEvent) {
    EMMultiDevicesEventUnknow = -1,         /** \~chinese 默认。 \~english Default. */
    EMMultiDevicesEventContactRemove = 2,    /** \~chinese 用户 A 在设备 A1 上删除了好友，则设备 A2 上会收到该事件。 \~english If user A deletes a contact on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventContactAccept = 3,    /** \~chinese 用户 A 在设备 A1 上同意了其他用户的好友请求，则设备 A2 上会收到该事件。 \~english If user A accepts a contact invitation on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventContactDecline = 4,   /** \~chinese 用户 A 在设备 A1 上拒绝了其他用户的好友请求，则设备 A2 上会收到该事件。 \~english If user A declines a contact invitation on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventContactBan = 5,       /** \~chinese 用户 A 在设备 A1 上将其他用户加入黑名单，则设备 A2 上会收到该事件。 \~english If user A adds another user into the block list on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventContactAllow = 6,     /** \~chinese 用户 A 在设备 A1 上将某用户移出黑名单，则设备 A2 上会收到该事件。 \~english If user A removes a user from the block list on device A1, this event is triggered on device A2. */
    
    EMMultiDevicesEventGroupCreate = 10,     /** \~chinese 用户 A 在设备 A1 上创建了群组，则设备 A2 上会收到该事件。\~english If user A creates a chat group on Device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupDestroy = 11,    /** \~chinese 用户 A 在设备 A1 上销毁了群组，则设备 A2 上会收到该事件。 \~english If user A destroys a chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupJoin = 12,       /** \~chinese 用户 A 在设备 A1 上加入了群组，则设备 A2 会收到该事件。 \~english If user A joins a chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupLeave = 13,      /** \~chinese 用户 A 在设备 A1 上退出群组，则设备 A2 会收到该事件。 \~english If user A leaves a chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupApply = 14,      /** \~chinese 用户 A 在设备 A1 上申请加入群组，则设备 A2 会收到该事件。 \~english If user A requests to join a chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupApplyAccept = 15,    /** \~chinese 用户 A 在设备 A1 上收到了其他用户的入群申请，则设备 A2 会收到该事件。 \~english If user A receives another user's request to join the chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupApplyDecline = 16,   /** \~chinese 用户 A 在设备 A1 上拒绝了其他用户的入群申请，设备 A2 上会收到该事件。 \~english If user A declines another user's request to join the chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupInvite = 17,     /** \~chinese 用户 A 在设备 A1 上邀请了其他用户进入群组，则设备 A2 上会收到该事件。 \~english If user A invites other users to join the chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupInviteAccept = 18,   /** \~chinese 用户 A 在设备 A1 上同意了其他用户的群组邀请，则设备 A2 上会收到该事件。 \~english If user A accepts another user's group invitation on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupInviteDecline = 19,  /** \~chinese 用户 A 在设备 A1 上拒绝了其他用户的群组邀请，则设备 A2 上会收到该事件。 \~english If user A declines another user's group invitation on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupKick = 20,       /** \~chinese 用户 A 在设备 A1 上将其他用户踢出群组，则设备 A2 上会收到该事件。 \~english If user A removes other users from a chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupBan = 21,        /** \~chinese 用户 A 在设备 A1 上被加入黑名单，则设备 A2 上会收到该事件。 \~english If user A is added to the block list on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupAllow = 22,      /** \~chinese 用户 A 在设备 A1 上将其他用户移出群组，则设备 A2 上会收到该事件。 \~english If user A removes other users from a chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupBlock = 23,      /** \~chinese 用户 A 在设备 A1 上屏蔽了某个群组的消息，设备 A2 上会收到该事件。 \~english If user A blocks messages from a chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupUnBlock = 24,    /** \~chinese 用户 A 在设备 A1 上取消屏蔽了某个群组的消息，设备 A2 上会收到该事件。 \~english If user A unblocks messages from a chat group on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupAssignOwner = 25,    /** \~chinese 用户 A 在设备 A1 上更新了群组的群主，则设备 A2 上会收到该事件。 \~english If user A assigns a group owner on device A1, this event is triggered on device A2.*/
    EMMultiDevicesEventGroupAddAdmin = 26,   /** \~chinese 用户 A 在设备 A1 上添加了群组管理员，则设备 A2 上会收到该事件。 \~english If user A adds a group admin on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupRemoveAdmin = 27,    /** \~chinese 用户 A 在设备 A1 上移除了群组管理员，则设备 A2 上会收到该事件。 \~english If user A removes a group admin on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupAddMute = 28,    /** \~chinese 用户 A 在设备 A1 上禁言了群成员，则设备 A2 上会收到该事件。 \~english If user A mutes other group members on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupRemoveMute = 29,     /** \~chinese 用户 A 在设备 A1 上取消禁言了群成员，则设备 A2 上会收到该事件。 \~english If user A unmutes other group members in device A1, this event is triggered on device A2. */
    
    EMMultiDevicesEventGroupAddWhiteList = 30,  /** \~chinese 用户 A 在设备 A1 上添加了群成员进白名单，则设备 A2 上会收到该事件。 \~english If user A adds a group member to the allow list in device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupRemoveWhiteList = 31,   /** \~chinese 用户 A 在设备 A1 上从白名单移除群成员，则设备 A2 上会收到该事件。 \~english If user A removes a group member from the allow list on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupAllBan = 32,    /** \~chinese 用户 A 在设备 A1 上开启群组成员全体禁言，则设备 A2 上会收到该事件。 \~english If user A mutes all group members on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupRemoveAllBan = 33,  /** \~chinese 用户 A 在设备 A1 上取消禁言了群成员，则设备 A2 上会收到该事件。 \~english If user A unmutes all group members in device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupUpdate = 34, /** \~chinese 用户 A 在设备 A1 上更新了群组信息，则设备 A2 上会收到该事件。 \~english If user A updates group information on device A1, this event is triggered on device A2. */
    
    EMMultiDevicesEventChatThreadCreate = 40, /** \~chinese 用户 A 在设备 A1 创建子区，则设备 A2 上会收到该事件。  \~english  If user A creates a message thread on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventChatThreadDestroy = 41,/** \~chinese 用户 A 在设备 A1 销毁了子区，则设备 A2 上会收到该事件。 \~english  If user A destroys a message thread on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventChatThreadJoin = 42,/** \~chinese 用户 A 在设备 A1 加入了子区，则设备 A2 上会收到该事件。 \~english If user A joins a message thread on device A1, this event is triggered on device A2.*/
    EMMultiDevicesEventChatThreadLeave = 43,/** \~chinese 用户 A 在设备 A1 离开了子区，则设备 A2 上会收到该事件。 \~english If user A leaves a message thread on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventChatThreadUpdate = 44,/** \~chinese 用户 A 在设备 A1 更新子区，则设备 A2 上会收到该事件。 \~english If user A updates a message thread on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventChatThreadKick = 45,/** \~chinese 用户 A 在设备 A1 被踢出子区，则设备 A2 上会收到该事件。 \~english If user A is kicked out of a message thread on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventGroupMemberAttributesChanged = 52,/** \~chinese 用户 A 在设备 A1 上修改群成员自定义属性，则设备 A2 上会收到该事件。\~english If user A modifies a custom attribute of a group member on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventConversationPinned = 60, /** \~chinese 用户 A 在设备 A1 置顶会话，则设备 A2 上会收到该事件。 \~english If user A pins a conversation on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventConversationUnpinned = 61,/** \~chinese 用户 A 在设备 A1取消置顶会话，则设备 A2 上会收到该事件。 \~english If user A unpins a conversation on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventConversationDelete = 62,/** \~chinese 用户 A 在设备 A1 删除会话，则设备 A2 上会收到该事件。 \~english If user A deletes a conversation on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventConversationUpdateMark = 63, /** \~chinese 用户 A 在设备 A1 添加/删除会话标记，则设备 A2 上会收到该事件。 \~english If user A add/remove a conversation mark on device A1, this event is triggered on device A2. */
    EMMultiDevicesEventConversationMuteInfoChanged = 64, /** \~chinese 用户 A 在设备 A1 设置会话免打扰，则设备 A2 上会收到该事件。 \~english If user A sets the Do Not Disturb mode for a conversation on device A1, this event is triggered on device A2. */
};

@protocol EMMultiDevicesDelegate <NSObject>

@optional

/**
 *  \~chinese
 *  多设备好友事件回调。
 *
 *  @param aEvent       多设备事件类型。
 *  @param aUsername    用户名。
 *  @param aExt         扩展信息。
 *
 *  \~english
 *  The multi-device contact event callback.
 *
 *  @param aEvent       The event type.
 *  @param aUsername    The username.
 *  @param aExt         The extended Information.
 */
- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString * _Nonnull)aUsername
                                       ext:(NSString * _Nullable)aExt;

/**
 *  \~chinese
 *  多设备群组事件回调。
 *
 *  @param aEvent       多设备事件类型。
 *  @param aGroupId     群组 ID。
 *  @param aExt         扩展信息。
 *
 *  \~english
 *  The multi-device group event callback.
 *
 *  @param aEvent       The event type.
 *  @param aGroupId     The group ID.
 *  @param aExt         The extended Information.
 */
- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString * _Nonnull)aGroupId
                                     ext:(id _Nullable)aExt;
/*!
 *  \~chinese
 *  多设备子区事件回调。
 *
 *  @param aEvent       多设备事件类型。
 *  @param aThreadId    子区 ID。
 *  @param aExt         扩展信息。
 *
 *  \~english
 *  The multi-device message thread event callback.
 *
 *  @param aEvent       The event type.
 *  @param aThreadId    The message thread ID.
 *  @param aExt         The extended Information.
 */

- (void)multiDevicesChatThreadEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 threadId:(NSString * _Nonnull)aThreadId
                                     ext:(id _Nullable)aExt;

/*!
 *  \~chinese
 *  单个会话设置免打扰的多设备事件回调。
 *
 *  @param undisturbData         扩展信息。
 *
 *  \~english
 *  The multi-device event callback for setting the Do Not Disturb mode for a single conversation.
 *
 *  @param aEvent       The event type.
 *  @param undisturbData         The extended Information.
 */
- (void)multiDevicesUndisturbEventNotifyFormOtherDeviceData:(NSString *_Nullable)undisturbData __deprecated_msg("Use -multiDevicesConversationEvent:conversationId:conversationType: instead");
/*!
 *  \~chinese
 *  单个会话删除漫游消息的多设备事件回调。
 *
 *  @param conversationId     会话 ID。
 *  @param deviceId 设备 ID。
 *
 *  \~english
 *  The multi-device event callback for removing historical messages of a single conversation from the server.
 *
 *  @param conversationId       The conversation ID.
 *  @param deviceId        The device ID.
 */
-(void)multiDevicesMessageBeRemoved:(NSString *_Nonnull)conversationId deviceId:(NSString *_Nonnull)deviceId;

/*!
 *  \~chinese
 *  单个会话操作的多设备事件回调。用户在收到会话多设备事件时需要调用``IEMChatManager#getAllConversations``方法获取最新的会话列表。
 *
 *  @param event 事件类型。
 *  @param conversationId 会话 ID。
 *  @param conversationType 会话类型。
 *
 *  \~english
 *  The multi-device event callback for the operation of a single conversation.User needs to call the ``IEMChatManager#getAllConversations`` method to get the latest conversation list when receiving the conversation multi-device event.
 *
 *  @param event The event type.
 *  @param conversationId The conversation ID.
 *  @param conversationType The conversation type.
 */
- (void)multiDevicesConversationEvent:(EMMultiDevicesEvent)event conversationId:(NSString *_Nonnull)conversationId conversationType:(EMConversationType)conversationType;

@end
