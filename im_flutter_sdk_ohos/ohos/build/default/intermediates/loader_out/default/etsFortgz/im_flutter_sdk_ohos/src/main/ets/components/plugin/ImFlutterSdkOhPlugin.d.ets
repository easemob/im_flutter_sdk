import { FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos';
/** ImFlutterSdkOhPlugin **/
export default class ImFlutterSdkOhPlugin implements FlutterPlugin {
    private clientWrapper;
    constructor();
    getUniqueClassName(): string;
    onAttachedToEngine(binding: FlutterPluginBinding): void;
    onDetachedFromEngine(binding: FlutterPluginBinding): void;
    sendDataToFlutter(data: Map<string, Object>): void;
}
