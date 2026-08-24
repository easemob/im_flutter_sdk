import { canonicalMessage, chatType, createEventAdapter } from "./event_adapter.js";

/**
 * Web 5.0 wrapper entry point. The native IIFE is loaded by the browser runner.
 */
export function createWebSdkWrapper({
  appKey,
  emit,
  onStatus = () => {},
}) {
  return createWeb5SdkWrapper({ appKey, emit, onStatus });
}

function createWeb5SdkWrapper({ appKey, emit, onStatus }) {
  const sdk = globalThis.IMSDK;
  if (!sdk?.ChatClient?.init) throw new Error("Web 5.0 SDK global IMSDK is not loaded");

  let currentUser = "";
  const messages = new Map();
  const client = sdk.ChatClient.init({
    appKey,
    managers: [
      sdk.ChatManager,
      sdk.ChatRoomManager,
      sdk.ChatThreadManager,
      sdk.ContactManager,
      sdk.GroupManager,
      sdk.PresenceManager,
      sdk.PushManager,
      sdk.UserInfoManager,
    ].filter(Boolean),
    enableDeliveryReceipt: true,
    // Contact sync in Web 5.0 requires the optional userInfo:read capability.
    // The test wrapper does not enable that manager yet; keep conversation
    // sync explicit until the user-info protocol is added as a real feature.
    enableSyncData: ["conversation"],
    useFixedDeviceId: true,
    deviceId: "webim",
  });
  const chat = client.chatManager;
  const chatRooms = client.chatRoomManager;
  const chatThreads = client.chatThreadManager;
  const contacts = client.contactManager;
  const groups = client.groupManager;
  const presence = client.presenceManager;
  const push = client.pushManager;
  const userInfo = client.userInfoManager;

  const managers = {
    ChatManager: chat,
    ChatRoomManager: chatRooms,
    ChatThreadManager: chatThreads,
    ContactManager: contacts,
    GroupManager: groups,
    PresenceManager: presence,
    PushManager: push,
    UserInfoManager: userInfo,
  };

  client.addEventHandler("native-auto-test", {
    onConnecting: () => onStatus("IM connecting"),
    onConnected: () => { onStatus("IM connected"); emit("onConnected", {}); },
    onDisconnected: () => { onStatus("IM disconnected"); emit("onDisconnected", {}); },
    onReconnectFailed: emitError,
    onTokenWillExpire: () => emit("onTokenWillExpire", {}),
    onTokenExpired: () => emit("onTokenDidExpire", {}),
    onOfflineMessageSyncStart: () => emit("onDataSyncStart", { type: "message" }),
    onOfflineMessageSyncFinish: () => emit("onDataSyncFinish", { type: "message" }),
    onSyncDataStart: (data) => emit("onDataSyncStart", jsonSafe(data || {})),
    onSyncDataFinished: (data) => emit("onDataSyncFinish", jsonSafe(data || {})),
    onGroupNotify: (payload) => emit("onGroupNotify", jsonSafe(payload || {})),
    onOwnInfoUpdated: (payload) => emit("onSelfUserInfoUpdate", jsonSafe(payload || {})),
    onUserInfoUpdated: (payload) => {
      const values = Array.isArray(payload) ? payload : [payload];
      for (const value of values.filter(Boolean)) emit("onUserInfoUpdate", jsonSafe(value));
    },
  });

  registerManagerEvents();

  async function invoke(manager, cmd, info = {}) {
    if (manager === "Client") return invokeClient(cmd, info);
    if (manager === "MessageManager") return invokeMessage(cmd, info);
    if (manager === "ConversationManager") return invokeConversation(cmd, info);
    if (hasMappedCommand(manager, cmd)) return invokeMapped(manager, cmd, info);
    if (manager === "ChatManager") return invokeChat(cmd, info);
    if (manager === "ContactManager") return invokeContact(cmd, info);
    if (manager === "GroupManager") return invokeGroup(cmd, info);
    if (manager === "PresenceManager") return invokePresence(cmd, info);
    if (manager === "ChatRoomManager" || manager === "ChatThreadManager" || manager === "PushManager" || manager === "UserInfoManager") {
      return invokeMapped(manager, cmd, info);
    }
    throw new Error(`Web 5.0 wrapper does not support ${manager}.${cmd}`);
  }

  async function invokeConversation(cmd, info) {
    if (cmd === "markAllMessagesAsRead") return chat.clearAllConversationUnreadMessageCount();
    if (cmd === "pinnedMessages") return chat.getPinnedMessageList(unreadOptions(info));
    throw new Error(`Web 5.0 wrapper does not support ConversationManager.${cmd}`);
  }

  async function invokeMessage(cmd, info) {
    if (cmd === "chatThread") return chatThreads?.getChatThread(String(info.threadId || info.chatThreadId)) || null;
    if (cmd === "getPinInfo") return chat.getPinnedMessageList(unreadOptions(info));
    if (cmd === "getReactionList") return chat.getReactionList({ messageId: String(info.msgId || info.messageId) });
    if (cmd === "groupAckCount") return chat.getGroupMessageReadReceipts(groupReceiptOptions(info));
    throw new Error(`Web 5.0 wrapper does not support MessageManager.${cmd}`);
  }

  function hasMappedCommand(manager, cmd) {
    return Boolean(web5CommandMap[manager]?.[cmd]);
  }

  async function invokeMapped(manager, cmd, info) {
    const target = managers[manager];
    const operation = web5CommandMap[manager]?.[cmd];
    if (!target || !operation) throw new Error(`Web 5.0 wrapper does not support ${manager}.${cmd}`);
    const result = await operation(target, info);
    return jsonSafe(result);
  }

  function registerManagerEvents() {
    registerEvents(chat, [
      ["onConversationListUpdate", (payload) => emit("onConversationUpdate", jsonSafe(payload || {}))],
      ["onMultiDeviceConversation", (payload) => emit("onConversationUpdate", jsonSafe(payload || {}))],
      ["onMessage", (payload) => handleMessages(payload, "onMessagesReceived", 1)],
      ["onMessageDelivered", (payload) => handleMessages(payload, "onMessagesDelivered", 0)],
      ["onMessageReadReceipts", (payload) => emit("onMessagesRead", jsonSafe(payload || {}))],
      ["onMessageRecalled", (payload) => emit("onMessagesRecalledInfo", normalizeRecallEvent(payload))],
      ["onMessageUpdated", (payload) => emit("onMessageContentChanged", jsonSafe(payload || {}))],
      ["onMessageError", (payload) => emit("onMessageError", jsonSafe(payload || {}))],
      ["onMessageProgress", (payload) => emit("onMessageProgressUpdate", jsonSafe(payload || {}))],
      ["onReactionChanged", (payload) => emit("messageReactionDidChange", normalizeWeb5Reaction(payload, currentUser))],
      ["onPinnedMessageChanged", (payload) => emit("onMessagePinChanged", jsonSafe(payload || {}))],
    ]);

    registerEvents(contacts, [
      ["onMultiDeviceContact", (payload) => emit("onContactChanged", jsonSafe(payload || {}))],
      ["onContactInvited", (payload) => emit("onContactInvited", jsonSafe(payload || {}))],
      ["onContactDeleted", (payload) => emit("onContactDeleted", jsonSafe(payload || {}))],
      ["onContactAdded", (payload) => emit("onContactAdded", jsonSafe(payload || {}))],
      ["onContactRefuse", (payload) => emit("onFriendRequestDeclined", jsonSafe(payload || {}))],
      ["onContactAgreed", (payload) => emit("onFriendRequestAccepted", jsonSafe(payload || {}))],
      ["onContactInfoUpdated", (payload) => emit("onContactInfoUpdate", jsonSafe(payload || {}))],
    ]);

    registerEvents(groups, [
      ["onInvitationReceived", (payload) => emit("onGroupInvitationReceived", jsonSafe(payload || {}))],
      ["onRequestToJoinReceived", (payload) => emit("onGroupRequestToJoinReceived", jsonSafe(payload || {}))],
      ["onRequestToJoinAccepted", (payload) => emit("onGroupRequestToJoinAccepted", jsonSafe(payload || {}))],
      ["onRequestToJoinDeclined", (payload) => emit("onGroupRequestToJoinDeclined", jsonSafe(payload || {}))],
      ["onInvitationAccepted", (payload) => emit("onGroupInvitationAccepted", jsonSafe(payload || {}))],
      ["onInvitationDeclined", (payload) => emit("onGroupInvitationDeclined", jsonSafe(payload || {}))],
      ["onUserRemoved", (payload) => emit("onGroupUserRemoved", jsonSafe(payload || {}))],
      ["onGroupDestroyed", (payload) => emit("onGroupDestroyed", jsonSafe(payload || {}))],
      ["onAutoAcceptInvitationFromGroup", (payload) => emit("onGroupAutoAcceptInvitation", jsonSafe(payload || {}))],
      ["onMuteListAdded", (payload) => emit("onGroupMuteListAdded", jsonSafe(payload || {}))],
      ["onMuteListRemoved", (payload) => emit("onGroupMuteListRemoved", jsonSafe(payload || {}))],
      ["onAllowListAdded", (payload) => emit("onGroupWhiteListAdded", jsonSafe(payload || {}))],
      ["onAllowListRemoved", (payload) => emit("onGroupWhiteListRemoved", jsonSafe(payload || {}))],
      ["onAllMemberMuteStateChanged", (payload) => emit("onGroupAllMemberMuteStateChanged", jsonSafe(payload || {}))],
      ["onAdminAdded", (payload) => emit("onGroupAdminAdded", jsonSafe(payload || {}))],
      ["onAdminRemoved", (payload) => emit("onGroupAdminRemoved", jsonSafe(payload || {}))],
      ["onOwnerChanged", (payload) => emit("onGroupOwnerChanged", jsonSafe(payload || {}))],
      ["onMembersJoined", (payload) => emit("onGroupMembersJoined", jsonSafe(payload || {}))],
      ["onMembersExited", (payload) => emit("onGroupMembersExited", jsonSafe(payload || {}))],
      ["onAnnouncementChanged", (payload) => emit("onGroupAnnouncementChanged", jsonSafe(payload || {}))],
      ["onSharedFileAdded", (payload) => emit("onGroupSharedFileAdded", jsonSafe(payload || {}))],
      ["onSharedFileDeleted", (payload) => emit("onGroupSharedFileDeleted", jsonSafe(payload || {}))],
      ["onGroupInfoChanged", (payload) => emit("onGroupSpecificationDidUpdate", jsonSafe(payload || {}))],
      ["onGroupDisabledChanged", (payload) => emit("onGroupStateChanged", jsonSafe(payload || {}))],
      ["onGroupMemberAttributeChanged", (payload) => emit("onGroupAttributesChangedOfMember", jsonSafe(payload || {}))],
      ["onUserGroupNamecardUpdated", (payload) => emit("onUserGroupNamecardUpdated", jsonSafe(payload || {}))],
    ]);

    registerEvents(chatRooms, [
      ["onChatRoomDestroyed", (payload) => emit("onRoomDestroyed", jsonSafe(payload || {}))],
      ["onMembersJoined", (payload) => emit("onRoomMemberJoined", jsonSafe(payload || {}))],
      ["onMembersExited", (payload) => emit("onRoomMemberExited", jsonSafe(payload || {}))],
      ["onRemovedFromChatRoom", (payload) => emit("onRoomRemoved", jsonSafe(payload || {}))],
      ["onMuteListAdded", (payload) => emit("onRoomMuteListAdded", jsonSafe(payload || {}))],
      ["onMuteListRemoved", (payload) => emit("onRoomMuteListRemoved", jsonSafe(payload || {}))],
      ["onAllowListAdded", (payload) => emit("onRoomWhiteListAdded", jsonSafe(payload || {}))],
      ["onAllowListRemoved", (payload) => emit("onRoomWhiteListRemoved", jsonSafe(payload || {}))],
      ["onAllMemberMuteStateChanged", (payload) => emit("onRoomAllMemberMuteStateChanged", jsonSafe(payload || {}))],
      ["onAdminAdded", (payload) => emit("onRoomAdminAdded", jsonSafe(payload || {}))],
      ["onAdminRemoved", (payload) => emit("onRoomAdminRemoved", jsonSafe(payload || {}))],
      ["onOwnerChanged", (payload) => emit("onRoomOwnerChanged", jsonSafe(payload || {}))],
      ["onAnnouncementChanged", (payload) => emit("onRoomAnnouncementChanged", jsonSafe(payload || {}))],
      ["onChatRoomInfoChanged", (payload) => emit("onRoomSpecificationChanged", jsonSafe(payload || {}))],
      ["onAttributesUpdate", (payload) => emit("onRoomAttributesDidUpdated", jsonSafe(payload || {}))],
      ["onAttributesRemoved", (payload) => emit("onRoomAttributesDidRemoved", jsonSafe(payload || {}))],
    ]);

    registerEvents(chatThreads, [["onChatThreadNotify", (payload) => emitThreadEvent(payload)]]);
    registerEvents(presence, [["onPresenceStatusChange", (payload) => emit("onPresenceStatusChanged", jsonSafe(payload || {}))]]);
  }

  function emitThreadEvent(payload) {
    const data = jsonSafe(payload || {});
    const value = String(data.type || data.eventType || data.action || data.operation || "").toLowerCase();
    const eventType = value.includes("destroy") || value.includes("delete")
      ? "onChatThreadDestroy"
      : value.includes("create") || value.includes("add")
        ? "onChatThreadCreate"
        : value.includes("kick") || value.includes("remove")
          ? "onUserKickOutOfChatThread"
          : "onChatThreadUpdate";
    emit(eventType, data);
  }

  function registerEvents(manager, entries) {
    if (!manager?.addEventHandler) return;
    const handler = {};
    for (const [name, callback] of entries) handler[name] = callback;
    const key = manager.constructor?.key || manager.constructor?.name || "manager";
    manager.addEventHandler(`native-auto-test-${key}`, handler);
  }

  const web5CommandMap = {
    ChatManager: {
      ackConversationRead: (m, i) => m.clearConversationUnreadMessageCount(unreadOptions(i)),
      ackGroupMessageRead: (m, i) => m.sendMessageReadReceipts(readReceiptOptions(i)),
      ackMessageRead: (m, i) => m.sendMessageReadReceipts(readReceiptOptions(i)),
      addRemoteAndLocalConversationsMark: (m, i) => m.addConversationMark(conversationMarkOptions(i)),
      asyncFetchGroupAcks: (m, i) => m.getGroupMessageReadReceipts(groupReceiptOptions(i)),
      deleteAllMessageAndConversation: (m) => m.clearAllMessagesAndConversations(),
      deleteConversation: (m, i) => m.deleteConversation(String(i.convId || i.conversationId), Boolean(i.deleteMessages)),
      deleteConversations: (m, i) => Promise.all((i.convIds || i.conversationIds || []).map((id) => m.deleteConversation(String(id), Boolean(i.deleteMessages)))),
      deleteMessagesBeforeTimestamp: (m, i) => m.removeHistoryMessages(historyDeleteOptions(i)),
      deleteRemoteAndLocalConversationsMark: (m, i) => m.removeConversationMark(conversationMarkOptions(i)),
      deleteRemoteConversation: (m, i) => m.deleteConversation(String(i.convId || i.conversationId), true),
      downloadAndParseCombineMessage: (m, i) => m.downloadAndParseCombineMessage(i),
      downloadAttachment: (m, i) => m.downloadAttachment(downloadOptions(i)),
      downloadThumbnail: (m, i) => m.downloadAttachment(downloadOptions(i)),
      fetchHistoryMessagesByOptions: (m, i) => m.getHistoryMessages(historyOptions(i)),
      fetchPinnedMessages: (m, i) => m.getPinnedMessageList({ conversationId: String(i.convId || i.conversationId), conversationType: conversationType(i.chatType || i.conversationType) }),
      fetchSupportLanguages: (m) => m.getSupportedTranslationLanguages(),
      getGroupMessageReadReceipts: (m, i) => m.getGroupMessageReadReceipts(groupReceiptOptions(i)),
      loadAllConversations: (m, i) => m.getConversationList(conversationListOptions(i)),
      loadConversationMessagesWithKeyword: (m, i) => m.searchMessages(searchOptions(i)),
      markAllChatMsgAsRead: (m, i) => m.clearConversationUnreadMessageCount(unreadOptions(i)),
      pinConversation: (m, i) => m.setConversationPinned({ conversationId: String(i.convId || i.conversationId), conversationType: conversationType(i.chatType || i.conversationType), pinned: Boolean(i.isPinned ?? i.pinned ?? true) }),
      pinMessage: (m, i) => m.pinMessage({ conversationId: String(i.convId || i.conversationId), conversationType: conversationType(i.chatType || i.conversationType), messageId: String(i.msgId || i.messageId), note: i.note }),
      removeMessagesFromServerWithMsgIds: (m, i) => m.removeHistoryMessages({ conversationId: String(i.convId || i.conversationId), messageIds: i.msgIds || i.messageIds || [] }),
      removeMessagesFromServerWithTs: (m, i) => m.removeHistoryMessages({ conversationId: String(i.convId || i.conversationId), timestamp: i.timestamp || i.ts }),
      resendMessage: (m, i) => m.sendMessage(i.message),
      searchChatMsgFromDB: (m, i) => m.searchMessages(searchOptions(i)),
      searchMessagesFromServer: (m, i) => m.searchMessages(searchOptions(i)),
      searchMsgsByOptions: (m, i) => m.searchMessages(searchOptions(i)),
      translateMessage: (m, i) => m.translateMessage({ messageId: String(i.msgId || i.messageId), targetLanguages: i.languages || i.targetLanguages || [] }),
      unpinMessage: (m, i) => m.unpinMessage({ conversationId: String(i.convId || i.conversationId), conversationType: conversationType(i.chatType || i.conversationType), messageId: String(i.msgId || i.messageId) }),
      updateChatMessage: (m, i) => m.modifyMessage(modifyOptions(i)),
      voiceFileToText: (m, i) => m.voiceFileToText(i),
      voiceMessageToText: (m, i) => m.voiceMessageToText(i),
    },
    ChatRoomManager: {
      fetchPublicChatRoomsFromServer: (m, i) => m.getChatRoomList(pageOptions(i)),
      fetchChatRoomInfoFromServer: (m, i) => m.getChatRoomInfo({ chatRoomId: roomId(i) }),
      getChatRoom: (m, i) => m.getChatRoom(roomId(i)),
      fetchChatRoomMembers: (m, i) => m.getMemberList({ chatRoomId: roomId(i), pageSize: pageSize(i), cursor: i.cursor || "" }),
      fetchChatRoomMuteList: (m, i) => m.getMuteList({ chatRoomId: roomId(i) }),
      fetchChatRoomBlockList: (m, i) => m.getBlocklist({ chatRoomId: roomId(i) }),
      fetchChatRoomWhiteListFromServer: (m, i) => m.getAllowlist({ chatRoomId: roomId(i) }),
      isMemberInChatRoomMuteList: (m, i) => m.checkIfInMuteList({ chatRoomId: roomId(i), userId: userId(i) }),
      isMemberInChatRoomWhiteListFromServer: (m, i) => m.checkIfInAllowList({ chatRoomId: roomId(i), userId: userId(i) }),
      joinChatRoom: (m, i) => m.joinChatRoom({ chatRoomId: roomId(i), message: i.message }),
      leaveChatRoom: (m, i) => m.leaveChatRoom({ chatRoomId: roomId(i) }),
      muteAllChatRoomMembers: (m, i) => m.muteAllMembers({ chatRoomId: roomId(i) }),
      unMuteAllChatRoomMembers: (m, i) => m.unmuteAllMembers({ chatRoomId: roomId(i) }),
      muteChatRoomMembers: (m, i) => m.muteMembers({ chatRoomId: roomId(i), userIds: members(i) }),
      unMuteChatRoomMembers: (m, i) => m.unmuteMembers({ chatRoomId: roomId(i), userIds: members(i) }),
      blockChatRoomMembers: (m, i) => m.blockMembers({ chatRoomId: roomId(i), userIds: members(i) }),
      unBlockChatRoomMembers: (m, i) => m.unblockMembers({ chatRoomId: roomId(i), userIds: members(i) }),
      removeChatRoomMembers: (m, i) => m.removeMembers({ chatRoomId: roomId(i), userIds: members(i) }),
      addMembersToChatRoomWhiteList: (m, i) => m.addUsersToAllowlist({ chatRoomId: roomId(i), userIds: members(i) }),
      removeMembersFromChatRoomWhiteList: (m, i) => m.removeUsersFromAllowlist({ chatRoomId: roomId(i), userIds: members(i) }),
      addChatRoomAdmin: (m, i) => m.addAdmin({ chatRoomId: roomId(i), userId: userId(i) }),
      removeChatRoomAdmin: (m, i) => m.removeAdmin({ chatRoomId: roomId(i), userId: userId(i) }),
      fetchChatRoomAllAttributesFromServer: (m, i) => m.getAttributes({ chatRoomId: roomId(i) }),
      fetchChatRoomAttributes: (m, i) => m.getAttributes({ chatRoomId: roomId(i), keys: i.keys || [] }),
      setChatRoomAttributes: (m, i) => m.setAttributes({ chatRoomId: roomId(i), attributes: i.attributes || {} }),
      removeChatRoomAttributes: (m, i) => m.removeAttributes({ chatRoomId: roomId(i), keys: i.keys || [] }),
      removeChatRoomAttributeFromServer: (m, i) => m.removeAttributes({ chatRoomId: roomId(i), keys: [String(i.attribute || i.key || "")] }),
      removeChatRoomAttributeFromServerForced: (m, i) => m.removeAttributes({ chatRoomId: roomId(i), keys: [String(i.attribute || i.key || "")] }),
      updateChatRoomAnnouncement: (m, i) => m.updateAnnouncement({ chatRoomId: roomId(i), announcement: String(i.announcement || "") }),
      fetchChatRoomAnnouncement: (m, i) => m.getAnnouncement({ chatRoomId: roomId(i) }),
      changeChatRoomSubject: (m, i) => m.updateChatRoomInfo({ chatRoomId: roomId(i), subject: i.subject || i.name || "" }),
      changeChatRoomDescription: (m, i) => m.updateChatRoomInfo({ chatRoomId: roomId(i), description: i.description || "" }),
      changeChatRoomOwner: (m, i) => m.updateChatRoomInfo({ chatRoomId: roomId(i), owner: userId(i) }),
    },
    ContactManager: {
      fetchAllContacts: (m) => m.getContacts(),
      getAllContactsFromDB: (m) => m.getContacts(),
      getBlockListFromServer: (m) => m.getBlocklist(),
      getSelfIdsOnOtherPlatform: (m) => client.getSelfIdsOnOtherPlatform(),
    },
    GroupManager: {
      acceptInvitationFromGroup: (m, i) => m.acceptInvitation({ groupId: groupId(i), invitee: userId(i) }),
      acceptJoinApplication: (m, i) => m.acceptGroupJoinRequest({ groupId: groupId(i), userId: userId(i) }),
      addAdmin: (m, i) => m.addGroupAdmin({ groupId: groupId(i), userId: userId(i) }),
      addWhiteList: (m, i) => m.addUsersToGroupAllowlist({ groupId: groupId(i), userIds: members(i) }),
      blockMembers: (m, i) => m.blockGroupMembers({ groupId: groupId(i), userIds: members(i) }),
      blockUser: (m, i) => m.blockGroupMembers({ groupId: groupId(i), userIds: [userId(i)] }),
      declineInvitationFromGroup: (m, i) => m.rejectInvitation({ groupId: groupId(i), invitee: userId(i) }),
      declineJoinApplication: (m, i) => m.rejectGroupJoinRequest({ groupId: groupId(i), userId: userId(i) }),
      downloadGroupSharedFile: (m, i) => m.downloadGroupSharedFile(i),
      fetchGroupBlackList: (m, i) => m.getGroupBlocklist({ groupId: groupId(i), pageSize: pageSize(i), cursor: i.cursor || "" }),
      fetchGroupMembersInfo: (m, i) => m.getGroupMemberList({ groupId: groupId(i), pageSize: pageSize(i), cursor: i.cursor || "" }),
      fetchMemberAttributesFromGroup: (m, i) => m.getGroupMembersAttributes({ groupId: groupId(i), userIds: members(i) }),
      fetchMembersAttributesFromGroup: (m, i) => m.getGroupMembersAttributes({ groupId: groupId(i), userIds: members(i) }),
      fetchMemberAllAttributes: (m, i) => m.getGroupMembersAttributes({ groupId: groupId(i), userIds: members(i) }),
      getGroupAnnouncementFromServer: (m, i) => m.getGroupAnnouncement({ groupId: groupId(i) }),
      getGroupBlockListFromServer: (m, i) => m.getGroupBlocklist({ groupId: groupId(i), pageSize: pageSize(i), cursor: i.cursor || "" }),
      getGroupFileListFromServer: (m, i) => m.getGroupSharedFileList({ groupId: groupId(i), pageSize: pageSize(i), cursor: i.cursor || "" }),
      getGroupMuteListFromServer: (m, i) => m.getGroupMuteList({ groupId: groupId(i), pageSize: pageSize(i), cursor: i.cursor || "" }),
      getGroupWhiteListFromServer: (m, i) => m.getGroupAllowlist({ groupId: groupId(i), pageSize: pageSize(i), cursor: i.cursor || "" }),
      inviterUser: (m, i) => m.inviteUsersToGroup({ groupId: groupId(i), userIds: members(i), welcomeMessage: i.message }),
      isMemberInGroupMuteList: (m, i) => m.checkIfInGroupMuteList({ groupId: groupId(i), userId: userId(i) }),
      isMemberInWhiteListFromServer: (m, i) => m.checkIfInGroupAllowList({ groupId: groupId(i), userId: userId(i) }),
      joinPublicGroup: (m, i) => m.joinGroup({ groupId: groupId(i), message: i.message }),
      muteAllMembers: (m, i) => m.muteAllGroupMembers({ groupId: groupId(i) }),
      muteMembers: (m, i) => m.muteGroupMembers({ groupId: groupId(i), userIds: members(i) }),
      removeAdmin: (m, i) => m.removeGroupAdmin({ groupId: groupId(i), userId: userId(i) }),
      removeGroupSharedFile: (m, i) => m.deleteGroupSharedFile({ groupId: groupId(i), fileId: String(i.fileId || i.id) }),
      removeUserFromGroup: (m, i) => m.removeGroupMembers({ groupId: groupId(i), userIds: [userId(i)] }),
      removeWhiteList: (m, i) => m.removeUsersFromGroupAllowlist({ groupId: groupId(i), userIds: members(i) }),
      requestToJoinPublicGroup: (m, i) => m.joinGroup({ groupId: groupId(i), message: i.message }),
      setMemberAttributesFromGroup: (m, i) => m.setGroupMemberAttributes({ groupId: groupId(i), userId: userId(i), attributes: i.attributes || {} }),
      unMuteAllMembers: (m, i) => m.unmuteAllGroupMembers({ groupId: groupId(i) }),
      unMuteMembers: (m, i) => m.unmuteGroupMembers({ groupId: groupId(i), userIds: members(i) }),
      unblockMembers: (m, i) => m.unblockGroupMembers({ groupId: groupId(i), userIds: members(i) }),
      unblockUser: (m, i) => m.unblockGroupMembers({ groupId: groupId(i), userIds: [userId(i)] }),
      updateDescription: (m, i) => m.updateGroupInfo({ groupId: groupId(i), description: i.description || "" }),
      updateGroupAnnouncement: (m, i) => m.updateGroupAnnouncement({ groupId: groupId(i), announcement: i.announcement || "" }),
      updateGroupAvatar: (m, i) => m.updateGroupInfo({ groupId: groupId(i), avatar: i.avatar || i.avatarUrl || "" }),
      updateGroupConfigs: (m, i) => m.updateGroupInfo({ groupId: groupId(i), ...i.configs }),
      updateGroupExt: (m, i) => m.updateGroupInfo({ groupId: groupId(i), ext: i.ext || "" }),
      updateGroupExtension: (m, i) => m.updateGroupInfo({ groupId: groupId(i), ext: i.ext || "" }),
      updateGroupOwner: (m, i) => m.changeGroupOwner({ groupId: groupId(i), newOwner: userId(i) }),
      updateGroupSubject: (m, i) => m.updateGroupInfo({ groupId: groupId(i), name: i.subject || i.name || "" }),
      uploadGroupSharedFile: (m, i) => m.uploadGroupSharedFile(i),
    },
    PresenceManager: {
      fetchSubscribedMembersWithPageNum: (m, i) => m.getSubscribedPresenceList(pageOptions(i)),
    },
    ChatThreadManager: {
      createChatThread: (m, i) => m.createChatThread({ parentMessageId: String(i.msgId || i.parentMessageId), name: i.name || i.subject || "", message: i.message }),
      destroyChatThread: (m, i) => m.destroyChatThread({ chatThreadId: String(i.threadId || i.chatThreadId) }),
      fetchChatThreadDetail: (m, i) => m.getChatThreadInfo({ chatThreadId: String(i.threadId || i.chatThreadId) }),
      fetchChatThreadMember: (m, i) => m.getChatThreadMemberList({ chatThreadId: String(i.threadId || i.chatThreadId), pageSize: pageSize(i), cursor: i.cursor || "" }),
      fetchChatThreadsWithParentId: (m, i) => m.getChatThreadList({ parentMessageId: String(i.msgId || i.parentMessageId), pageSize: pageSize(i), cursor: i.cursor || "" }),
      fetchJoinedChatThreads: (m, i) => m.getJoinedChatThreadList(pageOptions(i)),
      fetchJoinedChatThreadsWithParentId: (m, i) => m.getJoinedChatThreadList({ ...pageOptions(i), parentMessageId: String(i.msgId || i.parentMessageId) }),
      fetchLastMessageWithChatThreads: (m, i) => m.getChatThreadLastMessageList({ threadIds: i.threadIds || [] }),
      joinChatThread: (m, i) => m.joinChatThread({ chatThreadId: String(i.threadId || i.chatThreadId) }),
      leaveChatThread: (m, i) => m.leaveChatThread({ chatThreadId: String(i.threadId || i.chatThreadId) }),
      removeMemberFromChatThread: (m, i) => m.removeChatThreadMember({ chatThreadId: String(i.threadId || i.chatThreadId), userId: userId(i) }),
      updateChatThreadSubject: (m, i) => m.updateChatThreadName({ chatThreadId: String(i.threadId || i.chatThreadId), name: i.subject || i.name || "" }),
    },
    PushManager: {
      bindDeviceToken: (m, i) => m.uploadPushToken({ deviceToken: String(i.token || i.deviceToken || ""), deviceId: i.deviceId }),
      fetchConversationSilentMode: (m, i) => m.getConversationSilentMode(pushConversation(i)),
      fetchPreferredNotificationLanguage: (m) => m.getPushLanguage(),
      fetchSilentModeForAll: (m) => m.getGlobalSilentMode(),
      fetchSilentModeForConversations: (m, i) => m.getConversationSilentModes({ conversationIds: i.conversationIds || i.convIds || [] }),
      removeConversationSilentMode: (m, i) => m.clearConversationRemindType(pushConversation(i)),
      setConversationSilentMode: (m, i) => m.setConversationSilentMode(pushConversation(i)),
      setPreferredNotificationLanguage: (m, i) => m.setPushLanguage({ language: String(i.language || "") }),
      setSilentModeForAll: (m, i) => m.setGlobalSilentMode(i.mode || i.silentMode || {}),
      updateFCMPushToken: (m, i) => m.uploadPushToken({ deviceToken: String(i.token || i.deviceToken || ""), deviceType: "fcm" }),
      updateHMSPushToken: (m, i) => m.uploadPushToken({ deviceToken: String(i.token || i.deviceToken || ""), deviceType: "hms" }),
    },
    UserInfoManager: {
      fetchOwnInfo: async (m) => {
        const profiles = await m.getUserInfoByUserId({ userIds: [currentUser] });
        return profiles.find((profile) => String(profile?.userId || "") === currentUser) || null;
      },
      fetchSubscribedUsers: (m) => m.getSubscribedUsers(),
      fetchUserInfoById: async (m, i) => userInfoMap(await m.getUserInfoByUserId({ userIds: userIds(i) })),
      fetchUserInfoByIdWithType: async (m, i) => userInfoMap(await m.getUserInfoByAttribute({ userIds: userIds(i), attributes: i.attributes || i.type || [] })),
      getUserInfoWithUserId: async (m, i) => {
        const id = userId(i);
        const profiles = await m.getUserInfoByUserId({ userIds: [id] });
        return profiles.find((profile) => String(profile?.userId || "") === id) || null;
      },
      getUserInfoWithUserIds: async (m, i) => userInfoMap(await m.getUserInfoByUserId({ userIds: userIds(i) })),
      subscribeUsersInfo: (m, i) => m.subscribeUsersInfo({ userIds: i.userIds || [], expires: i.expires }),
      unsubscribeUsersInfo: (m, i) => m.unsubscribeUsersInfo({ userIds: i.userIds || [] }),
      updateOwnUserInfo: (m, i) => m.updateOwnInfo(i.userInfo || i.info || {}),
      updateOwnUserInfoWithType: (m, i) => m.updateOwnInfoByAttribute(i.userInfo || i.info || {}),
    },
  };

  return { invoke };

  async function invokeClient(cmd, info) {
    if (cmd === "init") return null;
    if (cmd === "isConnected") return client.getConnectionState() === "connected";
    if (cmd === "getCurrentDeviceId") return String(client.getClientResource?.() || "webim");
    if (cmd === "getCurrentUser") return { userId: client.getCurrentUserId() || currentUser };
    if (cmd === "getUserIdsWithRTCUids") return client.getUserIdsWithRTCUids(info);
    if (cmd === "getRTCTokenInfoWithChannelName") return client.getRTCTokenInfo(info);
    if (cmd === "login") {
      currentUser = String(info.userId || "");
      const result = await client.login({ userId: currentUser, token: String(info.pwdOrToken || info.token || "") });
      return result ?? currentUser;
    }
    if (cmd === "renewToken") return client.renewToken(String(info.token || info.pwdOrToken || ""));
    if (cmd === "logout") {
      await client.logout();
      currentUser = "";
      messages.clear();
      return null;
    }
    throw new Error(`Web 5.0 wrapper does not support Client.${cmd}`);
  }

  async function invokeChat(cmd, info) {
    if (cmd === "sendMessage") {
      const message = buildMessage(info);
      const localId = message.msgLocalId;
      const sent = await chat.sendMessage(message);
      const result = sent || message;
      const canonical = canonicalWeb5Message(result, { direction: 0, currentUser });
      messages.set(canonical.msgId || localId, canonical);
      emit("onMessageSuccess", { msgId: localId, msg: canonical });
      return { ...canonical, msgId: localId };
    }
    if (cmd === "createTextMessage") return jsonSafe(chat.createTextMessage(info));
    if (cmd === "addReaction") {
      await chat.addReaction({ messageId: String(info.msgId || info.messageId), reaction: String(info.reaction) });
      return null;
    }
    if (cmd === "removeReaction") {
      await chat.removeReaction({ messageId: String(info.msgId || info.messageId), reaction: String(info.reaction) });
      return null;
    }
    if (cmd === "fetchReactionList" || cmd === "getReactionList") return chat.getReactionList({ messageId: String(info.msgId || info.messageId) });
    if (cmd === "fetchReactionDetail" || cmd === "getReactionDetail") return chat.getReactionDetail(info);
    if (cmd === "fetchHistoryMessages" || cmd === "getHistoryMessages") return chat.getHistoryMessages(historyOptions(info));
    if (cmd === "recallMessage") return chat.recallMessage({ conversationId: String(info.convId || info.conversationId), conversationType: conversationType(info.chatType || info.conversationType), messageId: String(info.msgId || info.messageId), ext: info.ext });
    if (cmd === "modifyMessage") return chat.modifyMessage({ conversationId: String(info.convId || info.conversationId), conversationType: conversationType(info.chatType || info.conversationType), messageId: String(info.msgId || info.messageId), message: { type: webMessageType(info.body), body: info.body || {}, ext: info.ext } });
    if (cmd === "clearConversationUnreadMessageCount") return chat.clearConversationUnreadMessageCount(unreadOptions(info));
    if (cmd === "sendMessageReadReceipts") return chat.sendMessageReadReceipts(info);
    throw new Error(`Web 5.0 wrapper does not support ChatManager.${cmd}`);
  }

  async function invokeContact(cmd, info) {
    if (cmd === "getAllContacts" || cmd === "getContacts") return contacts.getContacts();
    if (cmd === "addContact") return contacts.addContact({ userId: String(info.userId), message: info.message });
    if (cmd === "deleteContact") return contacts.deleteContact({ userId: String(info.userId) });
    if (cmd === "acceptInvitation") return contacts.acceptContactInvite({ userId: String(info.userId) });
    if (cmd === "declineInvitation") return contacts.declineContactInvite({ userId: String(info.userId) });
    if (cmd === "setContactRemark") return contacts.setContactRemark({ userId: String(info.userId), remark: String(info.remark || "") });
    if (cmd === "getBlockListFromDB") return contacts.getBlocklist();
    if (cmd === "addUserToBlockList") return contacts.addUsersToBlocklist({ userIds: [String(info.userId)] });
    if (cmd === "removeUserFromBlockList") return contacts.removeUserFromBlocklist({ userIds: [String(info.userId)] });
    throw new Error(`Web 5.0 wrapper does not support ContactManager.${cmd}`);
  }

  async function invokeGroup(cmd, info) {
    if (cmd === "getJoinedGroups" || cmd === "getJoinedGroupList") return groups.getJoinedGroupList(info);
    if (cmd === "getGroupMemberListFromServer" || cmd === "getGroupMemberList") return groups.getGroupMemberList(info);
    if (cmd === "getGroupWithId" || cmd === "getGroup") return jsonSafe(groups.getGroup(String(info.groupId)));
    if (cmd === "createGroup") return groups.createGroup(groupOptions(info));
    if (cmd === "joinPublicGroup" || cmd === "requestToJoinPublicGroup" || cmd === "joinGroup") return groups.joinGroup({ groupId: String(info.groupId), message: info.message });
    if (cmd === "leaveGroup") return groups.leaveGroup({ groupId: String(info.groupId) });
    if (cmd === "destroyGroup") return groups.destroyGroup({ groupId: String(info.groupId) });
    if (cmd === "addMembers") return groups.inviteUsersToGroup({ groupId: String(info.groupId), userIds: info.members || info.userIds || [] });
    if (cmd === "removeMembers") return groups.removeGroupMembers({ groupId: String(info.groupId), userIds: info.members || info.userIds || [] });
    if (cmd === "getGroupSpecificationFromServer") return groups.getGroupInfo({ groupId: String(info.groupId) });
    throw new Error(`Web 5.0 wrapper does not support GroupManager.${cmd}`);
  }

  async function invokePresence(cmd, info) {
    if (cmd === "publishPresenceWithDescription" || cmd === "publishPresence") return presence.publishPresence(info);
    if (cmd === "presenceSubscribe" || cmd === "subscribePresence") return presence.subscribePresence({ userIds: info.userIds || [] });
    if (cmd === "presenceUnsubscribe" || cmd === "unsubscribePresence") return presence.unsubscribePresence({ userIds: info.userIds || [] });
    if (cmd === "fetchPresenceStatus" || cmd === "getPresenceStatus") return presence.getPresenceStatus({ userIds: info.userIds || [] });
    throw new Error(`Web 5.0 wrapper does not support PresenceManager.${cmd}`);
  }

  function buildMessage(info) {
    const body = info.body || {};
    const options = messageOptions(info);
    const type = bodyType(body);
    if (type === 0) return chat.createTextMessage({ ...options, content: String(body.content || ""), targetLanguages: body.targetLanguages });
    if (type === 6) return chat.createCmdMessage({ ...options, action: String(body.action || ""), deliverOnlineOnly: Boolean(body.deliverOnlineOnly ?? info.deliverOnlineOnly) });
    if (type === 7) return chat.createCustomMessage({ ...options, event: String(body.event || ""), params: body.params || {} });
    if (type === 3) return chat.createLocationMessage({ ...options, latitude: Number(body.latitude || 0), longitude: Number(body.longitude || 0), address: body.address, buildingName: body.buildingName });
    if (type === 1) return chat.createImageMessage(mediaOptions(body, options));
    if (type === 2) return chat.createVideoMessage({ ...mediaOptions(body, options), duration: Number(body.duration || 0), thumbnailUrl: body.thumbnailRemotePath || body.thumbnailUrl });
    if (type === 4) return chat.createVoiceMessage({ ...mediaOptions(body, options), duration: Number(body.duration || 0) });
    if (type === 5) return chat.createFileMessage(mediaOptions(body, options));
    throw new Error(`Web 5.0 wrapper does not support message body type ${body.type}`);
  }

  function messageOptions(info) {
    return { conversationId: String(info.to || info.convId || info.conversationId), conversationType: conversationType(info.chatType || info.conversationType), ext: info.ext, deliverOnlineOnly: info.deliverOnlineOnly, needReadReceipt: info.needReadReceipt };
  }

  function mediaOptions(body, options) {
    const local = String(body.localPath || body.filePath || "");
    const remote = String(body.remotePath || body.originalUrl || body.url || "");
    const source = remote.startsWith("http://") || remote.startsWith("https://") || remote.startsWith("blob:") ? remote : undefined;
    return {
      ...options,
      data: body.data,
      originalUrl: source,
      filename: String(body.displayName || body.filename || local.split("/").pop() || "attachment"),
      filetype: body.filetype || body.mimeType,
      fileLength: body.fileSize || body.fileLength,
      width: body.width,
      height: body.height,
      isGif: Boolean(body.isGif),
    };
  }

  function emitError(error) { emit("onError", { error: jsonSafe(error) }); }

  function handleMessages(payload, eventType, direction) {
    const canonical = extractMessages(payload).map((message) => canonicalWeb5Message(message, { direction, currentUser }));
    for (const message of canonical) if (message.msgId) messages.set(message.msgId, message);
    emit(eventType, { messages: canonical });
  }
}

