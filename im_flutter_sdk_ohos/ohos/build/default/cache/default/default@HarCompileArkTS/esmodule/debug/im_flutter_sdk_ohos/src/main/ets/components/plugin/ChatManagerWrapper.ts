import { ChatClient, ConversationType, DownloadStatus, MessageStatus, ContentType, FetchReactionDetailParams, } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { ChatMessage, ChatMessageListener, ConversationListener, FileMessageBody, VoiceMessageBody, ImageMessageBody, VideoMessageBody, ChatError, FetchMessageOption, SearchDirection, RecallMessageInfo, GroupReadAck, ChatMessageReactionChange, ChatMessagePinInfo, PinOperation, MarkType } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { JSONMethodCodec, MethodChannel } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import type { FlutterPluginBinding, MethodCall, MethodCallHandler, MethodResult } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import ConversationFilterHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/ConversationFilterHelper&1.0.0";
import EnumTool from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/EnumTool&1.0.0";
import FetchMessageOptionHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/FetchMessageOptionHelper&1.0.0";
import HelpTool from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/HelpTool&1.0.0";
import MethodKey from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/MethodKeys&1.0.0";
import ChatErrorHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ChatErrorHelper&1.0.0";
import ChatMessagePinInfoHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ChatMessagePinInfoHelper&1.0.0";
import ChatMessageReactionChangeHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ChatMessageReactionChangeHelper&1.0.0";
import ChatMessageReactionHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ChatMessageReactionHelper&1.0.0";
import ConversationHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ConversationHelper&1.0.0";
import CursorResultHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/CursorResultHelper&1.0.0";
import GroupReadAckHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/GroupReadAckHelper&1.0.0";
import MessageBodyHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/MessageBodyHelper&1.0.0";
import MessageHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/MessageHelper&1.0.0";
import RecallMessageInfoHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/RecallMessageInfoHelper&1.0.0";
import { GetSafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
import Wrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/Wrapper&1.0.0";
export default class ChatManagerWrapper extends Wrapper implements MethodCallHandler {
    private messageChannel: MethodChannel;
    private listener: ChatMessageListener | undefined;
    private conversationListener: ConversationListener | undefined;
    constructor(binding: FlutterPluginBinding, channelName: string) {
        super(binding, channelName);
        this.messageChannel = new MethodChannel(binding.getBinaryMessenger(), "com.chat.im/chat_message", JSONMethodCodec.INSTANCE);
    }
    public registerEaseListener(): void {
        let weakRef = new WeakRef(this);
        this.unRegisterEaseListener();
        this.listener = {
            onMessageReceived(messages: ChatMessage[]) {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onMessagesReceived, MessageHelper.listToJson(messages));
            },
            onCmdMessageReceived(messages: ChatMessage[]) {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onCmdMessagesReceived, MessageHelper.listToJson(messages));
            },
            onMessageRead(messages: ChatMessage[]) {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onMessagesRead, MessageHelper.listToJson(messages));
            },
            onMessageRecalled(recallInfos: RecallMessageInfo[]) {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onMessagesRecalledInfo, RecallMessageInfoHelper.listToJson(recallInfos));
            },
            onMessageDelivered(messages: ChatMessage[]) {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onMessagesDelivered, MessageHelper.listToJson(messages));
            },
            onGroupMessageRead(groupReadAcks: GroupReadAck[]) {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onGroupMessageRead, GroupReadAckHelper.listToJson(groupReadAcks));
            },
            onReadAckForGroupMessageUpdated() {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onReadAckForGroupMessageUpdated, null);
            },
            onReactionChanged(messageReactionChanges: ChatMessageReactionChange[]) {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onMessageReactionDidChange, ChatMessageReactionChangeHelper.listToJson(messageReactionChanges));
            },
            onMessageContentChanged(modifiedMessage: ChatMessage, operatorId: string, operationTime: number) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("message", MessageHelper.toJson(modifiedMessage)!);
                data.set("operator", operatorId);
                data.set("operationTime", operationTime);
                retrievedObject?.channel?.invokeMethod(MethodKey.onMessageContentChanged, data);
            },
            onMessagePinChanged(messageId: string, conversationId: string, pinOperation: PinOperation, pinInfo: ChatMessagePinInfo) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("messageId", messageId);
                data.set("conversationId", conversationId);
                data.set("pinOperation", pinOperation);
                data.set("pinInfo", ChatMessagePinInfoHelper.toJson(pinInfo));
                retrievedObject?.channel?.invokeMethod(MethodKey.onMessagePinChanged, data);
            },
        };
        this.conversationListener = {
            onConversationUpdate() {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onConversationUpdate, null);
            },
            onConversationRead(from: string, to: string) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("from", from);
                data.set("to", to);
                retrievedObject?.channel?.invokeMethod(MethodKey.onConversationHasRead, data);
            },
        };
        ChatClient.getInstance().chatManager()?.addMessageListener(this.listener);
        ChatClient.getInstance().chatManager()?.addConversationListener(this.conversationListener);
    }
    public unRegisterEaseListener(): void {
        if (this.listener != null) {
            ChatClient.getInstance().chatManager()?.removeMessageListener(this.listener);
        }
        if (this.conversationListener != null) {
            ChatClient.getInstance().chatManager()?.removeConversationListener(this.conversationListener);
        }
    }
    updateDownloadStatus(downloadStatus: DownloadStatus, msg: ChatMessage, isThumbnail: boolean): Map<string, Object> {
        let canUpdate = false;
        switch (msg.getType()) {
            case ContentType.FILE:
            case ContentType.VOICE:
                if (isThumbnail)
                    break;
            case ContentType.IMAGE:
            case ContentType.VIDEO:
                canUpdate = true;
                break;
            default:
                break;
        }
        if (canUpdate) {
            let body = msg.getBody();
            if (msg.getType() == ContentType.FILE) {
                let tmpBody = body as FileMessageBody;
                tmpBody.setDownloadStatus(downloadStatus);
            }
            else if (msg.getType() == ContentType.VOICE) {
                let tmpBody = body as VoiceMessageBody;
                tmpBody.setDownloadStatus(downloadStatus);
            }
            else if (msg.getType() == ContentType.IMAGE) {
                let tmpBody = body as ImageMessageBody;
                if (isThumbnail) {
                    tmpBody.setThumbnailDownloadStatus(downloadStatus);
                }
                else {
                    tmpBody.setDownloadStatus(downloadStatus);
                }
            }
            else if (msg.getType() == ContentType.VIDEO) {
                let tmpBody = body as VideoMessageBody;
                if (isThumbnail) {
                    tmpBody.setThumbnailDownloadStatus(downloadStatus);
                }
                else {
                    tmpBody.setDownloadStatus(downloadStatus);
                }
            }
        }
        return MessageHelper.toJson(msg)!;
    }
    onMethodCall(call: MethodCall, result: MethodResult): void {
        if (MethodKey.sendMessage == call.method) {
            this.sendMessage(call, result);
        }
        else if (MethodKey.resendMessage == call.method) {
            this.resendMessage(call, result);
        }
        else if (MethodKey.ackMessageRead == call.method) {
            this.ackMessageRead(call, result);
        }
        else if (MethodKey.ackGroupMessageRead == call.method) {
            this.ackGroupMessageRead(call, result);
        }
        else if (MethodKey.ackConversationRead == call.method) {
            this.ackConversationRead(call, result);
        }
        else if (MethodKey.recallMessage == call.method) {
            this.recallMessage(call, result);
        }
        else if (MethodKey.getConversation == call.method) {
            this.getConversation(call, result);
        }
        else if (MethodKey.getThreadConversation == call.method) {
            this.getThreadConversation(call, result);
        }
        else if (MethodKey.markAllChatMsgAsRead == call.method) {
            this.markAllChatMsgAsRead(call, result);
        }
        else if (MethodKey.getUnreadMessageCount == call.method) {
            this.getUnreadMessageCount(call, result);
        }
        else if (MethodKey.updateChatMessage == call.method) {
            this.updateChatMessage(call, result);
        }
        else if (MethodKey.downloadAttachment == call.method) {
            this.downloadAttachment(call, result);
        }
        else if (MethodKey.downloadThumbnail == call.method) {
            this.downloadThumbnail(call, result);
        }
        else if (MethodKey.downloadMessageAttachmentInCombine == call.method) {
            this.downloadMessageAttachmentInCombine(call, result);
        }
        else if (MethodKey.downloadMessageThumbnailInCombine == call.method) {
            this.downloadMessageThumbnailInCombine(call, result);
        }
        else if (MethodKey.importMessages == call.method) {
            this.importMessages(call, result);
        }
        else if (MethodKey.loadAllConversations == call.method) {
            this.loadAllConversations(call, result);
        }
        else if (MethodKey.getConversationsFromServer == call.method) {
            this.getConversationsFromServer(call, result);
        }
        else if (MethodKey.deleteConversation == call.method) {
            this.deleteConversation(call, result);
        }
        else if (MethodKey.fetchHistoryMessages == call.method) {
            this.fetchHistoryMessages(call, result);
        }
        else if (MethodKey.fetchHistoryMessagesByOptions == call.method) {
            this.fetchHistoryMessagesByOptions(call, result);
        }
        else if (MethodKey.searchChatMsgFromDB == call.method) {
            this.searchChatMsgFromDB(call, result);
        }
        else if (MethodKey.getMessage == call.method) {
            this.getMessage(call, result);
        }
        else if (MethodKey.asyncFetchGroupAcks == call.method) {
            this.asyncFetchGroupMessageAckFromServer(call, result);
        }
        else if (MethodKey.deleteRemoteConversation == call.method) {
            this.deleteRemoteConversation(call, result);
        }
        else if (MethodKey.deleteMessagesBeforeTimestamp == call.method) {
            this.deleteMessagesBefore(call, result);
        }
        else if (MethodKey.translateMessage == call.method) {
            this.translateMessage(call, result);
        }
        else if (MethodKey.fetchSupportedLanguages == call.method) {
            this.fetchSupportedLanguages(call, result);
        }
        else if (MethodKey.addReaction == call.method) {
            this.addReaction(call, result);
        }
        else if (MethodKey.removeReaction == call.method) {
            this.removeReaction(call, result);
        }
        else if (MethodKey.fetchReactionList == call.method) {
            this.fetchReactionList(call, result);
        }
        else if (MethodKey.fetchReactionDetail == call.method) {
            this.fetchReactionDetail(call, result);
        }
        else if (MethodKey.reportMessage == call.method) {
            this.reportMessage(call, result);
        }
        else if (MethodKey.fetchConversationsFromServerWithPage == call.method) {
            this.getConversationsFromServerWithPage(call, result);
        }
        else if (MethodKey.removeMessagesFromServerWithMsgIds == call.method) {
            this.removeMessagesFromServerWithMsgIds(call, result);
        }
        else if (MethodKey.removeMessagesFromServerWithTs == call.method) {
            this.removeMessagesFromServerWithTs(call, result);
        }
        else if (MethodKey.getConversationsFromServerWithCursor == call.method) {
            this.getConversationsFromServerWithCursor(call, result);
        }
        else if (MethodKey.getPinnedConversationsFromServerWithCursor == call.method) {
            this.getPinnedConversationsFromServerWithCursor(call, result);
        }
        else if (MethodKey.pinConversation == call.method) {
            this.pinConversation(call, result);
        }
        else if (MethodKey.modifyMessage == call.method) {
            this.modifyMessage(call, result);
        }
        else if (MethodKey.downloadAndParseCombineMessage == call.method) {
            this.downloadAndParseCombineMessage(call, result);
        }
        else if (MethodKey.addRemoteAndLocalConversationsMark == call.method) {
            this.addRemoteAndLocalConversationsMark(call, result);
        }
        else if (MethodKey.deleteRemoteAndLocalConversationsMark == call.method) {
            this.deleteRemoteAndLocalConversationsMark(call, result);
        }
        else if (MethodKey.fetchConversationsByOptions == call.method) {
            this.fetchConversationsByOptions(call, result);
        }
        else if (MethodKey.deleteAllMessageAndConversation == call.method) {
            this.deleteAllMessageAndConversation(call, result);
        }
        else if (MethodKey.pinMessage == call.method) {
            this.pinMessage(call, result);
        }
        else if (MethodKey.unpinMessage == call.method) {
            this.unpinMessage(call, result);
        }
        else if (MethodKey.fetchPinnedMessages == call.method) {
            this.fetchPinnedMessages(call, result);
        }
        else if (MethodKey.searchMsgsByOptions == call.method) {
            this.searchMsgByOptions(call, result);
        }
        else if (MethodKey.getMessageCount == call.method) {
            this.getMessageCount(call, result);
        }
        else {
            super.onMethodCall(call, result);
        }
    }
    private sendMessage(call: MethodCall, result: MethodResult) {
        let msg = MessageHelper.fromJson(call.args);
        let localMsgID = msg.getMsgId();
        let weakRef = new WeakRef(this);
        msg.setMessageStatusCallback({
            onSuccess() {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", localMsgID);
                data.set("message", MessageHelper.toJson(msg));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            },
            onProgress(progress) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", localMsgID);
                data.set("progress", progress);
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, data);
            },
            onError(code, desc) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", localMsgID);
                data.set("message", MessageHelper.toJson(msg));
                data.set("error", ChatErrorHelper.infoToJson(code, desc));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            }
        });
        ChatClient.getInstance().chatManager()?.sendMessage(msg);
        this.onSuccess(result, call.method, MessageHelper.toJson(msg));
    }
    private resendMessage(call: MethodCall, result: MethodResult) {
        let tempMsg = MessageHelper.fromJson(call.args);
        let weakRef = new WeakRef(this);
        let msg = ChatClient.getInstance().chatManager()?.getMessage(tempMsg.getMsgId());
        if (msg == null) {
            msg = tempMsg;
        }
        let localMsgID = msg.getMsgId();
        msg.setStatus(MessageStatus.CREATE);
        msg.setMessageStatusCallback({
            onSuccess() {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", localMsgID);
                data.set("message", MessageHelper.toJson(msg));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            },
            onProgress(progress) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", localMsgID);
                data.set("progress", progress);
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, data);
            },
            onError(code, desc) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", localMsgID);
                data.set("message", MessageHelper.toJson(msg));
                data.set("error", ChatErrorHelper.infoToJson(code, desc));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            }
        });
        ChatClient.getInstance().chatManager()?.sendMessage(msg);
        this.onSuccess(result, call.method, MessageHelper.toJson(msg));
    }
    private ackMessageRead(call: MethodCall, result: MethodResult) {
        let msgId = call.argument("msg_id") as string;
        let to = call.argument("to") as string;
        ChatClient.getInstance().chatManager()?.ackMessageRead(to, msgId);
        this.onSuccess(result, call.method);
    }
    private ackGroupMessageRead(call: MethodCall, result: MethodResult) {
        let msgId = call.argument("msg_id") as string;
        let msg = ChatClient.getInstance().chatManager()?.getMessage(msgId);
        let content = GetSafetyValue(call.args, "content", null);
        ChatClient.getInstance().chatManager()?.ackGroupMessageRead(msg, content);
        this.onSuccess(result, call.method);
    }
    private ackConversationRead(call: MethodCall, result: MethodResult) {
        let convId = call.argument("convId") as string;
        ChatClient.getInstance().chatManager()?.ackConversationRead(convId);
        this.onSuccess(result, call.method);
    }
    private recallMessage(call: MethodCall, result: MethodResult) {
        let msgId = call.argument("msg_id") as string;
        let msg = ChatClient.getInstance().chatManager()?.getMessage(msgId);
        if (!msg) {
            this.onErrorInfo(result, 500, "The message was not found");
            return;
        }
        else {
            ChatClient.getInstance().chatManager()?.recallMessage(msg, GetSafetyValue(call.args, "ext"));
            this.onSuccess(result, call.method);
        }
    }
    private getConversation(call: MethodCall, result: MethodResult) {
        let convId = call.argument("convId") as string;
        let createIfNeed = GetSafetyValue(call.args, "createIfNeed", true);
        let type = GetSafetyValue(call.args, "type", ConversationType.Chat);
        let conv = ChatClient.getInstance().chatManager()?.getConversation(convId, type, createIfNeed);
        this.onSuccess(result, call.method, ConversationHelper.toJson(conv));
    }
    private getThreadConversation(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private markAllChatMsgAsRead(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.markAllConversationsAsRead();
        this.onSuccess(result, call.method);
    }
    private getUnreadMessageCount(call: MethodCall, result: MethodResult) {
        let conversations = ChatClient.getInstance().chatManager()?.getAllConversationsBySort();
        let count: number = 0;
        if (conversations != undefined) {
            for (let index = 0; index < conversations.length; index++) {
                const element = conversations[index];
                count += element.getUnreadMsgCount();
            }
        }
        this.onSuccess(result, call.method, count);
    }
    private updateChatMessage(call: MethodCall, result: MethodResult) {
        let msg = MessageHelper.fromJson(call.argument("message"));
        let dbMsg = ChatClient.getInstance().chatManager()?.getMessage(msg.getMsgId());
        if (!dbMsg) {
            this.onErrorInfo(result, 500, "The message is invalid.");
            return;
        }
        HelpTool.mergeMessage(msg, dbMsg);
        ChatClient.getInstance().chatManager()?.updateMessage(dbMsg);
        this.onSuccess(result, call.method, true);
    }
    private downloadAttachment(call: MethodCall, result: MethodResult) {
        let tempMsg = MessageHelper.fromJson(call.argument("message"));
        let dbMsg = ChatClient.getInstance().chatManager()?.getMessage(tempMsg.getMsgId());
        let weakRef = new WeakRef(this);
        dbMsg?.setMessageStatusCallback({
            onSuccess() {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", dbMsg?.getMsgId());
                data.set("message", retrievedObject?.updateDownloadStatus(DownloadStatus.SUCCESS, dbMsg, false));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            },
            onProgress(progress) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", dbMsg?.getMsgId());
                data.set("progress", progress);
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, data);
            },
            onError(code, desc) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", dbMsg?.getMsgId());
                data.set("message", retrievedObject?.updateDownloadStatus(DownloadStatus.FAILED, dbMsg, false));
                data.set("error", ChatErrorHelper.infoToJson(code, desc));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            }
        });
        ChatClient.getInstance().chatManager()?.downloadAttachment(dbMsg);
        this.onSuccess(result, call.method, this.updateDownloadStatus(DownloadStatus.DOWNLOADING, dbMsg!, false));
    }
    private downloadThumbnail(call: MethodCall, result: MethodResult) {
        let tempMsg = MessageHelper.fromJson(call.argument("message"));
        let dbMsg = ChatClient.getInstance().chatManager()?.getMessage(tempMsg.getMsgId());
        let weakRef = new WeakRef(this);
        dbMsg?.setMessageStatusCallback({
            onSuccess() {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", dbMsg?.getMsgId());
                data.set("message", retrievedObject?.updateDownloadStatus(DownloadStatus.SUCCESS, dbMsg, true));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            },
            onProgress(progress) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", dbMsg?.getMsgId());
                data.set("progress", progress);
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, data);
            },
            onError(code, desc) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", dbMsg?.getMsgId());
                data.set("message", retrievedObject?.updateDownloadStatus(DownloadStatus.FAILED, dbMsg, true));
                data.set("error", ChatErrorHelper.infoToJson(code, desc));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            }
        });
        ChatClient.getInstance().chatManager()?.downloadThumbnail(dbMsg);
        this.onSuccess(result, call.method, this.updateDownloadStatus(DownloadStatus.DOWNLOADING, dbMsg!, true));
    }
    private downloadMessageAttachmentInCombine(call: MethodCall, result: MethodResult) {
        let tempMsg = MessageHelper.fromJson(call.argument("message"));
        let weakRef = new WeakRef(this);
        tempMsg?.setMessageStatusCallback({
            onSuccess() {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", tempMsg?.getMsgId());
                data.set("message", retrievedObject?.updateDownloadStatus(DownloadStatus.SUCCESS, tempMsg, true));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            },
            onProgress(progress) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", tempMsg?.getMsgId());
                data.set("progress", progress);
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, data);
            },
            onError(code, desc) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", tempMsg?.getMsgId());
                data.set("message", retrievedObject?.updateDownloadStatus(DownloadStatus.FAILED, tempMsg, true));
                data.set("error", ChatErrorHelper.infoToJson(code, desc));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            }
        });
        ChatClient.getInstance().chatManager()?.downloadAttachment(tempMsg);
        this.onSuccess(result, call.method, this.updateDownloadStatus(DownloadStatus.DOWNLOADING, tempMsg!, false));
    }
    private downloadMessageThumbnailInCombine(call: MethodCall, result: MethodResult) {
        let tempMsg = MessageHelper.fromJson(call.argument("message"));
        let weakRef = new WeakRef(this);
        tempMsg?.setMessageStatusCallback({
            onSuccess() {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", tempMsg?.getMsgId());
                data.set("message", retrievedObject?.updateDownloadStatus(DownloadStatus.SUCCESS, tempMsg, true));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            },
            onProgress(progress) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", tempMsg?.getMsgId());
                data.set("progress", progress);
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, data);
            },
            onError(code, desc) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("localId", tempMsg?.getMsgId());
                data.set("message", retrievedObject?.updateDownloadStatus(DownloadStatus.FAILED, tempMsg, true));
                data.set("error", ChatErrorHelper.infoToJson(code, desc));
                retrievedObject?.messageChannel.invokeMethod(MethodKey.onMessageSuccess, data);
            }
        });
        ChatClient.getInstance().chatManager()?.downloadThumbnail(tempMsg);
        this.onSuccess(result, call.method, this.updateDownloadStatus(DownloadStatus.DOWNLOADING, tempMsg!, true));
    }
    private importMessages(call: MethodCall, result: MethodResult) {
        let ary = call.argument("messages") as Array<Map<string, Object>>;
        let msgs = new Array<ChatMessage>();
        for (let index = 0; index < ary.length; index++) {
            const element = ary[index];
            msgs.push(MessageHelper.fromJson(element));
        }
        ChatClient.getInstance().chatManager()?.importMessages(msgs)
            .then((value) => this.onSuccess(result, call.method, value))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private loadAllConversations(call: MethodCall, result: MethodResult) {
        let conversations = ChatClient.getInstance().chatManager()?.getAllConversationsBySort();
        this.onSuccess(result, call.method, ConversationHelper.listToJson(conversations));
    }
    private getConversationsFromServer(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private deleteConversation(call: MethodCall, result: MethodResult) {
        let convId = call.argument("convId") as string;
        let deleteMessages = call.argument("deleteMessages") as boolean;
        let succeed = ChatClient.getInstance().chatManager()?.deleteConversation(convId, deleteMessages);
        this.onSuccess(result, call.method, succeed);
    }
    private fetchHistoryMessages(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private fetchHistoryMessagesByOptions(call: MethodCall, result: MethodResult) {
        let convId = call.argument("convId") as string;
        let type = EnumTool.conversationTypeFromInt(call.argument("type") as number);
        let pageSize = call.argument("pageSize") as number;
        let cursor = GetSafetyValue(call.args, "cursor", null);
        let options: FetchMessageOption | undefined = FetchMessageOptionHelper.fromJson(GetSafetyValue(call.args, "options"));
        ChatClient.getInstance().chatManager()?.fetchHistoryMessages(convId, type, pageSize, cursor, options)
            .then((value) => this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private searchChatMsgFromDB(call: MethodCall, result: MethodResult) {
        let keywords: string | undefined = GetSafetyValue(call.args, "keywords");
        let timestamp: number | undefined = GetSafetyValue(call.args, "timestamp");
        let count: number | undefined = GetSafetyValue(call.args, "count");
        let from: string | undefined = GetSafetyValue(call.args, "from");
        let direct: SearchDirection | undefined = GetSafetyValue(call.args, "direction");
        ChatClient.getInstance().chatManager()?.searchMessagesFromDB(keywords, timestamp, count, from, direct)
            .then((value) => this.onSuccess(result, call.method, MessageHelper.listToJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private getMessage(call: MethodCall, result: MethodResult) {
        let msgId: string | undefined = GetSafetyValue(call.args, "msg_id");
        let msg = ChatClient.getInstance().chatManager()?.getMessage(msgId);
        this.onSuccess(result, call.method, MessageHelper.toJson(msg));
    }
    private asyncFetchGroupMessageAckFromServer(call: MethodCall, result: MethodResult) {
        let msgId: string | undefined = GetSafetyValue(call.args, "msg_id");
        let ack_id: string | undefined = GetSafetyValue(call.args, "ack_id");
        let pageSize: number | undefined = GetSafetyValue(call.args, "pageSize");
        ChatClient.getInstance().chatManager()?.fetchGroupReadAcks(msgId, pageSize, ack_id)
            .then((value) => this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private deleteRemoteConversation(call: MethodCall, result: MethodResult) {
        let conversationId: string | undefined = GetSafetyValue(call.args, "conversationId");
        let type = EnumTool.conversationTypeFromInt(call.argument("conversationType") as number);
        let deleteMessages = call.argument("isDeleteRemoteMessage") as boolean;
        ChatClient.getInstance().chatManager()?.deleteConversationFromServer(conversationId, type, deleteMessages)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private deleteMessagesBefore(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private translateMessage(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private fetchSupportedLanguages(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private addReaction(call: MethodCall, result: MethodResult) {
        let reaction: string | undefined = GetSafetyValue(call.args, "reaction");
        let msgId: string | undefined = GetSafetyValue(call.args, "msgId");
        ChatClient.getInstance().chatManager()?.addReaction(msgId, reaction)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private removeReaction(call: MethodCall, result: MethodResult) {
        let reaction: string | undefined = GetSafetyValue(call.args, "reaction");
        let msgId: string | undefined = GetSafetyValue(call.args, "msgId");
        ChatClient.getInstance().chatManager()?.removeReaction(msgId, reaction)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private fetchReactionList(call: MethodCall, result: MethodResult) {
        let msgIds: Array<string> | undefined = GetSafetyValue(call.args, "msgIds");
        let groupId: string | undefined = GetSafetyValue(call.args, "groupId");
        let chatType = EnumTool.chatTypeFromInt(GetSafetyValue(call.args, "chatType")! as number);
        ChatClient.getInstance().chatManager()?.fetchReactions(msgIds, chatType, groupId)
            .then((value) => {
            let data = new Map<string, Object>();
            value.forEach((v, k) => {
                data.set(k, ChatMessageReactionHelper.listToJson(v));
            });
            this.onSuccess(result, call.method, data);
        })
            .catch((e: ChatError) => this.onError(result, e));
    }
    private fetchReactionDetail(call: MethodCall, result: MethodResult) {
        let params = new FetchReactionDetailParams();
        params.messageId = GetSafetyValue(call.args, "msgId") ?? "";
        params.reaction = GetSafetyValue(call.args, "reaction") ?? "";
        params.cursor = GetSafetyValue(call.args, "cursor");
        params.pageSize = GetSafetyValue(call.args, "pageSize") ?? 20;
        ChatClient.getInstance().chatManager()?.fetchReactionDetail(params)
            .then((value) => this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private reportMessage(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private getConversationsFromServerWithPage(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private removeMessagesFromServerWithMsgIds(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.removeMessagesFromServer(GetSafetyValue(call.args, "convId"), GetSafetyValue(call.args, "type"), GetSafetyValue(call.args, "msgIds"))
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private removeMessagesFromServerWithTs(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private getConversationsFromServerWithCursor(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.fetchConversationsFromServer(GetSafetyValue(call.args, "pageSize"), GetSafetyValue(call.args, "cursor"))
            .then((value) => this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private getPinnedConversationsFromServerWithCursor(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.fetchPinnedConversationsFromServer(GetSafetyValue(call.args, "pageSize"), GetSafetyValue(call.args, "cursor"))
            .then((value) => this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private pinConversation(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.pinConversation(GetSafetyValue(call.args, "convId"), GetSafetyValue(call.args, "isPinned") ?? false)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private modifyMessage(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.modifyMessage(GetSafetyValue(call.args, "msgId"), MessageBodyHelper.textBodyFromJson(GetSafetyValue(call.args, "body")!))
            .then((value) => this.onSuccess(result, call.method, MessageHelper.toJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private downloadAndParseCombineMessage(call: MethodCall, result: MethodResult) {
        let msg = MessageHelper.fromJson(call.args);
        ChatClient.getInstance().chatManager()?.downloadAndParseCombineMessage(msg)
            .then((value) => this.onSuccess(result, call.method, MessageHelper.listToJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private addRemoteAndLocalConversationsMark(call: MethodCall, result: MethodResult) {
        let convIds: Array<string> = GetSafetyValue(call.args, "convIds")!;
        let mark: number = GetSafetyValue(call.args, "mark")!;
        ChatClient.getInstance().chatManager()?.addConversationMark(convIds, mark)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private deleteRemoteAndLocalConversationsMark(call: MethodCall, result: MethodResult) {
        let convIds: Array<string> = GetSafetyValue(call.args, "convIds")!;
        let mark: number = GetSafetyValue(call.args, "mark")!;
        ChatClient.getInstance().chatManager()?.removeConversationMark(convIds, mark)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private fetchConversationsByOptions(call: MethodCall, result: MethodResult) {
        let isPinned: boolean = GetSafetyValue(call.args, "pinned") ?? false;
        if (isPinned) {
            ChatClient.getInstance().chatManager()?.fetchPinnedConversationsFromServer(GetSafetyValue(call.args, "pageSize"), GetSafetyValue(call.args, "cursor"))
                .then((value) => this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
                .catch((e: ChatError) => this.onError(result, e));
            return;
        }
        let mark: MarkType | undefined = GetSafetyValue(call.args, "mark");
        if (mark != undefined) {
            ChatClient.getInstance().chatManager()?.fetchConversationsFromServerWithFilter(ConversationFilterHelper.fromJson(call.args))
                .then((value) => this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
                .catch((e: ChatError) => this.onError(result, e));
            return;
        }
        ChatClient.getInstance().chatManager()?.fetchConversationsFromServer(GetSafetyValue(call.args, "pageSize"), GetSafetyValue(call.args, "cursor"))
            .then((value) => this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private deleteAllMessageAndConversation(call: MethodCall, result: MethodResult) {
        let clearServerData: boolean | undefined = GetSafetyValue(call.args, "clearServerData", false);
        ChatClient.getInstance().chatManager()?.deleteAllConversationsAndMessages(clearServerData);
        this.noSupport(result);
    }
    private pinMessage(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.pinMessage(GetSafetyValue(call.args, "msgId"))
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private unpinMessage(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.unpinMessage(GetSafetyValue(call.args, "msgId"))
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private fetchPinnedMessages(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.fetchPinnedMessagesFromServer(GetSafetyValue(call.args, "convId"))
            .then((value) => this.onSuccess(result, call.method, MessageHelper.listToJson(value)))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private searchMsgByOptions(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private getMessageCount(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().chatManager()?.getDBMsgsCount()
            .then((value) => this.onSuccess(result, call.method, value))
            .catch((e: ChatError) => this.onError(result, e));
    }
}
