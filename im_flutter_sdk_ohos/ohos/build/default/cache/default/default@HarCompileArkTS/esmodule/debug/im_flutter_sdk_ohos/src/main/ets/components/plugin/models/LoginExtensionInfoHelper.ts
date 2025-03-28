import type { LoginExtInfo } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { SafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
export default class LoginExtensionInfoHelper {
    static toJson(info: LoginExtInfo): Map<string, Object> {
        let ret = new Map<string, Object>();
        SafetyValue(info.deviceInfo, (value) => ret.set("deviceName", value));
        SafetyValue(info.deviceExt, (value) => ret.set("ext", value));
        return ret;
    }
}
