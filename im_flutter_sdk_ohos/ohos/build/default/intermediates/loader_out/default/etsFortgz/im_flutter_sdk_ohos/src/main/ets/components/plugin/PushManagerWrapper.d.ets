import { FlutterPluginBinding, MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import Wrapper from './Wrapper';
export default class PushManagerWrapper extends Wrapper implements MethodCallHandler {
    constructor(binding: FlutterPluginBinding, channelName: string);
    onMethodCall(call: MethodCall, result: MethodResult): void;
    getImPushConfig(call: MethodCall, result: MethodResult): void;
    getImPushConfigFromServer(call: MethodCall, result: MethodResult): void;
    updatePushNickname(call: MethodCall, result: MethodResult): void;
    updateImPushStyle(call: MethodCall, result: MethodResult): void;
    updateHMSPushToken(call: MethodCall, result: MethodResult): void;
    updateFCMPushToken(call: MethodCall, result: MethodResult): void;
    reportPushAction(call: MethodCall, result: MethodResult): void;
    setConversationSilentMode(call: MethodCall, result: MethodResult): void;
    removeConversationSilentMode(call: MethodCall, result: MethodResult): void;
    fetchConversationSilentMode(call: MethodCall, result: MethodResult): void;
    setSilentModeForAll(call: MethodCall, result: MethodResult): void;
    fetchSilentModeForAll(call: MethodCall, result: MethodResult): void;
    fetchSilentModeForConversations(call: MethodCall, result: MethodResult): void;
    setPreferredNotificationLanguage(call: MethodCall, result: MethodResult): void;
    fetchPreferredNotificationLanguage(call: MethodCall, result: MethodResult): void;
    getPushTemplate(call: MethodCall, result: MethodResult): void;
    setPushTemplate(call: MethodCall, result: MethodResult): void;
    syncSilentModels(call: MethodCall, result: MethodResult): void;
    bindDeviceToken(call: MethodCall, result: MethodResult): void;
}
