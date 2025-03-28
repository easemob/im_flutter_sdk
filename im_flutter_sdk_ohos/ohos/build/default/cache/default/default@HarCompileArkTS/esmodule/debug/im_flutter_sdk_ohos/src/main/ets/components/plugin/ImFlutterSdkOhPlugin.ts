import type { FlutterPlugin, FlutterPluginBinding } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import ClientWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/ClientWrapper&1.0.0";
/** ImFlutterSdkOhPlugin **/
export default class ImFlutterSdkOhPlugin implements FlutterPlugin {
    private clientWrapper: ClientWrapper | null = null;
    constructor() {
    }
    getUniqueClassName(): string {
        return "ImFlutterSdkOhPlugin";
    }
    onAttachedToEngine(binding: FlutterPluginBinding): void {
        this.clientWrapper = new ClientWrapper(binding, "chat_client");
    }
    onDetachedFromEngine(binding: FlutterPluginBinding): void {
        this.clientWrapper?.unRegisterEaseListener();
    }
    public sendDataToFlutter(data: Map<string, Object>): void {
        if (this.clientWrapper != null) {
            this.clientWrapper.sendDataToFlutter(data);
        }
    }
}
