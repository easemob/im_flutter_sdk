import type { Any } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
export type StringCallback<T> = (obj: T) => void;
export function SafetyValue<T>(value: T, func: StringCallback<T>, defaultValue?: T) {
    if (value != undefined && value != null) {
        func(value);
    }
    else if (defaultValue) {
        func(defaultValue);
    }
}
export function GetSafetyValue<T>(args: Any, key: string, defaultValue?: T): T | undefined {
    let ret: T | undefined;
    do {
        if (args instanceof Map) {
            if (args.has(key)) {
                ret = args.get(key) as T;
                break;
            }
        }
        if (IsObj(args)) {
            let keys = Object.keys(args);
            if (keys.includes(key)) {
                ret = args[key] as T;
            }
        }
    } while (false);
    if (ret == undefined)
        ret = defaultValue;
    return ret;
}
export function IsObj(object: Object): boolean {
    return object && typeof (object) == 'object';
}
export function ObjToMap(obj: Any): Map<string, string> {
    let map = new Map<string, string>();
    if (IsObj(obj)) {
        let keys = Object.keys(obj);
        for (let index = 0; index < keys.length; index++) {
            const key = keys[index];
            let v = obj[key] as object;
            if (typeof v === "string") {
                map.set(key, v);
            }
        }
    }
    return map;
}
