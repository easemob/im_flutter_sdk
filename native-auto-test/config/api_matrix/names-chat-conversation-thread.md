# iOS / Android 原生 5.0 名称映射

## 方法名映射表

### ChatManager

| 模块 / 能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| ChatManager / 注册消息监听 | `addDelegate` | `addMessageListener` | SIGNATURE_DIFFERENCE |
| ChatManager / 移除消息监听 | `removeDelegate` | `removeMessageListener` | SIGNATURE_DIFFERENCE |
| ChatManager / 注册会话监听 | `addConversationDelegate` | `addConversationListener` | SIGNATURE_DIFFERENCE |
| ChatManager / 移除会话监听 | `removeConversationDelegate` | `removeConversationListener` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取全部会话 | `getAllConversations` | `getAllConversations` / `getAllConversationsBySort` | SIGNATURE_DIFFERENCE |
| ChatManager / 过滤会话 | `filterConversationsFromDB` | `asyncFilterConversationsFromDB` | SIGNATURE_DIFFERENCE |
| ChatManager / 清会话内存缓存 | `cleanConversationsMemoryCache` | `cleanConversationsMemoryCache` | EXACT_MATCH |
| ChatManager / 按会话类型过滤 | — | `getConversationsByType` | ANDROID_ONLY |
| ChatManager / 获取未读总数 | `getUnreadMessageCount` | `getUnreadMessageCount` | SIGNATURE_DIFFERENCE |
| ChatManager / 置顶会话 | `pinConversation` | `asyncPinConversation` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取会话 | `getConversationWithConvId` / `getConversation` | `getConversation` | SIGNATURE_DIFFERENCE |
| ChatManager / 删除本地会话 | `deleteConversation` | `deleteConversation` | SIGNATURE_DIFFERENCE |
| ChatManager / 删除服务端会话 | `deleteServerConversation` | `deleteConversationFromServer` | SIGNATURE_DIFFERENCE |
| ChatManager / 批量删除会话 | `deleteConversations` | `asyncDeleteConversations` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取单条消息 | `getMessageWithMessageId` | `getMessage` | SIGNATURE_DIFFERENCE |
| ChatManager / 批量加载消息 | `getMessages` | `asyncLoadMessages` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取附件目录 | `getMessageAttachmentPath` | `EMConversation.getMessageAttachmentPath` | SIGNATURE_DIFFERENCE |
| ChatManager / 导入消息 | `importMessages` | `importMessages` | SIGNATURE_DIFFERENCE |
| ChatManager / 保存单消息 | — | `saveMessage` | ANDROID_ONLY |
| ChatManager / 更新消息 | `updateMessage` | `updateMessage` | SIGNATURE_DIFFERENCE |
| ChatManager / 修改已发消息 | `modifyMessage` | `asyncModifyMessage` | SIGNATURE_DIFFERENCE |
| ChatManager / 发送已读回执 | `sendMessageReadReceipts` | `asyncSendMessageReadReceipts` | SIGNATURE_DIFFERENCE |
| ChatManager / 清单会话未读 | `clearConversationUnreadMessageCount` | `asyncClearConversationUnreadMessageCount` | SIGNATURE_DIFFERENCE |
| ChatManager / 清全部会话未读 | `clearAllConversationUnreadMessageCount` | `asyncClearAllConversationUnreadMessageCount` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取群消息已读回执 | `getGroupMessageReadReceipts` | `asyncGetGroupMessageReadReceipts` | SIGNATURE_DIFFERENCE |
| ChatManager / 撤回消息 | `recallMessageWithMessageId` | `recallMessage` / `asyncRecallMessage` | SIGNATURE_DIFFERENCE |
| ChatManager / 发送消息 | `sendMessage` | `sendMessage` | SIGNATURE_DIFFERENCE |
| ChatManager / 下载缩略图 | `downloadMessageThumbnail` | `downloadThumbnail` | SIGNATURE_DIFFERENCE |
| ChatManager / 下载附件 | `downloadMessageAttachment` | `downloadAttachment` | SIGNATURE_DIFFERENCE |
| ChatManager / 下载大图 | `downloadBigImageAttachment` | `downloadBigImage` | SIGNATURE_DIFFERENCE |
| ChatManager / 下载并解析合并消息 | `downloadAndParseCombineMessage` | `downloadAndParseCombineMessage` | SIGNATURE_DIFFERENCE |
| ChatManager / 分页获取群消息已读用户 | `asyncFetchGroupMessageReadUsersFromServer` | `asyncFetchGroupMessageReadReceipts` | SIGNATURE_DIFFERENCE |
| ChatManager / 删除时间点前本地消息 | `deleteMessagesBefore` | `deleteMessagesBeforeTimestamp` | SIGNATURE_DIFFERENCE |
| ChatManager / 删除服务端消息 | `removeMessagesFromServerWithConversation` | `EMConversation.removeMessagesFromServer` | SIGNATURE_DIFFERENCE |
| ChatManager / 翻译消息 | `translateMessage` | `translateMessage` | SIGNATURE_DIFFERENCE |
| ChatManager / 语音消息转文字 | `voiceMessageToText` | `voiceMessageToText` | SIGNATURE_DIFFERENCE |
| ChatManager / 语音文件转文字 | `voiceFileToText` | `voiceFileToText` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取支持语言 | `fetchSupportedLanguages` | `fetchSupportLanguages` | SIGNATURE_DIFFERENCE |
| ChatManager / 本地搜索消息 | `searchMessagesWithTypes` / `loadMessagesWithKeyword` | `searchMsgFromDB` | SIGNATURE_DIFFERENCE |
| ChatManager / 跨会话关键词搜索 | `loadConversationMessagesWithKeyword` | `asyncLoadConversationMessagesWithKeyword` | SIGNATURE_DIFFERENCE |
| ChatManager / 添加 Reaction | `addReaction` | `addReaction` / `asyncAddReaction` | SIGNATURE_DIFFERENCE |
| ChatManager / 移除 Reaction | `removeReaction` | `removeReaction` / `asyncRemoveReaction` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取 Reaction 列表 | `getReactionList` | `getReactionList` / `asyncGetReactionList` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取 Reaction 明细 | `getReactionDetail` | `getReactionDetail` / `asyncGetReactionDetail` | SIGNATURE_DIFFERENCE |
| ChatManager / 拉取服务端历史消息 | `fetchMessagesFromServerBy` | `asyncFetchHistoryMessages` | SIGNATURE_DIFFERENCE |
| ChatManager / 搜索服务端消息 | `searchMessagesFromServerWithOption` | `asyncSearchMessagesFromServer` | SIGNATURE_DIFFERENCE |
| ChatManager / 添加会话标记 | `addConversationMark` | `asyncAddConversationMark` | SIGNATURE_DIFFERENCE |
| ChatManager / 移除会话标记 | `removeConversationMark` | `asyncRemoveConversationMark` | SIGNATURE_DIFFERENCE |
| ChatManager / 删除全部消息和会话 | `deleteAllMessagesAndConversations` | `asyncDeleteAllMsgsAndConversations` | SIGNATURE_DIFFERENCE |
| ChatManager / 置顶消息 | `pinMessage` | `asyncPinMessage` | SIGNATURE_DIFFERENCE |
| ChatManager / 取消置顶消息 | `unpinMessage` | `asyncUnPinMessage` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取置顶消息 | `getPinnedMessagesFromServer` | `asyncGetPinnedMessagesFromServer` | SIGNATURE_DIFFERENCE |
| ChatManager / 获取服务端消息总数 | `getMessageCountWithCompletion` | `asyncGetMessageCount` | SIGNATURE_DIFFERENCE |
| ChatManager / 标记语音已听 | — | `setVoiceMessageListened` | ANDROID_ONLY |

