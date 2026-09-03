/** Web 5.0 ChatManager adapter and message/conversation event registration. */
export function createChatManagerWrapper({ manager, emit, registerEvents, h, currentUser, messages }) {
  const commands = {
    ackConversationRead: (m, i) =>
      m.clearConversationUnreadMessageCount(h.unreadOptions(i)),
    ackGroupMessageRead: async (m, i) => {
      await m.sendMessageReadReceipts(h.readReceiptOptions(i));
      return true;
    },
    ackMessageRead: async (m, i) => {
      await m.sendMessageReadReceipts(h.readReceiptOptions(i));
      return true;
    },
    addRemoteAndLocalConversationsMark: (m, i) => m.addConversationMark(h.conversationMarkOptions(i)),
    asyncFetchGroupAcks: (m, i) => m.getGroupMessageReadReceipts(h.groupReceiptOptions(i)),
    deleteAllMessageAndConversation: (m) => m.clearAllMessagesAndConversations(),
    deleteConversation: (m, i) => m.deleteConversation({
      conversationId: String(i.convId || i.conversationId || ""),
      conversationType: h.protocolConversationType(i),
      deleteRoamingMessages: Boolean(i.deleteMessages ?? i.deleteRoamingMessages),
    }),
    deleteConversations: (m, i) => Promise.all((i.convIds || i.conversationIds || []).map((id) => m.deleteConversation({
      conversationId: String(id),
      conversationType: h.protocolConversationType(i),
      deleteRoamingMessages: Boolean(i.deleteMessages ?? i.deleteRoamingMessages),
    }))),
    deleteMessagesBeforeTimestamp: (m, i) => m.removeHistoryMessages(h.historyDeleteOptions(i)),
    deleteRemoteAndLocalConversationsMark: (m, i) => m.removeConversationMark(h.conversationMarkOptions(i)),
    downloadAndParseCombineMessage: (m, i) => m.downloadAndParseCombineMessage(i),
    downloadAttachment: (m, i) => downloadAttachment(m, i, false),
    downloadThumbnail: (m, i) => downloadAttachment(m, i, true),
    fetchHistoryMessagesByOptions: async (m, i) => normalizeHistoryResult(
      await m.getHistoryMessages(h.historyOptions(i)),
    ),
    fetchPinnedMessages: (m, i) => m.getPinnedMessageList({ conversationId: String(i.convId || i.conversationId), conversationType: h.conversationType(i.chatType || i.conversationType) }),
    fetchSupportLanguages: (m) => m.getSupportedTranslationLanguages(),
    getGroupMessageReadReceipts: (m, i) => m.getGroupMessageReadReceipts(h.groupReceiptOptions(i)),
    loadAllConversations: (m, i) => m.getConversationList(h.conversationListOptions(i)),
    loadConversationMessagesWithKeyword: (m, i) => m.searchMessages(h.searchOptions(i)),
    markAllChatMsgAsRead: async (m) => {
      await m.clearAllConversationUnreadMessageCount();
      return true;
    },
    pinConversation: (m, i) => m.setConversationPinned({ conversationId: String(i.convId ?? i.conversationId ?? ""), conversationType: h.conversationType(i.chatType || i.conversationType), pinned: Boolean(i.isPinned ?? i.pinned ?? true) }),
    pinMessage: (m, i) => m.pinMessage({ conversationId: String(i.convId || i.conversationId), conversationType: h.conversationType(i.chatType || i.conversationType), messageId: String(i.msgId || i.messageId), note: i.note }),
    removeMessagesFromServerWithMsgIds: (m, i) => m.removeHistoryMessages({
      conversationId: String(i.convId || i.conversationId || ""),
      conversationType: h.protocolConversationType(i),
      messageIds: i.msgIds || i.messageIds || [],
    }),
    removeMessagesFromServerWithTs: (m, i) => m.removeHistoryMessages(h.historyDeleteOptions(i)),
    resendMessage: (m, i) => m.sendMessage(i.message),
    searchChatMsgFromDB: (m, i) => m.searchMessages(h.searchOptions(i)),
    searchMessagesFromServer: (m, i) => m.searchMessages(h.searchOptions(i)),
    searchMsgsByOptions: (m, i) => m.searchMessages(h.searchOptions(i)),
    translateMessage: (m, i) => m.translateMessage({ messageId: String(i.msgId || i.messageId), targetLanguages: i.languages || i.targetLanguages || [] }),
    unpinMessage: (m, i) => m.unpinMessage({ conversationId: String(i.convId || i.conversationId), conversationType: h.conversationType(i.chatType || i.conversationType), messageId: String(i.msgId || i.messageId) }),
    updateChatMessage: (m, i) => m.modifyMessage(h.modifyOptions(i)),
    voiceFileToText: (m, i) => m.voiceFileToText(i),
    voiceMessageToText: (m, i) => m.voiceMessageToText(i),
  };

  function registerManagerEvents() {
    registerEvents(manager, [
      ["onConversationListUpdate", (payload) => emit("onConversationUpdate", h.jsonSafe(payload || {}))],
      ["onMultiDeviceConversation", (payload) => emit("onConversationUpdate", h.jsonSafe(payload || {}))],
      ["onMessage", (payload) => handleMessages(payload, "onMessagesReceived", 1)],
      ["onMessageDelivered", (payload) => handleMessages(payload, "onMessagesDelivered", 0)],
      ["onMessageReadReceipts", (payload) => emit("onMessagesRead", normalizeReadReceiptEvent(payload))],
      ["onMessageRecalled", (payload) => emit("onMessagesRecalledInfo", h.normalizeRecallEvent(payload))],
      ["onMessageUpdated", (payload) => emit("onMessageContentChanged", h.jsonSafe(payload || {}))],
      ["onMessageError", (payload) => emit("onMessageError", h.jsonSafe(payload || {}))],
      ["onMessageProgress", (payload) => emit("onMessageProgressUpdate", h.jsonSafe(payload || {}))],
      ["onReactionChanged", (payload) => emit("messageReactionDidChange", h.normalizeWeb5Reaction(payload, currentUser()))],
      ["onPinnedMessageChanged", (payload) => emit("onMessagePinChanged", h.jsonSafe(payload || {}))],
    ]);
  }

  async function invoke(cmd, info = {}) {
    if (cmd === "sendMessage") {
      const message = buildMessage(info);
      const sent = await manager.sendMessage(message);
      const canonical = normalizeMessage(sent, 0);
      const cached = canonical ? cacheMessage(canonical) : canonical;
      if (cached) emit("onMessageSuccess", { msgId: cached.msgId || cached.msgLocalId, msg: cached });
      return cached;
    }
    if (cmd === "createTextMessage") return h.jsonSafe(manager.createTextMessage(info));
    if (cmd === "addReaction") {
      return manager.addReaction({ messageId: String(info.msgId || info.messageId), reaction: String(info.reaction) });
    }
    if (cmd === "removeReaction") {
      return manager.removeReaction({ messageId: String(info.msgId || info.messageId), reaction: String(info.reaction) });
    }
    if (cmd === "fetchReactionList" || cmd === "getReactionList") {
      const result = await manager.getReactionList(h.reactionListOptions(info));
      return h.normalizeReactionListResult(result);
    }
    if (cmd === "fetchReactionDetail" || cmd === "getReactionDetail") {
      return manager.getReactionDetail(h.reactionDetailOptions(info));
    }
    if (cmd === "fetchHistoryMessages" || cmd === "getHistoryMessages") {
      return normalizeHistoryResult(await manager.getHistoryMessages(h.historyOptions(info)));
    }
    if (cmd === "recallMessage") return manager.recallMessage({ conversationId: String(info.convId || info.conversationId), conversationType: h.conversationType(info.chatType || info.conversationType), messageId: String(info.msgId || info.messageId), ext: info.ext });
    if (cmd === "modifyMessage") return manager.modifyMessage({ conversationId: String(info.convId || info.conversationId), conversationType: h.conversationType(info.chatType || info.conversationType), messageId: String(info.msgId || info.messageId), message: { type: h.webMessageType(info.body), body: info.body || {}, ext: info.ext } });
    if (cmd === "clearConversationUnreadMessageCount") return manager.clearConversationUnreadMessageCount(h.unreadOptions(info));
    if (cmd === "sendMessageReadReceipts") return manager.sendMessageReadReceipts(h.readReceiptOptions(info));
    throw new Error(`Web 5.0 wrapper does not support ChatManager.${cmd}`);
  }

  function buildMessage(info) {
    const body = info.body || {};
    const options = messageOptions(info);
    const type = h.bodyType(body);
    if (type === 0) {
      return manager.createTextMessage({
        ...options,
        content: String(body.content || ""),
        ...(body.targetLanguages == null ? {} : { targetLanguages: body.targetLanguages }),
      });
    }
    if (type === 6) return manager.createCmdMessage({ ...options, action: String(body.action || ""), deliverOnlineOnly: Boolean(body.deliverOnlineOnly ?? info.deliverOnlineOnly) });
    if (type === 7) return manager.createCustomMessage({ ...options, event: String(body.event || ""), params: body.params || {} });
    if (type === 3) return manager.createLocationMessage({ ...options, latitude: Number(body.latitude || 0), longitude: Number(body.longitude || 0), address: body.address, buildingName: body.buildingName });
    if (type === 1) return manager.createImageMessage(mediaOptions(body, options, type));
    if (type === 2) return manager.createVideoMessage({
      ...mediaOptions(body, options, type),
      ...(body.duration == null ? {} : { duration: Number(body.duration) }),
      ...(body.thumbnailRemotePath || body.thumbnailUrl
        ? { thumbnailUrl: body.thumbnailRemotePath || body.thumbnailUrl }
        : {}),
    });
    if (type === 4) return manager.createVoiceMessage({
      ...mediaOptions(body, options, type),
      ...(body.duration == null ? {} : { duration: Number(body.duration) }),
    });
    if (type === 5) return manager.createFileMessage(mediaOptions(body, options, type));
    throw new Error(`Web 5.0 wrapper does not support message body type ${body.type}`);
  }

  function messageOptions(info) {
    return {
      conversationId: String(info.to || info.convId || info.conversationId),
      conversationType: h.conversationType(info.chatType || info.conversationType),
      ext: info.ext,
      deliverOnlineOnly: info.deliverOnlineOnly,
      needReadReceipt: info.needReadReceipt,
      ...(info.webhookEnv == null ? {} : { webhookEnv: String(info.webhookEnv) }),
    };
  }

  function mediaOptions(body, options, type) {
    const local = String(body.localPath || body.filePath || "");
    const remote = String(body.remotePath || body.originalUrl || body.url || "");
    const source = remote.startsWith("http://") || remote.startsWith("https://") || remote.startsWith("blob:") ? remote : undefined;
    const mediaType = type === 1 ? "image" : type === 2 ? "video" : type === 4 ? "voice" : "file";
    const filename = body.displayName || body.filename || local.split("/").pop();
    const filetype = body.filetype || body.mimeType;
    const dimensions = {};
    if (body.width != null) dimensions.width = Number(body.width);
    if (body.height != null) dimensions.height = Number(body.height);
    return {
      ...options,
      ...(body.data == null ? {} : { data: body.data }),
      ...(source == null ? {} : { originalUrl: source }),
      ...(filename == null ? {} : { filename }),
      ...(filetype == null ? {} : { filetype }),
      ...(body.fileSize == null && body.fileLength == null ? {} : { fileLength: body.fileSize ?? body.fileLength }),
      ...dimensions,
      ...(body.isGif == null ? {} : { isGif: Boolean(body.isGif) }),
    };
  }

  async function downloadAttachment(manager, info, isThumbnail) {
    const message = info?.message && typeof info.message === "object" ? info.message : info;
    const normalized = normalizeMessage(message, 0, { read: true });
    const type = normalized?.type;
    if (!["image", "video", "voice", "file"].includes(type)) return normalized;

    // Web native ChatManager.downloadAttachment expects {message}, while
    // the common protocol carries the message directly under info.message.
    // The native result is binary metadata; return the common message shape
    // after the download, matching Android/iOS wrapper behavior.
    await manager.downloadAttachment({ message: normalized, isThumbnail });
    return normalized;
  }

  function normalizeHistoryResult(value) {
    const result = h.jsonSafe(value);
    if (!result || typeof result !== "object" || Array.isArray(result)) return result;
    const sourceItems = Array.isArray(result.list) ? result.list : result.items;
    if (!Array.isArray(sourceItems)) return result;
    const list = sourceItems.map((item) => {
      const from = item?.from ?? item?.sender?.userId;
      const direction = String(from || "") === String(currentUser() || "") ? 0 : 1;
      return normalizeMessage(item, direction);
    });
    const { items: _items, ...rest } = result;
    return { ...rest, list };
  }

  function handleMessages(payload, eventType, direction) {
    const canonical = h.extractMessages(payload).map((message) => normalizeMessage(message, direction));
    for (const message of canonical) cacheMessage(message);
    emit(eventType, { messages: canonical });
  }

  function cacheMessage(message) {
    const msgId = String(message?.msgId || message?.messageId || "");
    if (!msgId) return message;
    const existing = messages.get(msgId)
      || Array.from(messages.values()).find((item) => (
        String(item?.msgId || item?.messageId || "") === msgId
      ));
    if (!existing) {
      messages.set(msgId, message);
      return message;
    }
    const incomingBody = message.body && typeof message.body === "object" ? message.body : {};
    const existingBody = existing.body && typeof existing.body === "object" ? existing.body : {};
    const merged = {
      ...existing,
      ...message,
      from: message.from ?? existing.from,
      to: message.to ?? existing.to,
      body: {
        ...existingBody,
        ...incomingBody,
        content: incomingBody.content ?? existingBody.content,
      },
    };
    messages.set(msgId, merged);
    return merged;
  }

  function normalizeMessage(rawMessage, direction, { read = false } = {}) {
    const message = h.canonicalWeb5Message(rawMessage) || {};
    const type = message.type != null
      ? h.bodyType({ type: message.type })
      : h.bodyType(message.body || {});
    const sourceBody = message.body && typeof message.body === "object" ? message.body : {};
    const body = { ...sourceBody };
    if (message.type != null || sourceBody.type != null || sourceBody.bodyType != null) body.type = type;
    if ([1, 2, 4, 5].includes(type)) {
      if (body.displayName == null && body.filename != null) body.displayName = body.filename;
    }
    const direct = message.direct;
    const directDirection = direct === "SEND" ? 0 : direct === "RECEIVE" ? 1 : undefined;
    const senderId = String(message.from || "").split("/", 1)[0];
    const currentUserId = String(currentUser() || "").split("/", 1)[0];
    const inferredDirection = directDirection ?? (
      senderId && currentUserId ? (senderId === currentUserId ? 0 : 1) : direction
    );
    return {
      ...message,
      direction: message.direction ?? inferredDirection,
      ...(message.status == null ? {} : { status: message.status }),
      ...(message.hasRead == null ? {} : { hasRead: message.hasRead }),
      ...(message.isPeerRead == null ? {} : { isPeerRead: message.isPeerRead }),
      ...(message.needReadReceipt == null ? {} : { needReadReceipt: message.needReadReceipt }),
      ...(message.deliverOnlineOnly == null ? {} : { deliverOnlineOnly: message.deliverOnlineOnly }),
      ...(message.isThread == null ? {} : { isThread: message.isThread }),
      ...(message.isContentReplaced == null ? {} : { isContentReplaced: message.isContentReplaced }),
      body,
    };
  }

  function normalizeReadReceiptEvent(payload) {
    const rawPayload = h.jsonSafe(payload || {});
    const source = rawPayload?.data && typeof rawPayload.data === "object"
      ? rawPayload.data
      : rawPayload;
    const messageIds = Array.isArray(source?.messageIds)
      ? source.messageIds.map(String)
      : [];
    const receiptDetails = Array.isArray(source?.receiptDetails)
      ? source.receiptDetails
      : [];
    const messages = messageIds.map((messageId) => {
      const detail = receiptDetails.find((item) => String(item?.messageId || "") === messageId);
      return {
        msgId: messageId,
        ...(typeof detail?.count === "number" ? { readReceiptCount: detail.count } : {}),
      };
    });
    return {
      ...source,
      ...(source?.conversationId == null ? {} : { convId: String(source.conversationId) }),
      ...(source?.conversationType == null ? {} : { chatType: h.numericChatType(source.conversationType) }),
      messages,
    };
  }

  return { commands, invoke, registerManagerEvents };
}
