import { Any } from "@ohos/flutter_ohos";
export type StringCallback<T> = (obj: T) => void;
export declare function SafetyValue<T>(value: T, func: StringCallback<T>, defaultValue?: T): void;
export declare function GetSafetyValue<T>(args: Any, key: string, defaultValue?: T): T | undefined;
export declare function IsObj(object: Object): boolean;
export declare function ObjToMap(obj: Any): Map<string, string>;
