import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'im_websocket_bridge.dart';

/// Event bridge handler that forwards SDK events to WebSocket server
class EventBridgeHandler {
  static final EventBridgeHandler instance = EventBridgeHandler._();
  
  EventBridgeHandler._();
  
  /// Register all event handlers to forward events to WebSocket
  void registerAllHandlers() {
    _registerConnectionHandlers();
    _registerMultiDeviceHandlers();
    _registerChatHandlers();
    _registerChatRoomHandlers();
    _registerChatThreadHandlers();
    _registerContactHandlers();
    _registerGroupHandlers();
    _registerPresenceHandlers();
    _registerMessageHandlers();
  }
  
  /// Unregister all event handlers
  void unregisterAllHandlers() {
    EMClient.getInstance.removeConnectionEventHandler('eventBridgeHandler');
    EMClient.getInstance.removeMultiDeviceEventHandler('eventBridgeHandler');
    EMClient.getInstance.chatManager.removeEventHandler('eventBridgeHandler');
    EMClient.getInstance.chatRoomManager.removeEventHandler('eventBridgeHandler');
    EMClient.getInstance.chatThreadManager.removeEventHandler('eventBridgeHandler');
    EMClient.getInstance.contactManager.removeEventHandler('eventBridgeHandler');
    EMClient.getInstance.groupManager.removeEventHandler('eventBridgeHandler');
    EMClient.getInstance.presenceManager.removeEventHandler('eventBridgeHandler');
    EMClient.getInstance.chatManager.removeMessageEvent('eventBridgeHandler');
  }
  
  /// Register connection event handler
  void _registerConnectionHandlers() {
    EMClient.getInstance.addConnectionEventHandler(
      'eventBridgeHandler',
      EMConnectionEventHandler(
        onConnected: () {
          IMWebSocketBridge.instance.sendEvent(
            'onConnected',
            {},
          );
        },
        
        onDisconnected: () {
          IMWebSocketBridge.instance.sendEvent(
            'onDisconnected',
            {},
          );
        },
        
        onUserDidLoginFromOtherDevice: (info) {
          IMWebSocketBridge.instance.sendEvent(
            'onUserDidLoginFromOtherDevice',
            {'info': info.toJson()},
          );
        },
        
        onUserDidRemoveFromServer: () {
          IMWebSocketBridge.instance.sendEvent(
            'onUserDidRemoveFromServer',
            {},
          );
        },
        
        onUserDidForbidByServer: () {
          IMWebSocketBridge.instance.sendEvent(
            'onUserDidForbidByServer',
            {},
          );
        },
        
        onUserDidChangePassword: () {
          IMWebSocketBridge.instance.sendEvent(
            'onUserDidChangePassword',
            {},
          );
        },
        
        onUserDidLoginTooManyDevice: () {
          IMWebSocketBridge.instance.sendEvent(
            'onUserDidLoginTooManyDevice',
            {},
          );
        },
        
        onUserKickedByOtherDevice: () {
          IMWebSocketBridge.instance.sendEvent(
            'onUserKickedByOtherDevice',
            {},
          );
        },
        
        onUserAuthenticationFailed: () {
          IMWebSocketBridge.instance.sendEvent(
            'onUserAuthenticationFailed',
            {},
          );
        },
        
        onTokenWillExpire: () {
          IMWebSocketBridge.instance.sendEvent(
            'onTokenWillExpire',
            {},
          );
        },
        
        onTokenDidExpire: () {
          IMWebSocketBridge.instance.sendEvent(
            'onTokenDidExpire',
            {},
          );
        },
        
        onAppActiveNumberReachLimit: () {
          IMWebSocketBridge.instance.sendEvent(
            'onAppActiveNumberReachLimit',
            {},
          );
        },
        
        onOfflineMessageSyncStart: () {
          IMWebSocketBridge.instance.sendEvent(
            'onOfflineMessageSyncStart',
            {},
          );
        },
        
        onOfflineMessageSyncFinish: () {
          IMWebSocketBridge.instance.sendEvent(
            'onOfflineMessageSyncFinish',
            {},
          );
        },
      ),
    );
  }
  