function extractMessages(payload) {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.messages)) return payload.messages;
  if (payload?.message) return Array.isArray(payload.message) ? payload.message : [payload.message];
  return payload ? [payload] : [];
}

function canonicalWeb5Message(raw, { direction, currentUser }) {
  const msgId = String(raw?.msgServerId || raw?.msgId || raw?.messageId || raw?.id || raw?.msgLocalId || "");
  const from = String(raw?.from || raw?.sender?.userId || (direction === 0 ? currentUser : ""));
  const to = String(raw?.to || raw?.conversationId || (direction === 1 ? currentUser : ""));
  const body = raw?.body || {};
  return { msgId, msgLocalId: String(raw?.msgLocalId || ""), from, to, convId: String(raw?.conversationId || (direction === 0 ? to : from)), chatType: numericChatType(raw?.conversationType), direction, status: raw?.sendStatus === "failed" ? 3 : 2, hasRead: Boolean(raw?.isPeerRead ?? direction === 1), hasReadAck: Boolean(raw?.isPeerRead), hasDeliverAck: direction === 1 || raw?.sendStatus === "sent", needGroupAck: Boolean(raw?.needReadReceipt), isThread: Boolean(raw?.isChatThread), isContentReplaced: Boolean(raw?.isContentReplaced), deliverOnlineOnly: Boolean(raw?.deliverOnlineOnly), body: { type: bodyType(body), content: body.content ?? body.text ?? raw?.content ?? "", ...jsonSafe(body) } };
}

