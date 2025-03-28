import { Conversation } from "@easemob/chatsdk";
export default class ConversationHelper {
    static toJson(conv: Conversation | undefined): Map<string, Object> | null;
    static listToJson(conversations: Conversation[] | undefined): Map<string, Object>[];
}
