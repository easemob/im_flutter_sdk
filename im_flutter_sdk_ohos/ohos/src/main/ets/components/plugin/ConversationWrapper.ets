import {
  ChatClient,
  ChatError,
  ChatManager,
  ChatMessage,
  ContentType,
  Conversation,
  ConversationType,
  MessageSearchScope,
  SearchDirection,
} from '@easemob/chatsdk';
import {
  FlutterPluginBinding,
  MethodCall,
  MethodResult,
} from '@ohos/flutter_ohos';
import { JSON } from '@kit.ArkTS';
import MethodKey from './MethodKeys';
import Wrapper from './Wrapper';
import SafetyMapTool from './SafetyMapTool';
import ChannelValue from './models/ChannelValue';
import EnumTool from './models/EnumTool';
import MessageHelper from './models/MessageHelper';

/**
 * Wrapper for the `com.chat.im/chat_conversation` channel.
 *
 * chatsdk has no standalone ConversationManager (gap-ledger structural
 * difference 2): every key maps to a chatsdk `Conversation` instance method,
 * except the two server-side deletion keys which go through
 * `ChatManager.removeMessagesFromServer` (overloads by message ids / by
 * timestamp), mirroring the android wrapper.
 *
 * Keys intentionally absent (gap-ledger §17 Dart removal / §16.1 backlog):
 *  - deleteMessageByIds / deleteMessagesWithTs: removed from the ohos-branch
 *    Dart constants, no branch here.
 *  - removeMsgFromServerWithTimeStamp: orphan constant kept in backlog, not
 *    wired.
 *
 * Adaptation notes:
 *  - The "isThread" request field is ignored: chatsdk has no chat-thread
 *    concept on HarmonyOS.
 *  - syncConversationExt: the Flutter ext is a Map<String,String> while
 *    chatsdk stores a plain string, so the map is JSON-serialized before
 *    setExtField (mirrors android JSONObject.toString()).
 *  - conversationDeleteServerMessageWithTime: the Flutter caller now sends the
 *    conversation fields (convId/type) together with "beforeTs"; a missing
 *    convId is reported as an invalid-param error instead of falling through
 *    to notImplemented.
 *  - loadMsgWithStartId: chatsdk returns the page in ascending order whatever
 *    the requested direction, so the page is re-sorted to the documented
 *    Up = newest-first / Down = oldest-first order.
 */
