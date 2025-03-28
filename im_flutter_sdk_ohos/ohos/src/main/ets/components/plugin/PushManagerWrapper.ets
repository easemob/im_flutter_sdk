import {
  ChatClient,
  ChatError,
  Conversation,
  ConversationType,
  PushDisplayStyle,
  PushRemindType
} from '@easemob/chatsdk';
import { Any, FlutterPluginBinding, MethodCall, MethodCallHandler, MethodResult, ToolUtils } from '@ohos/flutter_ohos';
import MethodKey from './MethodKeys';
import { SilentModeParamHelper, SilentModeResultHelper } from './models/PushManagerHelper';
import Wrapper from './Wrapper';

export default class PushManagerWrapper extends Wrapper implements MethodCallHandler {

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.getImPushConfig == call.method) {
      this.getImPushConfig(call, result);
    }
    else if(MethodKey.getImPushConfigFromServer == call.method) {
      this.getImPushConfigFromServer(call, result);
    }
    else if(MethodKey.updatePushNickname == call.method) {
      this.updatePushNickname(call, result);
    }
    else if(MethodKey.updateImPushStyle == call.method) {
      this.updateImPushStyle(call, result);
    }
    else if(MethodKey.updateHMSPushToken == call.method) {
      this.updateHMSPushToken(call, result);
    }
    else if(MethodKey.updateFCMPushToken == call.method) {
      this.updateFCMPushToken(call, result);
    }
    else if (MethodKey.reportPushAction == call.method) {
      this.reportPushAction(call, result);
    }
    else if (MethodKey.setConversationSilentMode == call.method) {
      this.setConversationSilentMode(call, result);
    }
    else if (MethodKey.removeConversationSilentMode == call.method) {
      this.removeConversationSilentMode(call, result);
    }
    else if (MethodKey.fetchConversationSilentMode == call.method) {
      this.fetchConversationSilentMode(call, result);
    }
    else if (MethodKey.setSilentModeForAll == call.method) {
      this.setSilentModeForAll(call, result);
    }
    else if (MethodKey.fetchSilentModeForAll == call.method) {
      this.fetchSilentModeForAll(call, result);
    }
    else if (MethodKey.fetchSilentModeForConversations == call.method) {
      this.fetchSilentModeForConversations(call, result);
    }
    else if (MethodKey.setPreferredNotificationLanguage == call.method) {
      this.setPreferredNotificationLanguage(call, result);
    }
    else if (MethodKey.fetchPreferredNotificationLanguage == call.method) {
      this.fetchPreferredNotificationLanguage(call, result);
    }
    else if (MethodKey.getPushTemplate == call.method) {
      this.getPushTemplate(call, result);
    }
    else if (MethodKey.setPushTemplate == call.method) {
      this.setPushTemplate(call, result);
    }
    // 481
    else if (MethodKey.syncSilentModels == call.method) {
      this.syncSilentModels(call, result);
    }
    else if (MethodKey.bindDeviceToken == call.method) {
      this.bindDeviceToken(call, result);
    }
    else {
      super.onMethodCall(call, result);
    }
  }

  getImPushConfig(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  getImPushConfigFromServer(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  updatePushNickname(call: MethodCall, result: MethodResult) {
    let nickname = call.argument('nickname') as string;
    ChatClient.getInstance().pushManager()?.updatePushNickname(nickname).then(()=> {
      this.onSuccess(result, call.method, nickname);
    }).catch((e: ChatError) => {
      this.onError(result, e);
    })
  }

  updateImPushStyle(call: MethodCall, result: MethodResult) {
    const style = call.argument('pushStyle') as number;
    const displayStyle = style === 0 ? PushDisplayStyle.SimpleBanner : PushDisplayStyle.MessageSummary;
    ChatClient.getInstance().pushManager()?.updatePushDisplayStyle(displayStyle)
      .then(() => {
        this.onSuccess(result, call.method, style);
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  updateHMSPushToken(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  updateFCMPushToken(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  reportPushAction(call: MethodCall, result: MethodResult) {
    // Implement logic if needed
    this.noSupport(result);
  }

  setConversationSilentMode(call: MethodCall, result: MethodResult) {
    const conversationId = call.argument('conversationId') as string;
    const type = call.argument('conversationType') as ConversationType;
    const param = SilentModeParamHelper.fromJson(call.argument('param')) as PushRemindType;
    ChatClient.getInstance().pushManager()?.setSilentModeForConversation(conversationId, type, param)
      .then((r) => {
        this.onSuccess(result, call.method, SilentModeResultHelper.toJson(r));
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  removeConversationSilentMode(call: MethodCall, result: MethodResult) {
    const conversationId = call.argument('conversationId') as string;
    const type = call.argument('conversationType') as ConversationType;
    ChatClient.getInstance().pushManager()?.clearRemindTypeForConversation(conversationId, type)
      .then(() => {
        this.onSuccess(result, call.method);
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  fetchConversationSilentMode(call: MethodCall, result: MethodResult) {
    const conversationId = call.argument('conversationId') as string;
    const type = call.argument('conversationType') as ConversationType;
    ChatClient.getInstance().pushManager()?.getSilentModeForConversation(conversationId, type)
      .then((silentModeResult) => {
        this.onSuccess(result, call.method, SilentModeResultHelper.toJson(silentModeResult));
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  setSilentModeForAll(call: MethodCall, result: MethodResult) {
    const param = SilentModeParamHelper.fromJson(call.argument('param'));
    ChatClient.getInstance().pushManager()?.setSilentModeForAll(param)
      .then((r) => {
        this.onSuccess(result, call.method, SilentModeResultHelper.toJson(r));
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  fetchSilentModeForAll(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().pushManager()?.getSilentModeForAll()
      .then((silentModeResult) => {
        this.onSuccess(result, call.method, SilentModeResultHelper.toJson(silentModeResult));
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  fetchSilentModeForConversations(call: MethodCall, result: MethodResult) {
    let args:Any = call.args;
    let conversations: Conversation[] = [];
    if (args instanceof Map) {
      args.forEach((value: object, key: string) => {
        if (typeof value === 'number') {
          let conversation = ChatClient.getInstance().chatManager()?.getConversation(key, value, true);
          if (conversation) {
            conversations.push(conversation);
          }
        }
      })
    } else if (ToolUtils.isObj(args)){
      let keys = Object.keys(args);
      keys.forEach(key => {
        let type = args[key] as number;
        let conversation = ChatClient.getInstance().chatManager()?.getConversation(key, type, true);
        if (conversation) {
          conversations.push(conversation);
        }
      })
    }
    ChatClient.getInstance().pushManager()?.getSilentModeForConversations(conversations)
      .then((resultMap) => {
        let r = new Map<string, Map<string, object>>();
        resultMap.forEach((value, key) => {
          r.set(key, SilentModeResultHelper.toJson(value));
        })
        this.onSuccess(result, call.method, r);
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  setPreferredNotificationLanguage(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  fetchPreferredNotificationLanguage(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  getPushTemplate(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().pushManager()?.getPushTemplate()
      .then((template) => {
        this.onSuccess(result, call.method, template);
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  setPushTemplate(call: MethodCall, result: MethodResult) {
    const templateName = call.argument('pushTemplateName') as string;
    ChatClient.getInstance().pushManager()?.setPushTemplate(templateName)
      .then(() => {
        this.onSuccess(result, call.method);
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  syncSilentModels(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().pushManager()?.syncConversationsSilentModeFromServer()
      .then(() => {
        this.onSuccess(result, call.method);
      })
      .catch((e: ChatError) => {
        this.onError(result, e);
      });
  }

  bindDeviceToken(call: MethodCall, result: MethodResult) {
    const notifierName = call.argument('notifierName') as string;
    const deviceToken = call.argument('deviceToken') as string;
    if (notifierName && deviceToken) {
      ChatClient.getInstance().pushManager()?.uploadPushToken(deviceToken, notifierName)
        .then((token) => {
          this.onSuccess(result, call.method, token);
        })
        .catch((e: ChatError) => {
          this.onError(result, e);
        })
    } else if (notifierName) {
      ChatClient.getInstance().pushManager()?.unbindPushToken(notifierName)
        .then(()=> {
          this.onSuccess(result, call.method);
        })
        .catch((e: ChatError) => {
          this.onError(result, e);
        })
    }
  }
}