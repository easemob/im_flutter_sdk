import type { FlutterPluginBinding, MethodCallHandler } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import Wrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/Wrapper&1.0.0";
export default class ChatThreadManagerWrapper extends Wrapper implements MethodCallHandler {
    constructor(binding: FlutterPluginBinding, channelName: string) {
        super(binding, channelName);
    }
}
