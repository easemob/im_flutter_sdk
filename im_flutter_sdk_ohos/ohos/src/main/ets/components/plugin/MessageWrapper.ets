import { ChatClient } from '@easemob/chatsdk';
import { FlutterPluginBinding, MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import Wrapper from './Wrapper';
import MethodKey from './MethodKeys';
import { MessagePinInfoHelper, MessageReactionHelper } from './models/MessageHelper';

export default class MessageWrapper extends Wrapper implements MethodCallHandler {
  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.getReactionList === call.method) {
      this.reactionList(call, result);
    } else if (MethodKey.groupAckCount === call.method) {
      this.getAckCount(call, result);
    } else if (MethodKey.getChatThread === call.method) {
      this.getChatThread(call, result);
    } else if (MethodKey.getPinInfo === call.method) {
      this.getPinInfo(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private reactionList(call: MethodCall, result: MethodResult) {
    const msgId = call.argument('msgId') as string;
    const msg = this.getMessageWithId(msgId);
    const list: Array<Map<string, Object>> = [];
    if (msg) {
      const reactions = msg.getReactions();
      if (reactions) {
        reactions.forEach(reaction => {
          list.push(MessageReactionHelper.toJson(reaction));
        });
      }
    }
    this.onSuccess(result, call.method, list);
  }

  private getAckCount(call: MethodCall, result: MethodResult) {
    const msgId = call.argument('msgId') as string;
    const msg = this.getMessageWithId(msgId);
    if (msg) {
      this.onSuccess(result, call.method, msg.groupAckCount());
    } else {
      this.onSuccess(result, call.method, 0);
    }
  }

  private getChatThread(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  private getPinInfo(call: MethodCall, result: MethodResult) {
    const msgId = call.argument('msgId') as string;
    const msg = this.getMessageWithId(msgId);
    if (msg) {
      const pinInfo = msg.getPinnedInfo();
      this.onSuccess(result, call.method, pinInfo ? MessagePinInfoHelper.toJson(pinInfo) : null);
    } else {
      this.onSuccess(result, call.method, null);
    }
  }

  private getMessageWithId(msgId: string) {
    return ChatClient.getInstance().chatManager()?.getMessage(msgId);
  }
}