function normalizeWeb5Reaction(raw, currentUser) {
  const items = Array.isArray(raw) ? raw : [raw];
  return { events: items.filter(Boolean).map((event) => ({ convId: String(event.conversationId || event.convId || ""), msgId: String(event.messageId || event.msgId || ""), operations: (event.operations || event.reactions || []).map((item) => ({ userId: String(item.userId || item.operator || item.operatorId || ""), reaction: String(item.reaction || ""), operate: item.operate === 0 || item.reactionType === "delete" ? 0 : 1 })), reactions: Array.isArray(event.reactions) ? event.reactions.map((item) => ({ reaction: String(item.reaction || ""), count: Number(item.count || 0), isAddedBySelf: Array.isArray(item.userList) && item.userList.includes(currentUser), userList: Array.isArray(item.userList) ? item.userList.map(String) : [] })) : [] })) };
}

function historyOptions(info) {
  return { conversationId: String(info.convId || info.conversationId), conversationType: conversationType(info.chatType || info.conversationType), cursor: String(info.cursor || ""), pageSize: Number(info.pageSize || 20), searchDirection: info.searchDirection === 1 || info.searchDirection === "up" ? "up" : "down" };
}

function unreadOptions(info) { return { conversationId: String(info.convId || info.conversationId), conversationType: conversationType(info.chatType || info.conversationType) }; }
function groupOptions(info) { return { name: String(info.groupName || info.name || ""), description: info.description, memberIds: info.members || info.memberIds || [], isPublic: Boolean(info.isPublic), joinApprovalRequired: Boolean(info.joinApprovalRequired), allowInvites: Boolean(info.allowInvites) }; }
function bodyType(body) {
  const value = body?.type;
  if (value === 0 || value === "txt" || value === "text") return 0;
  if (value === 1 || value === "image") return 1;
  if (value === 2 || value === "video") return 2;
  if (value === 3 || value === "location") return 3;
  if (value === 4 || value === "voice") return 4;
  if (value === 5 || value === "file") return 5;
  if (value === 6 || value === "cmd" || value === "command") return 6;
  if (value === 7 || value === "custom") return 7;
  if (value === 8 || value === "combine") return 8;
  return Number(value || 0);
}
function webMessageType(body) { return bodyType(body) === 7 ? "custom" : "text"; }
function conversationType(value) { return Number(value) === 1 ? "groupChat" : Number(value) === 2 ? "chatRoom" : value === "groupChat" || value === "chatRoom" ? value : "singleChat"; }
function numericChatType(value) { return value === "groupChat" ? 1 : value === "chatRoom" ? 2 : 0; }
function jsonSafe(value) { if (value == null) return value; try { return JSON.parse(JSON.stringify(value)); } catch { return String(value); } }
function normalizeRecallEvent(payload) {
  const value = payload?.infos || payload?.recallInfos || payload?.messages || payload;
  const infos = Array.isArray(value) ? value : value ? [value] : [];
  return { infos: jsonSafe(infos) };
}

