import { ChatMessage, Chatroom, Group } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import ChatRoomHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ChatRoomHelper&1.0.0";
import GroupHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/GroupHelper&1.0.0";
import MessageHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/MessageHelper&1.0.0";
export default class PageResultHelper {
    // TODO: 补全类型
    static toJson(result: Chatroom[]): Map<string, Object> {
        let data = new Map<string, Object>();
        let list = Array<Object>();
        data.set("count", result.length);
        for (let index = 0; index < result.length; index++) {
            const element = result[index];
            if (element == undefined)
                continue;
            if (element instanceof Chatroom) {
                let item = ChatRoomHelper.toJson(element);
                if (item) {
                    list.push(item);
                }
            }
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
        }
        data.set("list", list);
        return data;
    }
}
