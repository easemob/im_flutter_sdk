import { FetchMessageOption } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { ContentType } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import EnumTool from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/EnumTool&1.0.0";
import { GetSafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
export default class FetchMessageOptionHelper {
    static fromJson(json: object | undefined | null): FetchMessageOption | undefined {
        if (!json) {
            return undefined;
        }
        let ret = new FetchMessageOption();
        ret.setDirection(GetSafetyValue(json, "direction"));
        ret.setIsSave(GetSafetyValue(json, "needSave"));
        ret.setStartTime(GetSafetyValue(json, "startTs"));
        ret.setEndTime(GetSafetyValue(json, "endTs"));
        let from: undefined | string = GetSafetyValue(json, "from");
        if (from != undefined) {
            ret.setFrom(from);
        }
        let typeList: Array<number> | undefined;
        typeList = GetSafetyValue(json, "msgTypes");
        if (typeList != undefined) {
            let types = new Array<ContentType>();
            for (let index = 0; index < typeList.length; index++) {
                const element = typeList[index];
                types.push(EnumTool.messageBodyTypeFromInt(element));
            }
            ret.setMsgTypes(types);
        }
        return ret;
    }
}