export default class ConversationWrapper extends Wrapper {
  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  override onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.getUnreadMsgCount === call.method) {
      this.getUnreadMsgCount(call, result);
    } else if (MethodKey.markAllMessagesAsRead === call.method) {
      this.markAllMessagesAsRead(call, result);
    } else if (MethodKey.markMessageAsRead === call.method) {
      this.markMessageAsRead(call, result);
    } else if (MethodKey.markMessagesAsReadWithTimestamp === call.method) {
      this.markMessagesAsReadWithTimestamp(call, result);
    } else if (MethodKey.syncConversationExt === call.method) {
      this.syncConversationExt(call, result);
    } else if (MethodKey.removeMessage === call.method) {
      this.removeMessage(call, result);
    } else if (MethodKey.getLatestMessage === call.method) {
      this.getLatestMessage(call, result);
    } else if (MethodKey.getLatestMessageFromOthers === call.method) {
      this.getLatestMessageFromOthers(call, result);
    } else if (MethodKey.clearAllMessages === call.method) {
      this.clearAllMessages(call, result);
    } else if (MethodKey.insertMessage === call.method) {
      this.insertMessage(call, result);
    } else if (MethodKey.appendMessage === call.method) {
      this.appendMessage(call, result);
    } else if (MethodKey.updateConversationMessage === call.method) {
      this.updateConversationMessage(call, result);
    } else if (MethodKey.loadMsgWithId === call.method) {
      this.loadMsgWithId(call, result);
    } else if (MethodKey.loadMsgWithStartId === call.method) {
      this.loadMsgWithStartId(call, result);
    } else if (MethodKey.loadMsgWithKeywords === call.method) {
      this.loadMsgWithKeywords(call, result);
    } else if (MethodKey.loadMsgWithMsgType === call.method) {
      this.loadMsgWithMsgType(call, result);
    } else if (MethodKey.loadMsgWithTime === call.method) {
      this.loadMsgWithTime(call, result);
    } else if (MethodKey.messageCount === call.method) {
      this.messageCount(call, result);
    } else if (MethodKey.pinnedMessages === call.method) {
      this.pinnedMessages(call, result);
    } else if (MethodKey.conversationRemindType === call.method) {
      this.remindType(call, result);
    } else if (MethodKey.conversationSearchMsgsByOptions === call.method) {
      this.searchMsgByOptions(call, result);
    } else if (MethodKey.conversationGetLocalMessageCount === call.method) {
      this.getLocalMessageCount(call, result);
    } else if (MethodKey.conversationDeleteServerMessageWithIds === call.method) {
      this.deleteLocalAndServerMessages(call, result);
    } else if (MethodKey.conversationDeleteServerMessageWithTime === call.method) {
      this.deleteLocalAndServerMessagesByTime(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private requireManager(result: MethodResult): ChatManager | undefined {
    let manager = ChatClient.getInstance().chatManager();
    if (manager === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'ChatManager unavailable: SDK not initialized');
    }
    return manager;
  }

  /**
   * Resolves the target Conversation from the standard request fields
   * (convId / type), mirroring android ConversationParams.getConversation
   * (createIfNotExist = true; isThread has no chatsdk counterpart).
   */
  private conversationFromManager(
    call: MethodCall,
    result: MethodResult,
    manager: ChatManager,
  ): Conversation | undefined {
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let type = EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'type') ?? 0);
    let conversation = manager.getConversation(convId, type, true);
    if (conversation === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `Conversation unavailable: ${convId}`);
    }
    return conversation;
  }

  private requireConversation(call: MethodCall, result: MethodResult): Conversation | undefined {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return undefined;
    }
    return this.conversationFromManager(call, result, manager);
  }

  private getUnreadMsgCount(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    this.onSuccess(result, call.method, conversation.getUnreadMsgCount());
  }

  private markAllMessagesAsRead(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    try {
      conversation.markAllMessagesAsRead();
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `markAllMessagesAsRead failed: ${JSON.stringify(e)}`);
    }
  }

  private markMessageAsRead(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    try {
      conversation.markMessageAsRead(msgId);
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `markMessageAsRead failed: ${JSON.stringify(e)}`);
    }
  }

  // 1.16.0
  private markMessagesAsReadWithTimestamp(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let timestamp = SafetyMapTool.getNumber(call.args, 'timestamp') ?? 0;
    try {
      let success = conversation.markMessagesAsReadWithTimestamp(timestamp);
      this.onSuccess(result, call.method, success);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `markMessagesAsReadWithTimestamp failed: ${JSON.stringify(e)}`);
    }
  }

  private syncConversationExt(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let jsonStr = '';
    let ext = ChannelValue.read(call.args, 'ext');
    if (ext instanceof Map) {
      let extMap = ext as Map<string, Object>;
      if (extMap.size > 0) {
        let record: Record<string, Object> = {};
        extMap.forEach((value: Object, key: string) => {
          record[key] = value;
        });
        jsonStr = JSON.stringify(record);
      }
    } else if (ChannelValue.isPlainObject(ext)) {
      let record = ext as Record<string, Object>;
      if (Object.keys(record).length > 0) {
        jsonStr = JSON.stringify(record);
      }
    }
    try {
      conversation.setExtField(jsonStr);
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `syncConversationExt failed: ${JSON.stringify(e)}`);
    }
  }

  private removeMessage(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    try {
      conversation.removeMessage(msgId);
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `removeMessage failed: ${JSON.stringify(e)}`);
    }
  }

  private getLatestMessage(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let msg = conversation.getLatestMessage();
    this.onSuccess(result, call.method, msg !== undefined ? MessageHelper.toJson(msg) : null);
  }

  private getLatestMessageFromOthers(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let msg = conversation.getLatestMessageFromOthers();
    this.onSuccess(result, call.method, msg !== undefined ? MessageHelper.toJson(msg) : null);
  }

  private clearAllMessages(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    try {
      conversation.clearAllMessages();
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `clearAllMessages failed: ${JSON.stringify(e)}`);
    }
  }

  private insertMessage(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let msg = MessageHelper.fromJson(ChannelValue.read(call.args, 'msg'));
    if (msg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return;
    }
    try {
      conversation.insertMessage(msg);
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `insertMessage failed: ${JSON.stringify(e)}`);
    }
  }

  private appendMessage(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let msg = MessageHelper.fromJson(ChannelValue.read(call.args, 'msg'));
    if (msg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return;
    }
    try {
      conversation.appendMessage(msg);
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `appendMessage failed: ${JSON.stringify(e)}`);
    }
  }

  private updateConversationMessage(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let conversation = this.conversationFromManager(call, result, manager);
    if (conversation === undefined) {
      return;
    }
    let tempMsg = MessageHelper.fromJson(ChannelValue.read(call.args, 'msg'));
    if (tempMsg === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'The message is invalid.');
      return;
    }
    let dbMsg = manager.getMessage(tempMsg.getMsgId());
    if (dbMsg === undefined) {
      this.onErrorInfo(result, 500, 'The message is invalid.');
      return;
    }
    // Mirrors android HelpTool.mergeMessage (same field set as
    // ChatManagerWrapper.updateChatMessage).
    dbMsg.setServerTimestamp(tempMsg.getServerTimestamp());
    dbMsg.setLocalTimestamp(tempMsg.getLocalTimestamp());
    dbMsg.setStatus(tempMsg.getStatus());
    dbMsg.setReceiverRead(tempMsg.isReceiverRead());
    dbMsg.setIsNeedGroupAck(tempMsg.isNeedGroupAck());
    dbMsg.setUnread(tempMsg.isUnread());
    dbMsg.deliverOnlineOnly(tempMsg.isDeliverOnlineOnly());
    dbMsg.setReceiverList(tempMsg.receiverList());
    let attributes = tempMsg.ext();
    if (attributes.size > 0) {
      dbMsg.setExt(attributes);
    }
    let body = tempMsg.getBody();
    if (body !== undefined) {
      dbMsg.setBody(body);
    }
    try {
      conversation.updateMessage(dbMsg);
      this.onSuccess(result, call.method, true);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `updateConversationMessage failed: ${JSON.stringify(e)}`);
    }
  }

  private loadMsgWithId(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let msgId = SafetyMapTool.getString(call.args, 'msgId') ?? '';
    let msg = conversation.getMessage(msgId);
    this.onSuccess(result, call.method, msg !== undefined ? MessageHelper.toJson(msg) : null);
  }

  private loadMsgWithStartId(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let startId = SafetyMapTool.getString(call.args, 'startId') ?? '';
    let count = SafetyMapTool.getNumber(call.args, 'count') ?? 20;
    let direction = EnumTool.searchDirectionFromInt(SafetyMapTool.getNumber(call.args, 'direction') ?? 0);
    this.handlePromise(result, call.method,
      conversation.loadMoreMessagesFromDB(startId, count, direction),
      (msgs) => MessageHelper.listToJson(ConversationWrapper.sortByDirection(msgs, direction)));
  }

  /**
   * chatsdk answers `loadMoreMessagesFromDB` in ascending server-timestamp
   * order regardless of `direction`, while the Flutter API documents
   * `ChatSearchDirection.Up` as newest-first and `Down` as oldest-first
   * (chat_conversation.dart loadMessages). Normalize the order here so the
   * ohos branch matches android/ios instead of exposing the platform order.
   */
  private static sortByDirection(msgs: Array<ChatMessage>, direction: SearchDirection): Array<ChatMessage> {
    let sorted = msgs.slice();
    sorted.sort((left: ChatMessage, right: ChatMessage): number => {
      let delta = ConversationWrapper.timestampOf(left) - ConversationWrapper.timestampOf(right);
      return direction === SearchDirection.UP ? -delta : delta;
    });
    return sorted;
  }

  /** Server timestamp is authoritative; local time covers local-only rows. */
  private static timestampOf(msg: ChatMessage): number {
    let serverTime = msg.getServerTimestamp();
    return serverTime > 0 ? serverTime : msg.getLocalTimestamp();
  }

  private loadMsgWithKeywords(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let keywords = SafetyMapTool.getString(call.args, 'keywords') ?? '';
    let timestamp = SafetyMapTool.getNumber(call.args, 'timestamp') ?? -1;
    let count = SafetyMapTool.getNumber(call.args, 'count') ?? 20;
    // chatsdk accepts a single sender id or an id array, covering both the
    // Flutter "senders" array and the legacy "from" string (gap-ledger 4.1).
    let from: string | Array<string> = '';
    let senders = SafetyMapTool.getStringArray(call.args, 'senders');
    if (senders !== undefined) {
      from = senders;
    } else {
      from = SafetyMapTool.getString(call.args, 'from') ?? '';
    }
    let direction = EnumTool.searchDirectionFromInt(SafetyMapTool.getNumber(call.args, 'direction') ?? 0);
    // Raw cast mirrors ChatManagerWrapper.loadConversationMessagesWithKeyword;
    // Dart MessageSearchScope indexes match chatsdk MessageSearchScope values.
    let scope = (SafetyMapTool.getNumber(call.args, 'searchScope') ?? 2) as MessageSearchScope;
    this.handlePromise(result, call.method,
      conversation.searchMessagesByKeywords(keywords, timestamp, count, from, direction, scope),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private loadMsgWithMsgType(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let type = EnumTool.messageBodyTypeFromInt(SafetyMapTool.getNumber(call.args, 'msgType') ?? 0);
    let timestamp = SafetyMapTool.getNumber(call.args, 'timestamp') ?? -1;
    let count = SafetyMapTool.getNumber(call.args, 'count') ?? 20;
    let sender = SafetyMapTool.getString(call.args, 'sender') ?? '';
    let direction = EnumTool.searchDirectionFromInt(SafetyMapTool.getNumber(call.args, 'direction') ?? 0);
    this.handlePromise(result, call.method,
      conversation.searchMessagesByType(type, timestamp, count, sender, direction),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private loadMsgWithTime(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let startTime = SafetyMapTool.getNumber(call.args, 'startTime') ?? 0;
    let endTime = SafetyMapTool.getNumber(call.args, 'endTime') ?? 0;
    let count = SafetyMapTool.getNumber(call.args, 'count') ?? 20;
    this.handlePromise(result, call.method,
      conversation.searchMessagesBetweenTime(startTime, endTime, count),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private messageCount(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    this.onSuccess(result, call.method, conversation.getAllMsgCount());
  }

  private pinnedMessages(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    this.handlePromise(result, call.method, conversation.getPinnedMessages(),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private remindType(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    try {
      this.onSuccess(result, call.method, EnumTool.remindTypeToInt(conversation.pushRemindType()));
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `conversationRemindType failed: ${JSON.stringify(e)}`);
    }
  }

  private searchMsgByOptions(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let types = new Array<ContentType>();
    let typeValues = ChannelValue.numberArray(call.args, 'types');
    if (typeValues !== undefined) {
      for (let value of typeValues) {
        types.push(EnumTool.messageBodyTypeFromInt(value));
      }
    }
    let ts = SafetyMapTool.getNumber(call.args, 'ts') ?? -1;
    let count = SafetyMapTool.getNumber(call.args, 'count') ?? 20;
    let from = SafetyMapTool.getString(call.args, 'from') ?? '';
    let direction: SearchDirection | undefined = undefined;
    if (SafetyMapTool.has(call.args, 'direction')) {
      direction = EnumTool.searchDirectionFromInt(SafetyMapTool.getNumber(call.args, 'direction') ?? 0);
    }
    this.handlePromise(result, call.method,
      conversation.searchMessagesByType(types, ts, count, from, direction),
      (msgs) => MessageHelper.listToJson(msgs));
  }

  private getLocalMessageCount(call: MethodCall, result: MethodResult): void {
    let conversation = this.requireConversation(call, result);
    if (conversation === undefined) {
      return;
    }
    let startMs = SafetyMapTool.getNumber(call.args, 'startTs') ?? 0;
    let endMs = SafetyMapTool.getNumber(call.args, 'endTs') ?? 0;
    this.onSuccess(result, call.method, conversation.getMsgCountInRange(startMs, endMs));
  }

  private deleteLocalAndServerMessages(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let type: ConversationType =
      EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'type') ?? 0);
    let msgIds = SafetyMapTool.getStringArray(call.args, 'msgIds') ?? [];
    this.handlePromise(result, call.method, manager.removeMessagesFromServer(convId, type, msgIds));
  }

  private deleteLocalAndServerMessagesByTime(call: MethodCall, result: MethodResult): void {
    let manager = this.requireManager(result);
    if (manager === undefined) {
      return;
    }
    if (!SafetyMapTool.has(call.args, 'convId')) {
      // The Flutter caller sends the conversation fields (see class doc);
      // a request without them cannot address the conversation.
      this.onErrorInfo(result, ChatError.INVALID_PARAM,
        'conversationDeleteServerMessageWithTime requires convId and type');
      return;
    }
    let convId = SafetyMapTool.getString(call.args, 'convId') ?? '';
    let type: ConversationType =
      EnumTool.conversationTypeFromInt(SafetyMapTool.getNumber(call.args, 'type') ?? 0);
    let beforeMs = SafetyMapTool.getNumber(call.args, 'beforeTs') ?? 0;
    this.handlePromise(result, call.method, manager.removeMessagesFromServer(convId, type, beforeMs));
  }
}
