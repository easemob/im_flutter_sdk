import { FlutterPluginBinding, MethodCallHandler } from "@ohos/flutter_ohos";
import Wrapper from "./Wrapper";
export default class ChatThreadManagerWrapper extends Wrapper implements MethodCallHandler {
    constructor(binding: FlutterPluginBinding, channelName: string);
}
