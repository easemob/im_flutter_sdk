import { ChatClient, ChatError, SearchDirection } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { ContentType, Conversation, ConversationType } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { FlutterPluginBinding, MethodCall, MethodCallHandler, MethodResult } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import HelpTool from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/HelpTool&1.0.0";
import MethodKey from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/MethodKeys&1.0.0";
import MessageHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/MessageHelper&1.0.0";
import { GetSafetyValue, IsObj } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
import Wrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/Wrapper&1.0.0";
import type { Any } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
export default class ConversationWrapper extends Wrapper implements MethodCallHandler {
    constructor(binding: FlutterPluginBinding, channelName: string) {
        super(binding, channelName);
    }
    onMethodCall(call: MethodCall, result: MethodResult): void {
        if (MethodKey.getUnreadMsgCount === call.method) {
            this.getUnreadMsgCount(call, result);
        }
        else if (MethodKey.markAllMessagesAsRead === call.method) {
            this.markAllMessagesAsRead(call, result);
        }
        else if (MethodKey.markMessageAsRead === call.method) {
            this.markMessageAsRead(call, result);
        }
        else if (MethodKey.syncConversationExt === call.method) {
            this.syncConversationExt(call, result);
        }
        else if (MethodKey.removeMessage === call.method) {
            this.removeMessage(call, result);
        }
        else if (MethodKey.deleteMessageByIds === call.method) {
            this.deleteMessageByIds(call, result);
        }
        else if (MethodKey.getLatestMessage === call.method) {
            this.getLatestMessage(call, result);
        }
        else if (MethodKey.getLatestMessageFromOthers === call.method) {
            this.getLatestMessageFromOthers(call, result);
        }
        else if (MethodKey.clearAllMessages === call.method) {
            this.clearAllMessages(call, result);
        }
        else if (MethodKey.deleteMessagesWithTs === call.method) {
            this.deleteMessagesWithTs(call, result);
        }
        else if (MethodKey.insertMessage === call.method) {
            this.insertMessage(call, result);
        }
        else if (MethodKey.appendMessage === call.method) {
            this.appendMessage(call, result);
        }
        else if (MethodKey.updateConversationMessage === call.method) {
            this.updateConversationMessage(call, result);
        }
        else if (MethodKey.loadMsgWithId === call.method) {
            this.loadMsgWithId(call, result);
        }
        else if (MethodKey.loadMsgWithStartId === call.method) {
            this.loadMsgWithStartId(call, result);
        }
        else if (MethodKey.loadMsgWithKeywords === call.method) {
            this.loadMsgWithKeywords(call, result);
        }
        else if (MethodKey.loadMsgWithMsgType === call.method) {
            this.loadMsgWithMsgType(call, result);
        }
        else if (MethodKey.loadMsgWithTime === call.method) {
            this.loadMsgWithTime(call, result);
        }
        else if (MethodKey.messageCount === call.method) {
            this.messageCount(call, result);
        }
        else if (MethodKey.removeMsgFromServerWithMsgList === call.method) {
            this.removeMsgFromServerWithMsgList(call, result);
        }
        else if (MethodKey.removeMsgFromServerWithTimeStamp === call.method) {
            this.removeMsgFromServerWithTimeStamp(call, result);
        }
        else if (MethodKey.pinnedMessages === call.method) {
            this.pinnedMessages(call, result);
        }
        // 481
        else if (MethodKey.conversationRemindType === call.method) {
            this.remindType(call, result);
        }
        else if (MethodKey.conversationSearchMsgsByOptions === call.method) {
            this.searchMsgByOptions(call, result);
        }
        else if (MethodKey.conversationGetLocalMessageCount === call.method) {
            this.getLocalMessageCount(call, result);
        }
        else if (MethodKey.conversationDeleteServerMessageWithIds === call.method) {
            this.deleteLocalAndServerMessages(call, result);
        }
        else if (MethodKey.conversationDeleteServerMessageWithTime === call.method) {
            this.deleteLocalAndServerMessagesByTime(call, result);
        }
        else {
            super.onMethodCall(call, result);
        }
    }
    private getUnreadMsgCount(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            this.onSuccess(result, call.method, conversation.getUnreadMsgCount());
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private markAllMessagesAsRead(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            this.onSuccess(result, call.method, conversation.markAllMessagesAsRead());
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private markMessageAsRead(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let msg_id = call.argument('msg_id') as string;
            conversation.markMessageAsRead(msg_id);
            this.onSuccess(result, call.method, true);
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private syncConversationExt(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let ext: Any = GetSafetyValue(call.args, "ext");
            if (IsObj(ext)) {
                const extJson = JSON.stringify(ext);
                conversation.setExtField(extJson);
            }
            this.onSuccess(result, call.method, true);
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private removeMessage(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let msg_id = call.argument('msg_id') as string;
            this.onSuccess(result, call.method, conversation.removeMessage(msg_id));
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private deleteMessageByIds(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let messageIds = call.argument('messageIds') as string[];
            if (messageIds && messageIds.length > 0) {
                messageIds.forEach(item => {
                    conversation?.removeMessage(item);
                });
            }
            this.onSuccess(result, call.method, true);
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private getLatestMessage(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let message = conversation.getLatestMessage();
            this.onSuccess(result, call.method, message !== undefined ? MessageHelper.toJson(message) : undefined);
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private getLatestMessageFromOthers(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let message = conversation.getLatestMessageFromOthers();
            this.onSuccess(result, call.method, message !== undefined ? MessageHelper.toJson(message) : undefined);
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private clearAllMessages(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            conversation.clearAllMessages();
            this.onSuccess(result, call.method, true);
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private deleteMessagesWithTs(call: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private insertMessage(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let msgJson = call.argument('msg') as Map<string, Object>;
            let message = MessageHelper.fromJson(msgJson);
            if (message) {
                this.onSuccess(result, call.method, conversation.insertMessage(message));
            }
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private appendMessage(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let msgJson = call.argument('msg') as Map<string, Object>;
            let message = MessageHelper.fromJson(msgJson);
            if (message) {
                this.onSuccess(result, call.method, conversation.appendMessage(message));
            }
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private updateConversationMessage(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let msgJson = call.argument('msg') as Map<string, Object>;
            let message = MessageHelper.fromJson(msgJson);
            let dbMsg = ChatClient.getInstance().chatManager()?.getMessage(message.getMsgId());
            if (dbMsg) {
                HelpTool.mergeMessage(message, dbMsg);
                conversation.updateMessage(dbMsg);
                this.onSuccess(result, call.method, true);
            }
            else {
                this.onErrorInfo(result, 500, "The message is invalid.");
            }
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private loadMsgWithId(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let msg_id = call.argument('msg_id') as string;
            let message = conversation.getMessage(msg_id);
            if (message) {
                this.onSuccess(result, call.method, MessageHelper.toJson(message));
            }
            else {
                // todo 检查逻辑
                this.onSuccess(result, call.method, undefined);
            }
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private loadMsgWithStartId(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let startId = call.argument('startId') as string;
            let count = call.argument('count') as number;
            let direction = SearchDirection.UP;
            if (call.hasArgument('direction')) {
                direction = call.argument('direction') as SearchDirection;
            }
            conversation.loadMoreMessagesFromDB(startId, count, direction).then(r => {
                let messageResult: Map<string, object>[] = [];
                r.forEach(message => {
                    let map = MessageHelper.toJson(message);
                    if (map) {
                        messageResult.push(map);
                    }
                });
                this.onSuccess(result, call.method, messageResult);
            }).catch((e: ChatError) => {
                this.onError(result, e);
            });
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    // todo 不支持scope
    private loadMsgWithKeywords(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let keywords = call.argument('keywords') as string;
            let timestamp = call.argument('timestamp') as number;
            let maxCount = call.argument('count') as number;
            let from = '';
            if (call.hasArgument('from')) {
                from = call.argument('from') as string;
            }
            let direction = SearchDirection.UP;
            if (call.hasArgument('direction')) {
                direction = call.argument('direction') as SearchDirection;
            }
            conversation.searchMessagesByKeywords(keywords, timestamp, maxCount, from, direction).then(r => {
                let messageResult: Map<string, object>[] = [];
                r.forEach(message => {
                    let map = MessageHelper.toJson(message);
                    if (map) {
                        messageResult.push(map);
                    }
                });
                this.onSuccess(result, call.method, messageResult);
            }).catch((e: ChatError) => {
                this.onError(result, e);
            });
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    // todo 校验消息类型是否正确
    private loadMsgWithMsgType(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let timestamp = call.argument('timestamp') as number;
            let maxCount = call.argument('count') as number;
            let from = '';
            if (call.hasArgument('sender')) {
                from = call.argument('sender') as string;
            }
            let direction = SearchDirection.UP;
            if (call.hasArgument('direction')) {
                direction = call.argument('direction') as SearchDirection;
            }
            let msgType = call.argument('msgType') as ContentType;
            conversation.searchMessagesByType(msgType, timestamp, maxCount, from, direction).then(r => {
                let messageResult: Map<string, object>[] = [];
                r.forEach(message => {
                    let map = MessageHelper.toJson(message);
                    if (map) {
                        messageResult.push(map);
                    }
                });
                this.onSuccess(result, call.method, messageResult);
            }).catch((e: ChatError) => {
                this.onError(result, e);
            });
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private loadMsgWithTime(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let startTime = call.argument('startTime') as number;
            let endTime = call.argument('endTime') as number;
            let maxCount = call.argument('count') as number;
            conversation.searchMessagesBetweenTime(startTime, endTime, maxCount).then(r => {
                let messageResult: Map<string, object>[] = [];
                r.forEach(message => {
                    let map = MessageHelper.toJson(message);
                    if (map) {
                        messageResult.push(map);
                    }
                });
                this.onSuccess(result, call.method, messageResult);
            }).catch((e: ChatError) => {
                this.onError(result, e);
            });
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private messageCount(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            this.onSuccess(result, call.method, conversation.getAllMsgCount());
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private removeMsgFromServerWithMsgList(call: MethodCall, result: MethodResult) {
        let convId = call.argument("convId") as string;
        let type = call.argument('type') as ConversationType;
        let msgIds = call.argument('msgIds') as string[];
        ChatClient.getInstance().chatManager()?.removeMessagesFromServer(convId, type, msgIds)?.then(() => {
            this.onSuccess(result, call.method);
        }).catch((e: ChatError) => {
            this.onError(result, e);
        });
    }
    private removeMsgFromServerWithTimeStamp(call: MethodCall, result: MethodResult) {
        let convId = call.argument("convId") as string;
        let type = call.argument('type') as ConversationType;
        let timestamp = call.argument('timestamp') as number;
        ChatClient.getInstance().chatManager()?.removeMessagesFromServer(convId, type, timestamp)?.then(() => {
            this.onSuccess(result, call.method);
        }).catch((e: ChatError) => {
            this.onError(result, e);
        });
    }
    private pinnedMessages(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            conversation.getPinnedMessages().then(r => {
                let messageResult: Map<string, object>[] = [];
                r.forEach(message => {
                    let map = MessageHelper.toJson(message);
                    if (map) {
                        messageResult.push(map);
                    }
                });
                this.onSuccess(result, call.method, messageResult);
            }).catch((e: ChatError) => {
                this.onError(result, e);
            });
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private remindType(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            this.onSuccess(result, call.method, conversation.pushRemindType() as number);
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    // todo 校验消息类型是否正确
    private searchMsgByOptions(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let timestamp = call.argument('ts') as number;
            let maxCount = call.argument('count') as number;
            let from = '';
            if (call.hasArgument('from')) {
                from = call.argument('from') as string;
            }
            let direction = SearchDirection.UP;
            if (call.hasArgument('direction')) {
                direction = call.argument('direction') as SearchDirection;
            }
            let msgTypes = call.argument('types') as ContentType[];
            conversation.searchMessagesByType(msgTypes, timestamp, maxCount, from, direction).then(r => {
                let messageResult: Map<string, object>[] = [];
                r.forEach(message => {
                    let map = MessageHelper.toJson(message);
                    if (map) {
                        messageResult.push(map);
                    }
                });
                this.onSuccess(result, call.method, messageResult);
            }).catch((e: ChatError) => {
                this.onError(result, e);
            });
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private getLocalMessageCount(call: MethodCall, result: MethodResult) {
        let conversation = this.conversationWithParam(call);
        if (conversation) {
            let startMs = call.argument('startMs') as number;
            let endMs = call.argument('endMs') as number;
            this.onSuccess(result, call.method, conversation.getMsgCountInRange(startMs, endMs));
        }
        else {
            this.onError(result, ChatError.createError(ChatError.INVALID_PARAM, 'Conversation is undefined!'));
        }
    }
    private deleteLocalAndServerMessages(call: MethodCall, result: MethodResult) {
        let convId = call.argument("convId") as string;
        let type = call.argument('type') as ConversationType;
        let msgIds: string[] = call.argument('msgIds') as string[];
        ChatClient.getInstance().chatManager()?.removeMessagesFromServer(convId, type, msgIds).then(() => {
            this.onSuccess(result, call.method);
        }).catch((e: ChatError) => {
            this.onError(result, e);
        });
    }
    private deleteLocalAndServerMessagesByTime(call: MethodCall, result: MethodResult) {
        let convId = call.argument("convId") as string;
        let type = call.argument('type') as ConversationType;
        let beforeMs = call.argument('beforeMs') as number;
        ChatClient.getInstance().chatManager()?.removeMessagesFromServer(convId, type, beforeMs).then(() => {
            this.onSuccess(result, call.method);
        }).catch((e: ChatError) => {
            this.onError(result, e);
        });
    }
    private conversationWithParam(call: MethodCall): Conversation | undefined {
        let convId = call.argument("convId") as string;
        let type = call.argument('type') as ConversationType;
        return ChatClient.getInstance().chatManager()?.getConversation(convId, type, true);
    }
}