  /// Register multi-device event handler
  void _registerMultiDeviceHandlers() {
    EMClient.getInstance.addMultiDeviceEventHandler(
      'eventBridgeHandler',
      EMMultiDeviceEventHandler(
        onContactEvent: (event, userId, ext) {
          IMWebSocketBridge.instance.sendEvent(
            'onContactEvent',
            {
              'event': event.toString(),
              'userId': userId,
              'ext': ext,
            },
          );
        },
        
        onGroupEvent: (event, groupId, userIds) {
          IMWebSocketBridge.instance.sendEvent(
            'onGroupEvent',
            {
              'event': event.toString(),
              'groupId': groupId,
              'userIds': userIds,
            },
          );
        },
        
        onChatThreadEvent: (event, chatThreadId, userIds) {
          IMWebSocketBridge.instance.sendEvent(
            'onChatThreadEvent',
            {
              'event': event.toString(),
              'chatThreadId': chatThreadId,
              'userIds': userIds,
            },
          );
        },
        
        onRemoteMessagesRemoved: (conversationId, deviceId) {
          IMWebSocketBridge.instance.sendEvent(
            'onRemoteMessagesRemoved',
            {
              'conversationId': conversationId,
              'deviceId': deviceId,
            },
          );
        },
        
        onConversationEvent: (event, conversationId, type) {
          IMWebSocketBridge.instance.sendEvent(
            'onConversationEvent',
            {
              'event': event.toString(),
              'conversationId': conversationId,
              'type': type.toString(),
            },
          );
        },
      ),
    );
  }
  
