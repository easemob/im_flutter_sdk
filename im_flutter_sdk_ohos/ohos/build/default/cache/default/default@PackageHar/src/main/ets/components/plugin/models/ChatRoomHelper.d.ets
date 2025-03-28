import { Chatroom } from "@easemob/chatsdk";
export default class ChatRoomHelper {
    static toJson(chatroom: Chatroom): Map<string, Object>;
    static listToJson(chatroom: Chatroom[]): Map<string, Object>[];
}