### Conversation

| 模块 / 能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| Conversation / 会话 ID | `conversationId` | `conversationId` | SIGNATURE_DIFFERENCE |
| Conversation / 会话名称 | `conversationName` | `getConversationName` | SIGNATURE_DIFFERENCE |
| Conversation / 会话头像 | `conversationAvatar` | `getConversationAvatar` | SIGNATURE_DIFFERENCE |
| Conversation / 会话类型 | `type` | `getType` | SIGNATURE_DIFFERENCE |
| Conversation / 未读数 | `unreadMessagesCount` | `getUnreadMsgCount` | SIGNATURE_DIFFERENCE |
| Conversation / 消息数 | `messagesCount` / `getMessageCountStart` | `getAllMsgCount` | SIGNATURE_DIFFERENCE |
| Conversation / 扩展字段 | `ext` | `setExtField` / `getExtField` | SIGNATURE_DIFFERENCE |
| Conversation / 是否 Thread 会话 | `isChatThread` | `isChatThread` | SIGNATURE_DIFFERENCE |
| Conversation / 是否置顶 | `isPinned` | `isPinned` | SIGNATURE_DIFFERENCE |
| Conversation / 置顶时间 | `pinnedTime` | `getPinnedTime` | SIGNATURE_DIFFERENCE |
| Conversation / 最新消息 | `latestMessage` | `getLastMessage` | SIGNATURE_DIFFERENCE |
| Conversation / 最新收到消息 | `lastReceivedMessage` | `getLatestMessageFromOthers` | SIGNATURE_DIFFERENCE |
| Conversation / 会话标记 | `marks` | `marks` | SIGNATURE_DIFFERENCE |
| Conversation / 推送提醒类型 | `disturbType` | `pushRemindType` | SIGNATURE_DIFFERENCE |
| Conversation / 是否群会话 | — | `isGroup` | ANDROID_ONLY |
| Conversation / 插入消息 | `insertMessage` | `insertMessage` | SIGNATURE_DIFFERENCE |
| Conversation / 追加消息 | `appendMessage` | `appendMessage` | SIGNATURE_DIFFERENCE |
| Conversation / 删除单条消息 | `deleteMessageWithId` | `removeMessage` | SIGNATURE_DIFFERENCE |
| Conversation / 清空全部消息 | `deleteAllMessages` | `clearAllMessages` | SIGNATURE_DIFFERENCE |
| Conversation / 删除服务端消息 | `removeMessagesFromServerMessageIds` / `removeMessagesFromServerWithTimeStamp` | `removeMessagesFromServer` | SIGNATURE_DIFFERENCE |
| Conversation / 更新消息 | `updateMessageChange` | `updateMessage` | SIGNATURE_DIFFERENCE |
| Conversation / 获取置顶消息 | `pinnedMessages` | `pinnedMessages` | SIGNATURE_DIFFERENCE |
| Conversation / 按 ID 获取消息 | `loadMessageWithId` | `getMessage` | SIGNATURE_DIFFERENCE |
| Conversation / 本地加载与搜索 | `loadMessagesStartFromId` / `loadMessagesWithType` / `searchMessagesWithTypes` / `loadMessagesWithKeyword` / `loadMessagesFrom` | `loadMoreMsgFromDB` / `searchMsgFromDB` / `asyncSearchMsgFromDB` | SIGNATURE_DIFFERENCE |
| Conversation / 搜索自定义消息 | `loadCustomMsgWithKeyword` | `searchCustomMsgFromDB` | SIGNATURE_DIFFERENCE |
| Conversation / 按时间范围删除消息 | `removeMessagesStart` | `removeMessages` | SIGNATURE_DIFFERENCE |
| Conversation / 获取当前全部消息 | — | `getAllMessages` | ANDROID_ONLY |
| Conversation / 仅清内存消息 | — | `clear` | ANDROID_ONLY |
| Conversation / 获取附件目录 | `IEMChatManager.getMessageAttachmentPath` | `getMessageAttachmentPath` | SIGNATURE_DIFFERENCE |
| Conversation / 类型转换帮助方法 | — | `msgType2ConversationType` | ANDROID_ONLY |

