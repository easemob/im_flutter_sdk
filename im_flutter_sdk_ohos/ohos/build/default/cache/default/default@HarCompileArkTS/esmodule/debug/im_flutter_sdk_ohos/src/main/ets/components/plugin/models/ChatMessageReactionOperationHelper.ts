import type { ChatMessageReactionOperation } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import EnumTool from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/EnumTool&1.0.0";
import { SafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
export default class ChatMessageReactionOperationHelper {
    static toJson(operation: ChatMessageReactionOperation): Map<string, Object> {
        let data = new Map<string, Object>();
        SafetyValue(operation.userId(), (value) => data.set("userId", value));
        SafetyValue(operation.reaction(), (value) => data.set("reaction", value));
        SafetyValue(operation.operation(), (value) => data.set("operate", EnumTool.reactionOperationToInt(value)));
        return data;
    }
    static listToJson(operations: ChatMessageReactionOperation[]): Map<string, Object>[] {
        let list = new Array<Map<string, Object>>();
        for (let index = 0; index < operations.length; index++) {
            const operation = operations[index];
            list.push(ChatMessageReactionOperationHelper.toJson(operation));
        }
        return list;
    }
}
