import type { GroupReadAck } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { SafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
export default class GroupReadAckHelper {
    static toJson(ack: GroupReadAck): Map<string, Object> {
        let ret = new Map<string, Object>();
        SafetyValue(ack.getMsgId(), (value) => ret.set("msg_id", value));
        SafetyValue(ack.getAckId(), (value) => ret.set("ack_id", value));
        SafetyValue(ack.getFrom(), (value) => ret.set("from", value));
        SafetyValue(ack.getCount(), (value) => ret.set("count", value));
        SafetyValue(ack.getTimestamp(), (value) => ret.set("timestamp", value));
        SafetyValue(ack.getContent(), (value) => ret.set("content", value));
        return ret;
    }
    static listToJson(acks: GroupReadAck[]): Map<string, Object>[] {
        let list = new Array<Map<string, Object>>();
        for (let index = 0; index < acks.length; index++) {
            const ack = acks[index];
            list.push(GroupReadAckHelper.toJson(ack));
        }
        return list;
    }
}