### ThreadManager

| 模块 / 能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| ThreadManager / 注册事件监听 | `addDelegate` | `addChatThreadChangeListener` | SIGNATURE_DIFFERENCE |
| ThreadManager / 移除事件监听 | `removeDelegate` | `removeChatThreadChangeListener` | SIGNATURE_DIFFERENCE |
| ThreadManager / 创建 Thread | `createChatThread` | `createChatThread` | SIGNATURE_DIFFERENCE |
| ThreadManager / 获取 Thread | `getChatThreadFromSever` | `getChatThreadFromServer` | SIGNATURE_DIFFERENCE |
| ThreadManager / 加入 Thread | `joinChatThread` | `joinChatThread` | SIGNATURE_DIFFERENCE |
| ThreadManager / 解散 Thread | `destroyChatThread` | `destroyChatThread` | SIGNATURE_DIFFERENCE |
| ThreadManager / 离开 Thread | `leaveChatThread` | `leaveChatThread` | SIGNATURE_DIFFERENCE |
| ThreadManager / 更新 Thread 名称 | `updateChatThreadName` | `updateChatThreadName` | SIGNATURE_DIFFERENCE |
| ThreadManager / 移除成员 | `removeMemberFromChatThread` | `removeMemberFromChatThread` | SIGNATURE_DIFFERENCE |
| ThreadManager / 获取成员 | `getChatThreadMemberListFromServerWithId` | `getChatThreadMembers` | SIGNATURE_DIFFERENCE |
| ThreadManager / 获取已加入 Thread | `getJoinedChatThreadsFromServerWithCursor` | `getJoinedChatThreadsFromServer` | SIGNATURE_DIFFERENCE |
| ThreadManager / 按父级获取 Thread | `getChatThreadsFromServerWithParentId` | `getChatThreadsFromServer` | SIGNATURE_DIFFERENCE |
| ThreadManager / 按父级获取已加入 Thread | `getJoinedChatThreadsFromServerWithParentId` | `getJoinedChatThreadsFromServer` | SIGNATURE_DIFFERENCE |
| ThreadManager / 获取 Thread 最新消息 | `getLastMessageFromSeverWithChatThreads` | `getChatThreadLatestMessage` | SIGNATURE_DIFFERENCE |

