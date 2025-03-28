import { SilentModeParam, SilentModeResult, SilentModeTime, SilentModeTimeParam } from "@easemob/chatsdk";
import { Any } from "@ohos/flutter_ohos";
export declare class SilentModeParamHelper {
    static fromJson(json: Map<string, object> | object): SilentModeParam;
}
export declare class SilentModeTimeHelper {
    static fromJson(args: Any): SilentModeTimeParam;
    static toJson(modeTime: SilentModeTime): Map<string, Object>;
}
export declare class SilentModeResultHelper {
    static toJson(result: SilentModeResult): Map<string, Object>;
}
