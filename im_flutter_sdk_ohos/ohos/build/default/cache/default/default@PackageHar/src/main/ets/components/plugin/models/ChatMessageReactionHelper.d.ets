import { ChatMessageReaction } from "@easemob/chatsdk";
export default class ChatMessageReactionHelper {
    static toJson(reaction: ChatMessageReaction): Map<string, Object>;
    static listToJson(reactions: ChatMessageReaction[]): Map<string, Object>[];
}
