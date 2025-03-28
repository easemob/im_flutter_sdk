import { ChatMessageReactionChange } from "@easemob/chatsdk";
export default class ChatMessageReactionChangeHelper {
    static toJson(change: ChatMessageReactionChange): Map<string, Object>;
    static listToJson(changes: ChatMessageReactionChange[]): Map<string, Object>[];
}
