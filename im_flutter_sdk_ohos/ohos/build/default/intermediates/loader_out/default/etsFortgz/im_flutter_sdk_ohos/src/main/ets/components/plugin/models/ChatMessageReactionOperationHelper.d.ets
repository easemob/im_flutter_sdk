import { ChatMessageReactionOperation } from "@easemob/chatsdk";
export default class ChatMessageReactionOperationHelper {
    static toJson(operation: ChatMessageReactionOperation): Map<string, Object>;
    static listToJson(operations: ChatMessageReactionOperation[]): Map<string, Object>[];
}
