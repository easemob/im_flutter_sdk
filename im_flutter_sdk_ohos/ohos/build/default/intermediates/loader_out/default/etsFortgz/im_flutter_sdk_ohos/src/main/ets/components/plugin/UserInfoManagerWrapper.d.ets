import { FlutterPluginBinding, MethodCallHandler, MethodCall, MethodResult } from "@ohos/flutter_ohos";
import Wrapper from "./Wrapper";
export default class UserInfoManagerWrapper extends Wrapper implements MethodCallHandler {
    constructor(binding: FlutterPluginBinding, channelName: string);
    onMethodCall(call: MethodCall, result: MethodResult): void;
    private updateOwnUserInfo;
    private fetchUserInfoByUserId;
    private generateMapFromMap;
}
