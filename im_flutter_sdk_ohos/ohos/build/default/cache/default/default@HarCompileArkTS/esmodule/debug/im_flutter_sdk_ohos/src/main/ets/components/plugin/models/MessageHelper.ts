import { ChatMessage, MessageDirection, ContentType, MessageStatus } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { MessageExtType, ChatMessageBody, TextMessageBody, ImageMessageBody, LocationMessageBody, CmdMessageBody, CustomMessageBody, FileMessageBody, VideoMessageBody, VoiceMessageBody, CombineMessageBody, ChatroomMessagePriority, ChatMessageReaction, ChatMessagePinInfo } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import EnumTool from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/EnumTool&1.0.0";
import JSON from "@ohos:util.json";
import MessageBodyHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/MessageBodyHelper&1.0.0";
import { GetSafetyValue, IsObj, SafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
import type { Any } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
export default class MessageHelper {
    static fromJson(json: Map<string, Object>): ChatMessage {
        let message: ChatMessage | undefined;
        let bodyMap = GetSafetyValue(json, "body") as object;
        let bodyType = EnumTool.messageBodyTypeFromInt(GetSafetyValue(bodyMap, "type")! as number);
        let direct = EnumTool.messageDirectFromInt(GetSafetyValue(json, "direction")! as number);
        let to = GetSafetyValue(json, "to") as string;
        let from = GetSafetyValue(json, "from") as string;
        let chatType = EnumTool.chatTypeFromInt(GetSafetyValue(json, "chatType")! as number);
        let msgId = GetSafetyValue(json, "msgId") as string;
        let body: ChatMessageBody | undefined;
        switch (bodyType) {
            case ContentType.TXT:
                {
                    body = MessageBodyHelper.textBodyFromJson(bodyMap);
                }
                break;
            case ContentType.IMAGE:
                {
                    body = MessageBodyHelper.imageBodyFromJson(bodyMap);
                }
                break;
            case ContentType.LOCATION:
                {
                    body = MessageBodyHelper.localBodyFromJson(bodyMap);
                }
                break;
            case ContentType.VIDEO:
                {
                    body = MessageBodyHelper.videoBodyFromJson(bodyMap);
                }
                break;
            case ContentType.VOICE:
                {
                    body = MessageBodyHelper.voiceBodyFromJson(bodyMap);
                }
                break;
            case ContentType.FILE:
                {
                    body = MessageBodyHelper.fileBodyFromJson(bodyMap);
                }
                break;
            case ContentType.CMD:
                {
                    body = MessageBodyHelper.cmdBodyFromJson(bodyMap);
                }
                break;
            case ContentType.CUSTOM:
                {
                    body = MessageBodyHelper.customBodyFromJson(bodyMap);
                }
                break;
            case ContentType.COMBINE:
                {
                    body = MessageBodyHelper.combineBodyFromJson(bodyMap);
                }
                break;
        }
        if (direct == MessageDirection.SEND) {
            message = ChatMessage.createSendMessage(to, body, chatType);
        }
        else {
            message = ChatMessage.createReceiveMessage(from, body, chatType, msgId);
        }
        message?.setTo(to);
        message?.setFrom(from);
        message?.setDirection(direct);
        message?.setReceiverRead(GetSafetyValue(json, "hasReadAck"));
        let status = EnumTool.messageStatusFromInt(GetSafetyValue(json, "status") as number);
        message?.setStatus(status);
        if (status == MessageStatus.SUCCESS) {
            message?.setUnread(!(GetSafetyValue(json, "hasRead") as boolean));
        }
        message?.setIsNeedGroupAck(GetSafetyValue(json, "needGroupAck"));
        let count: number | undefined = GetSafetyValue(json, "groupAckCount");
        if (count != undefined) {
            message?.setGroupAckCount(count);
        }
        message?.setBroadcast(GetSafetyValue(json, "broadcast"));
        message?.deliverOnlineOnly(GetSafetyValue(json, "deliverOnlineOnly"));
        message?.setLocalTimestamp(GetSafetyValue(json, "localTime"));
        message?.setServerTimestamp(GetSafetyValue(json, "serverTime"));
        message?.setDelivered(GetSafetyValue(json, "hasDeliverAck"));
        let priority: ChatroomMessagePriority | undefined = GetSafetyValue(json, "chatroomMessagePriority");
        if (priority != undefined) {
            message?.setPriority(priority);
        }
        message?.setMsgId(msgId);
        let attributes: Any = GetSafetyValue(json, "attributes");
        if (IsObj(attributes)) {
            let ext = new Map<string, MessageExtType>();
            let keys = Object.keys(attributes);
            for (let index = 0; index < keys.length; index++) {
                const k = keys[index];
                const v = attributes[k] as object;
                if (typeof v === "number" || typeof v === "string" || typeof v === "boolean") {
                    ext.set(k, v);
                }
                else if (v instanceof Object) {
                    // TODO: 待验证
                    message?.setJsonAttribute(k, JSON.stringify(v));
                }
            }
            if (ext.size != 0) {
                message?.setExt(ext);
            }
        }
        message?.setReceiverList(GetSafetyValue(json, "receiverList"));
        return message!;
    }
    static toJson(msg: ChatMessage | undefined): Map<string, Object> | undefined {
        if (!msg) {
            return undefined;
        }
        let data = new Map<string, Object>();
        switch (msg.getType()) {
            case ContentType.TXT:
                data.set("body", MessageBodyHelper.textBodyToJson(msg.getBody() as TextMessageBody));
                break;
            case ContentType.IMAGE:
                data.set("body", MessageBodyHelper.imageBodyToJson(msg.getBody() as ImageMessageBody));
                break;
            case ContentType.LOCATION:
                data.set("body", MessageBodyHelper.localBodyToJson(msg.getBody() as LocationMessageBody));
                break;
            case ContentType.CMD:
                data.set("body", MessageBodyHelper.cmdBodyToJson(msg.getBody() as CmdMessageBody));
                break;
            case ContentType.CUSTOM:
                data.set("body", MessageBodyHelper.customBodyToJson(msg.getBody() as CustomMessageBody));
                break;
            case ContentType.FILE:
                data.set("body", MessageBodyHelper.fileBodyToJson(msg.getBody() as FileMessageBody));
                break;
            case ContentType.VIDEO:
                data.set("body", MessageBodyHelper.videoBodyToJson(msg.getBody() as VideoMessageBody));
                break;
            case ContentType.VOICE:
                data.set("body", MessageBodyHelper.voiceBodyToJson(msg.getBody() as VoiceMessageBody));
                break;
            case ContentType.COMBINE:
                data.set("body", MessageBodyHelper.combineBodyToJson(msg.getBody() as CombineMessageBody));
                break;
        }
        SafetyValue(msg.ext(), (value) => data.set("attributes", value));
        SafetyValue(msg.getFrom(), (value) => data.set("from", value));
        SafetyValue(msg.getTo(), (value) => data.set("to", value));
        SafetyValue(msg.isReceiverRead(), (value) => data.set("hasReadAck", value));
        SafetyValue(msg.isDelivered(), (value) => data.set("hasDeliverAck", value));
        SafetyValue(msg.getLocalTimestamp(), (value) => data.set("localTime", value));
        SafetyValue(msg.getServerTimestamp(), (value) => data.set("serverTime", value));
        SafetyValue(msg.getStatus(), (value) => data.set("status", EnumTool.messageStatusToInt(value)));
        SafetyValue(msg.getChatType(), (value) => data.set("chatType", EnumTool.chatTypeToInt(value)));
        SafetyValue(msg.getDirection(), (value) => data.set("direction", EnumTool.messageDirectToInt(value)));
        SafetyValue(msg.getConversationId(), (value) => data.set("conversationId", value));
        SafetyValue(msg.getMsgId(), (value) => data.set("msgId", value));
        SafetyValue(msg.isUnread(), (value) => data.set("hasRead", !value));
        SafetyValue(msg.isNeedGroupAck(), (value) => data.set("needGroupAck", value));
        SafetyValue(msg.isOnlineState(), (value) => data.set("onlineState", value));
        SafetyValue(msg.isBroadcast(), (value) => data.set("broadcast", value));
        data.set("isThread", false);
        data.set("isContentReplaced", false);
        return data;
    }
    static listToJson(msgs: ChatMessage[] | undefined): Map<string, Object>[] {
        let list = new Array<Map<string, Object>>();
        if (msgs) {
            for (let index = 0; index < msgs.length; index++) {
                const msg = msgs[index];
                let message = MessageHelper.toJson(msg);
                if (message) {
                    list.push(message);
                }
            }
        }
        return list;
    }
}
export class MessageReactionHelper {
    static toJson(reaction: ChatMessageReaction): Map<string, Object> {
        const data = new Map<string, Object>();
        data.set("reaction", reaction.reaction());
        data.set("count", reaction.userCount());
        data.set("isAddedBySelf", reaction.isAddedBySelf());
        data.set("userList", reaction.userIds());
        return data;
    }
}
export class MessagePinInfoHelper {
    static toJson(info: ChatMessagePinInfo): Map<string, Object> {
        const data = new Map<string, Object>();
        data.set("pinTime", info.pinTime());
        data.set("operatorId", info.operatorId());
        return data;
    }
}