function pageSize(info) { return Number(info.pageSize || info.limit || 20); }
function pageOptions(info) {
  return {
    pageSize: pageSize(info),
    cursor: String(info.cursor || ""),
    pageNum: Number(info.pageNum || info.pageNo || 1),
  };
}
function conversationListOptions(info) {
  const options = {};
  if (typeof info?.isPinned === "boolean") options.isPinned = info.isPinned;
  if (Number.isInteger(info?.mark)) options.mark = info.mark;
  return options;
}
function roomId(info) { return String(info.chatRoomId || info.roomId || info.id || ""); }
function groupId(info) { return String(info.groupId || info.id || ""); }
function userId(info) { return String(info.userId || info.username || info.member || info.operator || ""); }
function userIds(info) {
  const values = info?.userIds || info?.usernames || info?.ids || [];
  return Array.isArray(values) ? values.map(String) : [String(values)];
}
function members(info) { return info.members || info.userIds || info.usernames || []; }
function userInfoMap(profiles) {
  return Object.fromEntries(
    (Array.isArray(profiles) ? profiles : [])
      .filter((profile) => profile && profile.userId)
      .map((profile) => [String(profile.userId), profile]),
  );
}
function readReceiptOptions(info) {
  return {
    messageId: String(info.msgId || info.messageId || ""),
    conversationId: String(info.convId || info.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType),
    messageIds: info.msgIds || info.messageIds || [],
  };
}
function groupReceiptOptions(info) {
  return {
    messageId: String(info.msgId || info.messageId || ""),
    groupId: groupId(info),
    pageSize: pageSize(info),
    cursor: String(info.cursor || ""),
  };
}
function conversationMarkOptions(info) {
  return {
    conversationId: String(info.convId || info.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType),
    mark: info.mark || info.markId || info.conversationMark,
  };
}
function historyDeleteOptions(info) {
  return {
    conversationId: String(info.convId || info.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType),
    timestamp: info.timestamp || info.ts,
  };
}
function downloadOptions(info) {
  return {
    messageId: String(info.msgId || info.messageId || ""),
    remoteUrl: info.remoteUrl || info.url,
    localPath: info.localPath || info.filePath,
    secretKey: info.secretKey,
    isThumbnail: Boolean(info.isThumbnail || info.thumbnail),
  };
}
function searchOptions(info) {
  return {
    conversationId: String(info.convId || info.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType),
    keywords: String(info.keyword || info.keywords || ""),
    pageSize: pageSize(info),
    cursor: String(info.cursor || ""),
    searchDirection: info.searchDirection,
  };
}
function pushConversation(info) {
  return {
    conversationId: String(info.convId || info.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType),
    silentModeParam: info.silentMode || info.silentModeParam || info,
  };
}
function modifyOptions(info) {
  const source = info.message || {};
  return {
    conversationId: String(info.convId || info.conversationId || source.conversationId || ""),
    conversationType: conversationType(info.chatType || info.conversationType || source.conversationType),
    messageId: String(info.msgId || info.messageId || source.messageId || ""),
    message: {
      type: webMessageType(info.body || source.body || {}),
      body: info.body || source.body || {},
      ext: info.ext || source.ext,
    },
  };
}