  /// Register chat event handler
  void _registerChatHandlers() {
    EMClient.getInstance.chatManager.addEventHandler(
      'eventBridgeHandler',
      EMChatEventHandler(
        onMessagesReceived: (messages) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessagesReceived',
            {'messages': messages.map((m) => m.toJson()).toList()},
          );
        },
        
        onCmdMessagesReceived: (messages) {
          IMWebSocketBridge.instance.sendEvent(
            'onCmdMessagesReceived',
            {'messages': messages.map((m) => m.toJson()).toList()},
          );
        },
        
        onMessagesRead: (messages) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessagesRead',
            {'messages': messages.map((m) => m.toJson()).toList()},
          );
        },
        
        onGroupMessageRead: (groupMessageAcks) {
          IMWebSocketBridge.instance.sendEvent(
            'onGroupMessageRead',
            {'groupMessageAcks': groupMessageAcks.map((a) => a.toJson()).toList()},
          );
        },
        
        onReadAckForGroupMessageUpdated: () {
          IMWebSocketBridge.instance.sendEvent(
            'onReadAckForGroupMessageUpdated',
            {},
          );
        },
        
        onMessagesDelivered: (messages) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessagesDelivered',
            {'messages': messages.map((m) => m.toJson()).toList()},
          );
        },
        
        onMessagesRecalled: (messages) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessagesRecalled',
            {'messages': messages.map((m) => m.toJson()).toList()},
          );
        },
        
        onMessagesRecalledInfo: (infos) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessagesRecalledInfo',
            {'infos': infos.map((i) => i.toJson()).toList()},
          );
        },
        
        onConversationsUpdate: () {
          IMWebSocketBridge.instance.sendEvent(
            'onConversationsUpdate',
            {},
          );
        },
        
        onConversationRead: (from, to) {
          IMWebSocketBridge.instance.sendEvent(
            'onConversationRead',
            {'from': from, 'to': to},
          );
        },
        
        onMessageReactionDidChange: (events) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessageReactionDidChange',
            {'events': events.map((e) => e.toJson()).toList()},
          );
        },
        
        onMessageContentChanged: (message, operatorId, operationTime) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessageContentChanged',
            {
              'message': message.toJson(),
              'operatorId': operatorId,
              'operationTime': operationTime,
            },
          );
        },
        
        onMessagePinChanged: (messageId, conversationId, pinOperation, pinInfo) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessagePinChanged',
            {
              'messageId': messageId,
              'conversationId': conversationId,
              'pinOperation': pinOperation.toString(),
              'pinInfo': pinInfo.toJson(),
            },
          );
        },
      ),
    );
  }
  
  /// Register chat room event handler
  void _registerChatRoomHandlers() {
    EMClient.getInstance.chatRoomManager.addEventHandler(
      'eventBridgeHandler',
      EMChatRoomEventHandler(
        onAdminAddedFromChatRoom: (roomId, admin) {
          IMWebSocketBridge.instance.sendEvent(
            'onAdminAddedFromChatRoom',
            {'roomId': roomId, 'admin': admin},
          );
        },
        
        onAdminRemovedFromChatRoom: (roomId, admin) {
          IMWebSocketBridge.instance.sendEvent(
            'onAdminRemovedFromChatRoom',
            {'roomId': roomId, 'admin': admin},
          );
        },
        
        onAllChatRoomMemberMuteStateChanged: (roomId, isAllMuted) {
          IMWebSocketBridge.instance.sendEvent(
            'onAllChatRoomMemberMuteStateChanged',
            {'roomId': roomId, 'isAllMuted': isAllMuted},
          );
        },
        
        onAllowListAddedFromChatRoom: (roomId, members) {
          IMWebSocketBridge.instance.sendEvent(
            'onAllowListAddedFromChatRoom',
            {'roomId': roomId, 'members': members},
          );
        },
        
        onAllowListRemovedFromChatRoom: (roomId, members) {
          IMWebSocketBridge.instance.sendEvent(
            'onAllowListRemovedFromChatRoom',
            {'roomId': roomId, 'members': members},
          );
        },
        
        onAnnouncementChangedFromChatRoom: (roomId, announcement) {
          IMWebSocketBridge.instance.sendEvent(
            'onAnnouncementChangedFromChatRoom',
            {'roomId': roomId, 'announcement': announcement},
          );
        },
        
        onChatRoomDestroyed: (roomId, roomName) {
          IMWebSocketBridge.instance.sendEvent(
            'onChatRoomDestroyed',
            {'roomId': roomId, 'roomName': roomName},
          );
        },
        
        onMemberExitedFromChatRoom: (roomId, roomName, participant) {
          IMWebSocketBridge.instance.sendEvent(
            'onMemberExitedFromChatRoom',
            {
              'roomId': roomId,
              'roomName': roomName,
              'participant': participant,
            },
          );
        },
        
        onMemberJoinedFromChatRoom: (roomId, participant, ext) {
          IMWebSocketBridge.instance.sendEvent(
            'onMemberJoinedFromChatRoom',
            {
              'roomId': roomId,
              'participant': participant,
              'ext': ext,
            },
          );
        },
        
        onMuteListAddedFromChatRoom: (roomId, mutes) {
          IMWebSocketBridge.instance.sendEvent(
            'onMuteListAddedFromChatRoom',
            {'roomId': roomId, 'mutes': mutes},
          );
        },
        
        onMuteListRemovedFromChatRoom: (roomId, mutes) {
          IMWebSocketBridge.instance.sendEvent(
            'onMuteListRemovedFromChatRoom',
            {'roomId': roomId, 'mutes': mutes},
          );
        },
        
        onOwnerChangedFromChatRoom: (roomId, newOwner, oldOwner) {
          IMWebSocketBridge.instance.sendEvent(
            'onOwnerChangedFromChatRoom',
            {
              'roomId': roomId,
              'newOwner': newOwner,
              'oldOwner': oldOwner,
            },
          );
        },
        
        onRemovedFromChatRoom: (roomId, roomName, participant, reason) {
          IMWebSocketBridge.instance.sendEvent(
            'onRemovedFromChatRoom',
            {
              'roomId': roomId,
              'roomName': roomName,
              'participant': participant,
              'reason': reason?.toString(),
            },
          );
        },
        
        onSpecificationChanged: (room) {
          IMWebSocketBridge.instance.sendEvent(
            'onSpecificationChanged',
            {'room': room.toJson()},
          );
        },
        
        onAttributesUpdated: (roomId, attributes, from) {
          IMWebSocketBridge.instance.sendEvent(
            'onAttributesUpdated',
            {
              'roomId': roomId,
              'attributes': attributes,
              'from': from,
            },
          );
        },
        
        onAttributesRemoved: (roomId, removedKeys, from) {
          IMWebSocketBridge.instance.sendEvent(
            'onAttributesRemoved',
            {
              'roomId': roomId,
              'removedKeys': removedKeys,
              'from': from,
            },
          );
        },
      ),
    );
  }
  
  /// Register chat thread event handler
  void _registerChatThreadHandlers() {
    EMClient.getInstance.chatThreadManager.addEventHandler(
      'eventBridgeHandler',
      EMChatThreadEventHandler(
        onChatThreadCreate: (event) {
          IMWebSocketBridge.instance.sendEvent(
            'onChatThreadCreate',
            {'event': event.toJson()},
          );
        },
        
        onChatThreadDestroy: (event) {
          IMWebSocketBridge.instance.sendEvent(
            'onChatThreadDestroy',
            {'event': event.toJson()},
          );
        },
        
        onChatThreadUpdate: (event) {
          IMWebSocketBridge.instance.sendEvent(
            'onChatThreadUpdate',
            {'event': event.toJson()},
          );
        },
        
        onUserKickOutOfChatThread: (event) {
          IMWebSocketBridge.instance.sendEvent(
            'onUserKickOutOfChatThread',
            {'event': event.toJson()},
          );
        },
      ),
    );
  }
  
  /// Register contact event handler
  void _registerContactHandlers() {
    EMClient.getInstance.contactManager.addEventHandler(
      'eventBridgeHandler',
      EMContactEventHandler(
        onContactAdded: (userId) {
          IMWebSocketBridge.instance.sendEvent(
            'onContactAdded',
            {'userId': userId},
          );
        },
        
        onContactDeleted: (userId) {
          IMWebSocketBridge.instance.sendEvent(
            'onContactDeleted',
            {'userId': userId},
          );
        },
        
        onContactInvited: (userId, reason) {
          IMWebSocketBridge.instance.sendEvent(
            'onContactInvited',
            {'userId': userId, 'reason': reason},
          );
        },
        
        onFriendRequestAccepted: (userId) {
          IMWebSocketBridge.instance.sendEvent(
            'onFriendRequestAccepted',
            {'userId': userId},
          );
        },
        
        onFriendRequestDeclined: (userId) {
          IMWebSocketBridge.instance.sendEvent(
            'onFriendRequestDeclined',
            {'userId': userId},
          );
        },
      ),
    );
  }
  
  /// Register group event handler
  void _registerGroupHandlers() {
    EMClient.getInstance.groupManager.addEventHandler(
      'eventBridgeHandler',
      EMGroupEventHandler(
        onAdminAddedFromGroup: (groupId, admin) {
          IMWebSocketBridge.instance.sendEvent(
            'onAdminAddedFromGroup',
            {'groupId': groupId, 'admin': admin},
          );
        },
        
        onAdminRemovedFromGroup: (groupId, admin) {
          IMWebSocketBridge.instance.sendEvent(
            'onAdminRemovedFromGroup',
            {'groupId': groupId, 'admin': admin},
          );
        },
        
        onAllGroupMemberMuteStateChanged: (groupId, isAllMuted) {
          IMWebSocketBridge.instance.sendEvent(
            'onAllGroupMemberMuteStateChanged',
            {'groupId': groupId, 'isAllMuted': isAllMuted},
          );
        },
        
        onAllowListAddedFromGroup: (groupId, members) {
          IMWebSocketBridge.instance.sendEvent(
            'onAllowListAddedFromGroup',
            {'groupId': groupId, 'members': members},
          );
        },
        
        onAllowListRemovedFromGroup: (groupId, members) {
          IMWebSocketBridge.instance.sendEvent(
            'onAllowListRemovedFromGroup',
            {'groupId': groupId, 'members': members},
          );
        },
        
        onAnnouncementChangedFromGroup: (groupId, announcement) {
          IMWebSocketBridge.instance.sendEvent(
            'onAnnouncementChangedFromGroup',
            {'groupId': groupId, 'announcement': announcement},
          );
        },
        
        onAutoAcceptInvitationFromGroup: (groupId, inviter, inviteMessage) {
          IMWebSocketBridge.instance.sendEvent(
            'onAutoAcceptInvitationFromGroup',
            {
              'groupId': groupId,
              'inviter': inviter,
              'inviteMessage': inviteMessage,
            },
          );
        },
        
        onGroupDestroyed: (groupId, groupName) {
          IMWebSocketBridge.instance.sendEvent(
            'onGroupDestroyed',
            {'groupId': groupId, 'groupName': groupName},
          );
        },
        
        onInvitationAcceptedFromGroup: (groupId, invitee, reason) {
          IMWebSocketBridge.instance.sendEvent(
            'onInvitationAcceptedFromGroup',
            {
              'groupId': groupId,
              'invitee': invitee,
              'reason': reason,
            },
          );
        },
        
        onInvitationDeclinedFromGroup: (groupId, invitee, reason) {
          IMWebSocketBridge.instance.sendEvent(
            'onInvitationDeclinedFromGroup',
            {
              'groupId': groupId,
              'invitee': invitee,
              'reason': reason,
            },
          );
        },
        
        onInvitationReceivedFromGroup: (groupId, groupName, inviter, reason) {
          IMWebSocketBridge.instance.sendEvent(
            'onInvitationReceivedFromGroup',
            {
              'groupId': groupId,
              'groupName': groupName,
              'inviter': inviter,
              'reason': reason,
            },
          );
        },
        
        onMemberExitedFromGroup: (groupId, member) {
          IMWebSocketBridge.instance.sendEvent(
            'onMemberExitedFromGroup',
            {'groupId': groupId, 'member': member},
          );
        },
        
        onMemberJoinedFromGroup: (groupId, member) {
          IMWebSocketBridge.instance.sendEvent(
            'onMemberJoinedFromGroup',
            {'groupId': groupId, 'member': member},
          );
        },
        
        onMuteListAddedFromGroup: (groupId, mutes, muteExpire) {
          IMWebSocketBridge.instance.sendEvent(
            'onMuteListAddedFromGroup',
            {
              'groupId': groupId,
              'mutes': mutes,
              'muteExpire': muteExpire,
            },
          );
        },
        
        onMuteListRemovedFromGroup: (groupId, mutes) {
          IMWebSocketBridge.instance.sendEvent(
            'onMuteListRemovedFromGroup',
            {'groupId': groupId, 'mutes': mutes},
          );
        },
        
        onOwnerChangedFromGroup: (groupId, newOwner, oldOwner) {
          IMWebSocketBridge.instance.sendEvent(
            'onOwnerChangedFromGroup',
            {
              'groupId': groupId,
              'newOwner': newOwner,
              'oldOwner': oldOwner,
            },
          );
        },
        
        onRequestToJoinAcceptedFromGroup: (groupId, groupName, accepter) {
          IMWebSocketBridge.instance.sendEvent(
            'onRequestToJoinAcceptedFromGroup',
            {
              'groupId': groupId,
              'groupName': groupName,
              'accepter': accepter,
            },
          );
        },
        
        onRequestToJoinDeclinedFromGroup: (groupId, groupName, decliner, reason, applicant) {
          IMWebSocketBridge.instance.sendEvent(
            'onRequestToJoinDeclinedFromGroup',
            {
              'groupId': groupId,
              'groupName': groupName,
              'decliner': decliner,
              'reason': reason,
              'applicant': applicant,
            },
          );
        },
        
        onRequestToJoinReceivedFromGroup: (groupId, groupName, applicant, reason) {
          IMWebSocketBridge.instance.sendEvent(
            'onRequestToJoinReceivedFromGroup',
            {
              'groupId': groupId,
              'groupName': groupName,
              'applicant': applicant,
              'reason': reason,
            },
          );
        },
        
        onSharedFileAddedFromGroup: (groupId, sharedFile) {
          IMWebSocketBridge.instance.sendEvent(
            'onSharedFileAddedFromGroup',
            {
              'groupId': groupId,
              'sharedFile': sharedFile.toJson(),
            },
          );
        },
        
        onSpecificationDidUpdate: (group) {
          IMWebSocketBridge.instance.sendEvent(
            'onSpecificationDidUpdate',
            {'group': group.toJson()},
          );
        },
        
        onDisableChanged: (groupId, isDisable) {
          IMWebSocketBridge.instance.sendEvent(
            'onDisableChanged',
            {'groupId': groupId, 'isDisable': isDisable},
          );
        },
        
        onSharedFileDeletedFromGroup: (groupId, fileId) {
          IMWebSocketBridge.instance.sendEvent(
            'onSharedFileDeletedFromGroup',
            {'groupId': groupId, 'fileId': fileId},
          );
        },
        
        onUserRemovedFromGroup: (groupId, groupName) {
          IMWebSocketBridge.instance.sendEvent(
            'onUserRemovedFromGroup',
            {'groupId': groupId, 'groupName': groupName},
          );
        },
        
        onAttributesChangedOfGroupMember: (groupId, userId, attributes, operatorId) {
          IMWebSocketBridge.instance.sendEvent(
            'onAttributesChangedOfGroupMember',
            {
              'groupId': groupId,
              'userId': userId,
              'attributes': attributes,
              'operatorId': operatorId,
            },
          );
        },
        
        onMembersJoinedFromGroup: (groupId, userIds) {
          IMWebSocketBridge.instance.sendEvent(
            'onMembersJoinedFromGroup',
            {'groupId': groupId, 'userIds': userIds},
          );
        },
        
        onMembersExitedFromGroup: (groupId, userIds) {
          IMWebSocketBridge.instance.sendEvent(
            'onMembersExitedFromGroup',
            {'groupId': groupId, 'userIds': userIds},
          );
        },
      ),
    );
  }
  
  /// Register presence event handler
  void _registerPresenceHandlers() {
    EMClient.getInstance.presenceManager.addEventHandler(
      'eventBridgeHandler',
      EMPresenceEventHandler(
        onPresenceStatusChanged: (list) {
          IMWebSocketBridge.instance.sendEvent(
            'onPresenceStatusChanged',
            {'list': list.map((p) => p.toJson()).toList()},
          );
        },
      ),
    );
  }
  
  /// Register message event handler
  void _registerMessageHandlers() {
    EMClient.getInstance.chatManager.addMessageEvent(
      'eventBridgeHandler',
      ChatMessageEvent(
        onSuccess: (msgId, msg) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessageSuccess',
            {'msgId': msgId, 'msg': msg.toJson()},
          );
        },
        
        onError: (msgId, msg, error) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessageError',
            {
              'msgId': msgId,
              'msg': msg.toJson(),
              'error': {
                'code': error.code,
                'description': error.description,
              },
            },
          );
        },
        
        onProgress: (msgId, progress) {
          IMWebSocketBridge.instance.sendEvent(
            'onMessageProgress',
            {'msgId': msgId, 'progress': progress},
          );
        },
      ),
    );
  }
}
