import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodResult,
} from '@ohos/flutter_ohos';


import common from '@ohos.app.ability.common';
import ClientWrapper from './ClientWrapper';

/** ImFlutterSdkOhPlugin **/
export default class ImFlutterSdkOhPlugin implements FlutterPlugin {
  private clientWrapper: ClientWrapper | null = null;
  constructor() {
  }

  getUniqueClassName(): string {
    return "ImFlutterSdkOhPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.clientWrapper = new ClientWrapper(binding, "chat_client");
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.clientWrapper?.unRegisterEaseListener();
  }

  public sendDataToFlutter(data: Map<string, Object>):void {
    if(this.clientWrapper != null) {
      this.clientWrapper.sendDataToFlutter(data);
    }
  }
}

