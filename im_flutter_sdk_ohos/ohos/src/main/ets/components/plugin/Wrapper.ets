import {
  FlutterPluginBinding,
  JSONMethodCodec,
  MethodCall, MethodCallHandler, MethodChannel, MethodResult
} from "@ohos/flutter_ohos";
import { common } from "@kit.AbilityKit";
import { ChatError } from "@easemob/chatsdk";
import ChatErrorHelper from "./models/ChatErrorHelper";
import taskPool from '@ohos.taskpool';


@Concurrent
function onSuccess(result: MethodResult, method: string, object?: Object | null): void {
  let map = new Map<string, Object>();
  if(object !== null && object !== undefined) {
    map.set(method, object);
  }
  result.success(map);
}


export default class Wrapper implements  MethodCallHandler{

  public context: common.Context  | undefined;
  public binding: FlutterPluginBinding | undefined;
  public channel: MethodChannel | undefined;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    this.context = binding.getApplicationContext();
    this.binding = binding;
    let channelKey = `com.chat.im/${channelName}`;
    console.log(`channelKey:  ${channelKey}`);
    this.channel = new MethodChannel(this.binding.getBinaryMessenger(), channelKey, JSONMethodCodec.INSTANCE);
    this.channel.setMethodCallHandler(this);
    this.registerEaseListener();
  }

  public onSuccess(result: MethodResult, method: string, object?: Object | null): void {
    // taskPool.execute(onSuccess, result, method, object);
    let map = new Map<string, Object>();
    if(object !== null && object !== undefined) {
      map.set(method, object);
    }
    result.success(map);
  }

  public onError(result: MethodResult, e: ChatError): void {
    let map = new Map<string, Object>();
    map.set("error", ChatErrorHelper.toJson(e));
    result.success(map);
  }

  public async asyncRunnable(func: Function) {
    await taskPool.execute(func);
  }

  public onErrorInfo(result: MethodResult, code: number, desc: string) {
    let map = new Map<string, Object>();
    map.set("error", ChatErrorHelper.infoToJson(code, desc));
    result.success(map);
  }

  public noSupport(result: MethodResult) {
    result.notImplemented();
    throw Error();
  }

  public registerEaseListener() {}

  public unRegisterEaseListener() {}

  onMethodCall(_: MethodCall, result: MethodResult): void {
    this.noSupport(result);
  }
}