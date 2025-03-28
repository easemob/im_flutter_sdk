import { ChatClient, ChatError, Presence, PresenceListener } from '@easemob/chatsdk';
import { FlutterPluginBinding, MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import Wrapper from './Wrapper';
import MethodKey from './MethodKeys';
import { PresenceHelper } from './models/PresenceHelper';

export default class PresenceManagerWrapper extends Wrapper implements MethodCallHandler {
  private listener: PresenceListener | undefined;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.presenceWithDescription === call.method) {
      this.publishPresenceWithDescription(call, result);
    } else if (MethodKey.presenceSubscribe === call.method) {
      this.subscribe(call, result);
    } else if (MethodKey.presenceUnsubscribe === call.method) {
      this.unsubscribe(call, result);
    } else if (MethodKey.fetchPresenceStatus === call.method) {
      this.fetchPresenceStatus(call, result);
    } else if (MethodKey.fetchSubscribedMembersWithPageNum === call.method) {
      this.fetchSubscribedMembersWithPageNum(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private publishPresenceWithDescription(call: MethodCall, result: MethodResult) {
    const desc = call.argument('desc') as string;
    ChatClient.getInstance().presenceManager()?.publishPresence(desc)
      .then(() => this.onSuccess(result, call.method, true))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private subscribe(call: MethodCall, result: MethodResult) {
    const members = call.argument('members') as string[];
    const expiry = call.argument('expiry') as number;
    ChatClient.getInstance().presenceManager()?.subscribePresences(members, expiry)
      .then((presences: Presence[]) => {
        const list = presences.map(presence => PresenceHelper.toJson(presence));
        this.onSuccess(result, call.method, list);
      })
      .catch((e: ChatError) => this.onError(result, e));
  }

  private unsubscribe(call: MethodCall, result: MethodResult) {
    const members = call.argument('members') as string[];
    ChatClient.getInstance().presenceManager()?.unsubscribePresences(members)
      .then(() => this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private fetchPresenceStatus(call: MethodCall, result: MethodResult) {
    const members = call.argument('members') as string[];
    ChatClient.getInstance().presenceManager()?.fetchPresenceStatus(members)
      .then((presences: Presence[]) => {
        const list = presences.map(presence => PresenceHelper.toJson(presence));
        this.onSuccess(result, call.method, list);
      })
      .catch((e: ChatError) => this.onError(result, e));
  }

  private fetchSubscribedMembersWithPageNum(call: MethodCall, result: MethodResult) {
    const pageSize = call.argument('pageSize') as number;
    const pageNum = call.argument('pageNum') as number;
    ChatClient.getInstance().presenceManager()?.fetchSubscribedMembers(pageNum, pageSize)
      .then((members: string[]) => this.onSuccess(result, call.method, members))
      .catch((e: ChatError) => this.onError(result, e));
  }

  registerEaseListener() {
    this.unRegisterEaseListener();
    let weakRef = new WeakRef(this);
    this.listener = {
      onPresenceUpdated(presences: Array<Presence>):void {
        let retrievedObject = weakRef.deref();
        const list = presences.map(presence => PresenceHelper.toJson(presence));
        retrievedObject?.channel?.invokeMethod(MethodKey.onPresenceStatusChanged, list);
      }
    };
    ChatClient.getInstance().presenceManager()?.addListener(this.listener);
  }

  unRegisterEaseListener() {
    if (this.listener) {
      ChatClient.getInstance().presenceManager()?.removeListener(this.listener);
    }
  }
}