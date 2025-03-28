import type { Chatroom } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { SafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
export default class ChatRoomHelper {
    static toJson(chatroom: Chatroom): Map<string, Object> {
        let ret = new Map<string, Object>();
        SafetyValue(chatroom.chatroomId(), (value) => ret.set("roomId", value));
        SafetyValue(chatroom.chatroomName(), (value) => ret.set("name", value));
        SafetyValue(chatroom.chatroomDescription(), (value) => ret.set("desc", value));
        SafetyValue(chatroom.owner(), (value) => ret.set("owner", value));
        SafetyValue(chatroom.memberCount(), (value) => ret.set("memberCount", value));
        SafetyValue(chatroom.admins(), (value) => ret.set("adminList", value));
        SafetyValue(chatroom.members(), (value) => ret.set("memberList", value));
        SafetyValue(chatroom.blocklist(), (value) => ret.set("blockList", value));
        SafetyValue(Array.from(chatroom.mutes().keys()), (value) => ret.set("muteList", value));
        SafetyValue(chatroom.isAllMemberMuted(), (value) => ret.set("isAllMemberMuted", value));
        SafetyValue(chatroom.chatroomAnnouncement(), (value) => ret.set("announcement", value));
        SafetyValue(chatroom.createTimestamp(), (value) => ret.set("createTimestamp", value));
        SafetyValue(chatroom.currentUserRole(), (value) => ret.set("permissionType", value));
        SafetyValue(chatroom.muteExpireTimestamp(), (value) => ret.set("muteExpireTimestamp", value));
        SafetyValue(chatroom.isInWhitelist(), (value) => ret.set("isInWhitelist", value));
        return ret;
    }
    static listToJson(chatroom: Chatroom[]): Map<string, Object>[] {
        let list = new Array<Map<string, Object>>();
        for (let index = 0; index < chatroom.length; index++) {
            const contact = chatroom[index];
            list.push(ChatRoomHelper.toJson(contact));
        }
        return list;
    }
}
