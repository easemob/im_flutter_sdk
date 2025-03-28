import { FlutterPluginBinding, MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import Wrapper from './Wrapper';
export default class MessageWrapper extends Wrapper implements MethodCallHandler {
    constructor(binding: FlutterPluginBinding, channelName: string);
    onMethodCall(call: MethodCall, result: MethodResult): void;
    private reactionList;
    private getAckCount;
    private getChatThread;
    private getPinInfo;
    private getMessageWithId;
}
