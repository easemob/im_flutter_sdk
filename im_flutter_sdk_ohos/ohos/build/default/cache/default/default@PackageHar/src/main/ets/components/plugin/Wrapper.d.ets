import { FlutterPluginBinding, MethodCall, MethodCallHandler, MethodChannel, MethodResult } from "@ohos/flutter_ohos";
import { common } from "@kit.AbilityKit";
import { ChatError } from "@easemob/chatsdk";
export default class Wrapper implements MethodCallHandler {
    context: common.Context | undefined;
    binding: FlutterPluginBinding | undefined;
    channel: MethodChannel | undefined;
    constructor(binding: FlutterPluginBinding, channelName: string);
    onSuccess(result: MethodResult, method: string, object?: Object | null): void;
    onError(result: MethodResult, e: ChatError): void;
    asyncRunnable(func: Function): Promise<void>;
    onErrorInfo(result: MethodResult, code: number, desc: string): void;
    noSupport(result: MethodResult): void;
    registerEaseListener(): void;
    unRegisterEaseListener(): void;
    onMethodCall(_: MethodCall, result: MethodResult): void;
}
