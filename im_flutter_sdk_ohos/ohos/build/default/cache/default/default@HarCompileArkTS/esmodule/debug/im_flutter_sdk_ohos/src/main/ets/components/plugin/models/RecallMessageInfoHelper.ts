import type { RecallMessageInfo } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { SafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
import MessageHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/MessageHelper&1.0.0";
export default class RecallMessageInfoHelper {
    static toJson(info: RecallMessageInfo): Map<string, Object> {
        let data = new Map<string, Object>();
        SafetyValue(info.getRecallMessageId(), (value) => data.set("recallMsgId", value));
        SafetyValue(info.getRecallBy(), (value) => data.set("recallBy", value));
        SafetyValue(info.getExt(), (value) => data.set("ext", value));
        SafetyValue(info.getRecallMessage(), (value) => data.set("msg", MessageHelper.toJson(value)!));
        SafetyValue(info.getConversationId(), (value) => data.set("conversationId", value));
        return data;
    }
    static listToJson(infos: RecallMessageInfo[]): Map<string, Object>[] {
        let list = new Array<Map<string, Object>>();
        for (let index = 0; index < infos.length; index++) {
            const info = infos[index];
            list.push(RecallMessageInfoHelper.toJson(info));
        }
        return list;
    }
}
