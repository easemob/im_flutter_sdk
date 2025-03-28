import { ChatMessage, ChatMessageReaction, Chatroom, Contact, Conversation, Group, GroupReadAck } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { CursorResult } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { SafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
import ChatMessageReactionHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ChatMessageReactionHelper&1.0.0";
import ContactHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ContactHelper&1.0.0";
import ConversationHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ConversationHelper&1.0.0";
import GroupHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/GroupHelper&1.0.0";
import GroupReadAckHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/GroupReadAckHelper&1.0.0";
import MessageHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/MessageHelper&1.0.0";
export default class CursorResultHelper {
    // TODO: 补全类型
    static toJson<T>(result: CursorResult<T>): Map<string, Object> {
        let data = new Map<string, Object>();
        SafetyValue(result.getNextCursor(), (value) => data.set("cursor", value));
        let list = Array<Object>();
        for (let index = 0; index < result.getResult().length; index++) {
            const element = result.getResult()[index];
            if (element == undefined)
                continue;
            if (element instanceof ChatMessage) {
                let item = MessageHelper.toJson(element);
                if (item) {
                    list.push(item);
                }
            }
            else if (element instanceof Group) {
                let item = GroupHelper.toJson(element);
                if (item) {
                    list.push(item);
                }
            }
            else if (element instanceof Chatroom) {
            }
            else if (element instanceof GroupReadAck) {
                let item = GroupReadAckHelper.toJson(element);
                if (item) {
                    list.push(item);
                }
            }
            else if (element instanceof ChatMessageReaction) {
                let item = ChatMessageReactionHelper.toJson(element);
                if (item) {
                    list.push(item);
                }
            }
            else if (element instanceof Conversation) {
                let item = ConversationHelper.toJson(element);
                if (item) {
                    list.push(item);
                }
            }
            else if (element instanceof Contact) {
                list.push(ContactHelper.toJson(element));
            }
            else if (typeof element === "string") {
                list.push(element);
            }
        }
        data.set("list", list);
        return data;
    }
}