### ChatThread 模型

| 模块 / 能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| ChatThread / Thread ID | `threadId` | `getChatThreadId` | SIGNATURE_DIFFERENCE |
| ChatThread / Thread 名称 | `threadName` | `getChatThreadName` | SIGNATURE_DIFFERENCE |
| ChatThread / 所有者 | `owner` | `getOwner` | SIGNATURE_DIFFERENCE |
| ChatThread / 父级 ID | `parentId` | `getParentId` | SIGNATURE_DIFFERENCE |
| ChatThread / 创建消息 ID | `messageId` | `getMessageId` | SIGNATURE_DIFFERENCE |
| ChatThread / 成员数 | `membersCount` | `getMemberCount` | SIGNATURE_DIFFERENCE |
| ChatThread / 消息数 | `messageCount` | `getMessageCount` | SIGNATURE_DIFFERENCE |
| ChatThread / 创建时间 | `createAt` | `getCreateAt` | SIGNATURE_DIFFERENCE |
| ChatThread / 最新消息 | `lastMessage` | `getLastMessage` | SIGNATURE_DIFFERENCE |

## Callback 名映射表

| 模块 / 能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| 异步结果 / 成功 | `completion` | `EMCallBack.onSuccess` / `EMValueCallBack.onSuccess` | SIGNATURE_DIFFERENCE |
| 异步结果 / 失败 | `completion` | `EMCallBack.onError` / `EMValueCallBack.onError` | SIGNATURE_DIFFERENCE |
| 异步结果 / 进度 | `progress` | `EMCallBack.onProgress` / `EMValueCallBack.onProgress` | SIGNATURE_DIFFERENCE |
| Message callback / 新消息 | `messagesDidReceive` | `onMessageReceived` | SIGNATURE_DIFFERENCE |
| Message callback / 流式消息 | `onStreamMessagesReceived` | `onStreamMessageReceived` | SIGNATURE_DIFFERENCE |
| Message callback / 命令消息 | `cmdMessagesDidReceive` | `onCmdMessageReceived` | SIGNATURE_DIFFERENCE |
| Message callback / 单聊已读回执 | `onMessageReadReceipts` | `onMessageReadReceipts` | SIGNATURE_DIFFERENCE |
| Message callback / 群消息已读回执更新 | `groupMessageReadReceiptsHasChanged` | `onReadReceiptForGroupMessageUpdated` | SIGNATURE_DIFFERENCE |
| Message callback / 送达 | `messagesDidDeliver` | `onMessageDelivered` | SIGNATURE_DIFFERENCE |
| Message callback / 撤回 | `messagesInfoDidRecall` | `onMessageRecalledWithExt` | SIGNATURE_DIFFERENCE |
| Message callback / 消息状态变化 | `messageStatusDidChange` | `onMessageChanged` | SIGNATURE_DIFFERENCE |
| Message callback / 附件状态变化 | `messageAttachmentStatusDidChange` | — | IOS_ONLY |
| Message callback / Reaction 变化 | `messageReactionDidChange` | `onReactionChanged` | SIGNATURE_DIFFERENCE |
| Message callback / 内容修改 | `onMessageContentChanged` | `onMessageContentChanged` | SIGNATURE_DIFFERENCE |
| Message callback / Pin 变化 | `onMessagePinChanged` | `onMessagePinChanged` | SIGNATURE_DIFFERENCE |
| Conversation callback / 会话列表更新 | `conversationListDidUpdate` | `onConversationUpdate` | SIGNATURE_DIFFERENCE |
| Thread callback / 创建 | `onChatThreadCreate` | `onChatThreadCreated` | SIGNATURE_DIFFERENCE |
| Thread callback / 更新 | `onChatThreadUpdate` | `onChatThreadUpdated` | SIGNATURE_DIFFERENCE |
| Thread callback / 销毁 | `onChatThreadDestroy` | `onChatThreadDestroyed` | SIGNATURE_DIFFERENCE |
| Thread callback / 用户被移出 | `onUserKickOutOfChatThread` | `onChatThreadUserRemoved` | SIGNATURE_DIFFERENCE |
