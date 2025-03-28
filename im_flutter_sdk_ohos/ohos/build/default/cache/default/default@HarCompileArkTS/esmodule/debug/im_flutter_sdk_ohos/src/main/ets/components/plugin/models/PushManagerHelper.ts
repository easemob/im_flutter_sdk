import { PushRemindType } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { SilentModeParam, SilentModeResult, SilentModeTime, SilentModeTimeParam } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import { ToolUtils } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import type { Any } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import { GetSafetyValue } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
export class SilentModeParamHelper {
    static fromJson(json: Map<string, object> | object): SilentModeParam {
        if (ToolUtils.isObj(json)) {
            let keys = Object.keys(json);
            if (keys.includes('remindType')) {
                let remindType = GetSafetyValue(json, 'remindType', PushRemindType.ALL);
                return remindType ?? PushRemindType.ALL;
            }
            if (keys.includes('startTime') && keys.includes('endTime')) {
                let startTime = SilentModeTimeHelper.fromJson(GetSafetyValue(json, 'startTime'));
                let endTime = SilentModeTimeHelper.fromJson(GetSafetyValue(json, 'endTime'));
                return {
                    startTime: startTime,
                    endTime: endTime
                };
            }
        }
        else if (json instanceof Map) {
            if (json.has('remindType')) {
                let remindType = json.get('remindType');
                if (typeof remindType === 'number') {
                    return remindType as PushRemindType;
                }
                return PushRemindType.ALL;
            }
            if (json.has('startTime') && json.has('endTime')) {
                let startTime = SilentModeTimeHelper.fromJson(json.get('startTime'));
                let endTime = SilentModeTimeHelper.fromJson(json.get('endTime'));
                return {
                    startTime: startTime,
                    endTime: endTime
                };
            }
        }
        return PushRemindType.ALL;
    }
}
export class SilentModeTimeHelper {
    static fromJson(args: Any): SilentModeTimeParam {
        let hour: number = 0;
        let minute: number = 0;
        if (args instanceof Map) {
            args.forEach((value: number, key: string) => {
                if (key === 'hour') {
                    hour = value;
                }
                else if (key === 'minute') {
                    minute = value;
                }
            });
        }
        else if (ToolUtils.isObj(args)) {
            hour = args['hour'] as number;
            minute = args['minute'] as number;
        }
        return {
            hours: hour,
            minutes: minute
        };
    }
    static toJson(modeTime: SilentModeTime): Map<string, Object> {
        let data: Map<string, Object> = new Map();
        data.set('hour', modeTime.getHour());
        data.set('minute', modeTime.getMinute());
        return data;
    }
}
export class SilentModeResultHelper {
    static toJson(result: SilentModeResult): Map<string, Object> {
        let data = new Map<string, Object>();
        data.set('expireTs', result.getExpireTimestamp());
        if (result.getConversationId()) {
            data.set('conversationId', result.getConversationId());
        }
        if (result.getConversationType() !== undefined) {
            data.set('conversationType', result.getConversationType() as number);
        }
        let startTime = result.getSilentModeStartTime();
        if (startTime) {
            data.set('startTime', SilentModeTimeHelper.toJson(startTime));
        }
        let endTime = result.getSilentModeEndTime();
        if (endTime) {
            data.set('endTime', SilentModeTimeHelper.toJson(endTime));
        }
        if (result.getRemindType() !== undefined) {
            data.set('remindType', result.getRemindType() as number);
        }
        return data;
    }
}
