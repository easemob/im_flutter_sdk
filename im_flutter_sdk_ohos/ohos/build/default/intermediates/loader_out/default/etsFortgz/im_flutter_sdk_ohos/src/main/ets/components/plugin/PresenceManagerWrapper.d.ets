import { FlutterPluginBinding, MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import Wrapper from './Wrapper';
export default class PresenceManagerWrapper extends Wrapper implements MethodCallHandler {
    private listener;
    constructor(binding: FlutterPluginBinding, channelName: string);
    onMethodCall(call: MethodCall, result: MethodResult): void;
    private publishPresenceWithDescription;
    private subscribe;
    private unsubscribe;
    private fetchPresenceStatus;
    private fetchSubscribedMembersWithPageNum;
    registerEaseListener(): void;
    unRegisterEaseListener(): void;
}
