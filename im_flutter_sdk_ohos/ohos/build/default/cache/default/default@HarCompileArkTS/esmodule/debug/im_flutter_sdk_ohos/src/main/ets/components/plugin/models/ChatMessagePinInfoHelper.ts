import type { ChatMessagePinInfo } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { SafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
export default class ChatMessagePinInfoHelper {
    static toJson(info: ChatMessagePinInfo): Map<string, Object> {
        let data = new Map<string, Object>();
        SafetyValue(info.pinTime(), (value) => data.set("pinTime", value));
        SafetyValue(info.operatorId(), (value) => data.set("operatorId", value));
        return data;
    }
}
