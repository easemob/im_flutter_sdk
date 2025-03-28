import { ConversationFilter } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { MarkType } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { GetSafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
export default class ConversationFilterHelper {
    static fromJson(json: Map<string, Object>): ConversationFilter {
        let filter = new ConversationFilter();
        let mark: MarkType | undefined = GetSafetyValue(json, "mark");
        if (mark != undefined) {
            filter.markType = mark;
        }
        let pageSize: number | undefined = GetSafetyValue(json, "pageSize");
        if (pageSize != undefined) {
            filter.pageSize = pageSize;
        }
        let cursor: string | undefined = GetSafetyValue(json, "cursor");
        if (cursor != undefined) {
            filter.cursor = cursor;
        }
        return filter;
    }
}
