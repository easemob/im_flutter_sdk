import { ChatMessage, ChatMessageReaction, ChatMessagePinInfo } from "@easemob/chatsdk";
export default class MessageHelper {
    static fromJson(json: Map<string, Object>): ChatMessage;
    static toJson(msg: ChatMessage | undefined): Map<string, Object> | undefined;
    static listToJson(msgs: ChatMessage[] | undefined): Map<string, Object>[];
}
export declare class MessageReactionHelper {
    static toJson(reaction: ChatMessageReaction): Map<string, Object>;
}
export declare class MessagePinInfoHelper {
    static toJson(info: ChatMessagePinInfo): Map<string, Object>;
}
