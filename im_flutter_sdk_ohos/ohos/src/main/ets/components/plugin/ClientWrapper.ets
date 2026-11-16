import {
  ChatClient,
  ChatError,
  ChatOptions,
  ConnectionListener,
  ConversationType,
  LoginExtInfo,
  MultiDevicesEvent,
  MultiDevicesListener,
} from '@easemob/chatsdk';
import { FlutterPluginBinding, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import MethodKey from './MethodKeys';
import Wrapper from './Wrapper';
import SafetyMapTool from './SafetyMapTool';
import ChatOptionsHelper from './models/ChatOptionsHelper';
import LoginExtensionInfoHelper from './models/LoginExtensionInfoHelper';

/**
 * Wrapper for the `com.chat.im/chat_client` channel.
 *
 * Implements every chat_client method key kept in the ohos-branch Dart
 * constants (the set after the T2.0a removal), registers the chatsdk
 * ConnectionListener / MultiDevicesListener and forwards their callbacks to
 * Dart as channel events. The seven logout-reason events are dispatched
 * second-level from the onLogout / onDisconnected error codes, mirroring the
 * android ClientWrapper (errorCode 8 onAppActiveNumberReachLimit has been
 * removed from Dart, so it falls through to onDisconnected).
 */
export default class ClientWrapper extends Wrapper {
  private connectionListener: ConnectionListener | undefined;
  private multiDevicesListener: MultiDevicesListener | undefined;
  private inited: boolean = false;

  /**
   * Called right after a successful ChatClient.init. The plugin uses this to
   * eagerly register every wrapper's SDK listeners: the android/ios wrappers
   * register listeners in their constructors, so an app that only listens
   * (never calls a manager API) still receives events. On ohos the manager
   * getters are undefined before init, so registration is deferred to here
   * (and to the first onMethodCall of each wrapper).
   */
  private onInitSuccessListener: (() => void) | undefined;

  public setOnInitSuccessListener(listener: (() => void) | undefined): void {
    this.onInitSuccessListener = listener;
  }

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  override onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.init === call.method) {
      this.init(call, result);
    } else if (MethodKey.createAccount === call.method) {
      this.createAccount(call, result);
    } else if (MethodKey.login === call.method) {
      this.login(call, result);
    } else if (MethodKey.renewToken === call.method) {
      this.renewToken(call, result);
    } else if (MethodKey.logout === call.method) {
      this.logout(call, result);
    } else if (MethodKey.changeAppKey === call.method) {
      this.changeAppKey(call, result);
    } else if (MethodKey.changeAppId === call.method) {
      this.changeAppId(call, result);
    } else if (MethodKey.uploadLog === call.method) {
      this.uploadLog(call, result);
    } else if (MethodKey.getToken === call.method) {
      this.getToken(call, result);
    } else if (MethodKey.getCurrentUser === call.method) {
      this.getCurrentUser(call, result);
    } else if (MethodKey.getCurrentDeviceId === call.method) {
      this.getCurrentDeviceId(call, result);
    } else if (MethodKey.isConnected === call.method) {
      this.isConnected(call, result);
    } else if (MethodKey.getConnectionState === call.method) {
      this.getConnectionState(call, result);
    } else if (MethodKey.startCallback === call.method) {
      this.startCallback(call, result);
    } else if (MethodKey.updateUsingHttpsOnlySetting === call.method) {
      this.updateUsingHttpsOnlySetting(call, result);
    } else if (MethodKey.updateLoginExtensionInfo === call.method) {
      this.updateLoginExtensionInfo(call, result);
    } else if (MethodKey.updateDeleteMessagesWhenLeaveGroupSetting === call.method) {
      this.updateDeleteMessagesWhenLeaveGroupSetting(call, result);
    } else if (MethodKey.updateDeleteMessageWhenLeaveRoomSetting === call.method) {
      this.updateDeleteMessageWhenLeaveRoomSetting(call, result);
    } else if (MethodKey.updateAutoAcceptGroupInvitationSetting === call.method) {
      this.updateAutoAcceptGroupInvitationSetting(call, result);
    } else if (MethodKey.updateAcceptInvitationAlways === call.method) {
      this.acceptInvitationAlways(call, result);
    } else if (MethodKey.updateAutoDownloadAttachmentThumbnailSetting === call.method) {
      this.updateAutoDownloadAttachmentThumbnailSetting(call, result);
    } else if (MethodKey.updateRequireAckSetting === call.method) {
      this.updateRequireAckSetting(call, result);
    } else if (MethodKey.updateDeliveryAckSetting === call.method) {
      this.updateDeliveryAckSetting(call, result);
    } else if (MethodKey.updateSortMessageByServerTimeSetting === call.method) {
      this.updateSortMessageByServerTimeSetting(call, result);
    } else if (MethodKey.updateMessagesReceiveCallbackIncludeSendSetting === call.method) {
      this.updateMessagesReceiveCallbackIncludeSendSetting(call, result);
    } else if (MethodKey.updateRegradeMessagesSetting === call.method) {
      this.updateRegradeMessagesSetting(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private init(call: MethodCall, result: MethodResult): void {
    if (this.inited) {
      this.onSuccess(result, call.method);
      return;
    }
    try {
      let options = ChatOptionsHelper.fromJson(call.args);
      ChatClient.getInstance().init(this.context, options);
      this.inited = true;
      this.registerEaseListener();
      if (this.onInitSuccessListener !== undefined) {
        this.onInitSuccessListener();
      }
      this.onSuccess(result, call.method);
    } catch (e) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, `init failed: ${JSON.stringify(e)}`);
    }
  }

  private createAccount(call: MethodCall, result: MethodResult): void {
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    let password = SafetyMapTool.getString(call.args, 'password', '') ?? '';
    this.handlePromise(result, call.method, ChatClient.getInstance().createAccount(userId, password),
      () => userId);
  }

  private login(call: MethodCall, result: MethodResult): void {
    let isPassword = SafetyMapTool.getBoolean(call.args, 'isPassword', true) ?? true;
    let userId = SafetyMapTool.getString(call.args, 'userId', '') ?? '';
    let pwdOrToken = SafetyMapTool.getString(call.args, 'pwdOrToken', '') ?? '';
    let promise: Promise<void>;
    if (isPassword) {
      promise = ChatClient.getInstance().login(userId, pwdOrToken);
    } else {
      promise = ChatClient.getInstance().loginWithToken(userId, pwdOrToken);
    }
    this.handlePromise(result, call.method, promise, () => ChatClient.getInstance().getCurrentUser());
  }

  private renewToken(call: MethodCall, result: MethodResult): void {
    let token = SafetyMapTool.getString(call.args, 'agora_token', '') ?? '';
    this.handlePromise(result, call.method, ChatClient.getInstance().renewToken(token));
  }

  private logout(call: MethodCall, result: MethodResult): void {
    let unbindToken = SafetyMapTool.getBoolean(call.args, 'unbindToken', true) ?? true;
    this.handlePromise(result, call.method, ChatClient.getInstance().logout(unbindToken), () => true);
  }

  private changeAppKey(call: MethodCall, result: MethodResult): void {
    let appKey = SafetyMapTool.getString(call.args, 'appKey', '') ?? '';
    // chatsdk changeAppkey is synchronous and only usable while logged out.
    let err: ChatError | null = ChatClient.getInstance().changeAppkey(appKey) as ChatError | null;
    if (err === null || err.errorCode === ChatError.EM_NO_ERROR) {
      this.onSuccess(result, call.method, true);
    } else {
      this.onError(result, err);
    }
  }

  private changeAppId(call: MethodCall, result: MethodResult): void {
    let appId = SafetyMapTool.getString(call.args, 'appId', '') ?? '';
    // Same synchronous contract as changeAppKey.
    let err: ChatError | null = ChatClient.getInstance().changeAppId(appId) as ChatError | null;
    if (err === null || err.errorCode === ChatError.EM_NO_ERROR) {
      this.onSuccess(result, call.method, true);
    } else {
      this.onError(result, err);
    }
  }

  private uploadLog(call: MethodCall, result: MethodResult): void {
    this.handlePromise(result, call.method, ChatClient.getInstance().uploadLog(), () => true);
  }

  private getToken(call: MethodCall, result: MethodResult): void {
    this.onSuccess(result, call.method, ChatClient.getInstance().getAccessToken());
  }

  private getCurrentUser(call: MethodCall, result: MethodResult): void {
    this.onSuccess(result, call.method, ChatClient.getInstance().getCurrentUser());
  }

  private getCurrentDeviceId(call: MethodCall, result: MethodResult): void {
    // Mirrors android: deviceName / resource are always empty; the UUID comes
    // from ChatOptions.getDeviceUuid (android builds it with DeviceUuidFactory).
    let deviceUuid = '';
    let options = ChatClient.getInstance().getOptions();
    if (options !== undefined) {
      deviceUuid = options.getDeviceUuid();
    }
    let deviceInfo = new Map<string, Object>();
    deviceInfo.set('deviceName', '');
    deviceInfo.set('resource', '');
    deviceInfo.set('deviceUUID', deviceUuid);
    this.onSuccess(result, call.method, deviceInfo);
  }

  private isConnected(call: MethodCall, result: MethodResult): void {
    this.onSuccess(result, call.method, ChatClient.getInstance().isConnected());
  }

  // 1.16.0
  private getConnectionState(call: MethodCall, result: MethodResult): void {
    this.onSuccess(result, call.method, ChatClient.getInstance().getConnectionState() as number);
  }

  private startCallback(call: MethodCall, result: MethodResult): void {
    // Flutter framework handshake; no chatsdk counterpart, keep the protocol.
    this.onSuccess(result, call.method);
  }

  private updateUsingHttpsOnlySetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'usingHttpsOnly', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setUsingHttpsOnly(value));
  }

  private updateLoginExtensionInfo(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getString(call.args, 'extension', '') ?? '';
    this.applyOptions(result, call.method, (options) => options.setLoginCustomExt(value));
  }

  private updateDeleteMessagesWhenLeaveGroupSetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'deleteMessagesWhenLeaveGroup', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setDeleteMessagesOnLeaveGroup(value));
  }

  private updateDeleteMessageWhenLeaveRoomSetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'deleteMessageWhenLeaveRoom', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setDeleteMessagesOnLeaveChatroom(value));
  }

  private updateAutoAcceptGroupInvitationSetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'autoAcceptGroupInvitation', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setAutoAcceptGroupInvitations(value));
  }

  private acceptInvitationAlways(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'acceptInvitationAlways', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setAcceptInvitationAlways(value));
  }

  private updateAutoDownloadAttachmentThumbnailSetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'autoDownloadThumbnail', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setAutoDownloadThumbnail(value));
  }

  private updateRequireAckSetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'requireAck', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setRequireReadAck(value));
  }

  private updateDeliveryAckSetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'requireDeliveryAck', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setRequireDeliveryAck(value));
  }

  private updateSortMessageByServerTimeSetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'sortMessageByServerTime', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setSortMessageByServerTime(value));
  }

  private updateMessagesReceiveCallbackIncludeSendSetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'includeSend', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setIncludeSendMessageInMessageListener(value));
  }

  private updateRegradeMessagesSetting(call: MethodCall, result: MethodResult): void {
    let value = SafetyMapTool.getBoolean(call.args, 'isRead', false) ?? false;
    this.applyOptions(result, call.method, (options) => options.setRegardImportedMsgAsRead(value));
  }

  private applyOptions(result: MethodResult, method: string, apply: (options: ChatOptions) => void): void {
    let options = ChatClient.getInstance().getOptions();
    if (options === undefined) {
      this.onErrorInfo(result, ChatError.GENERAL_ERROR, 'ChatOptions unavailable: SDK not initialized');
      return;
    }
    apply(options);
    this.onSuccess(result, method);
  }

  override registerEaseListener(): void {
    if (this.connectionListener !== undefined) {
      ChatClient.getInstance().removeConnectionListener(this.connectionListener);
    }
    this.connectionListener = {
      onConnected: (): void => {
        let data = new Map<string, Object>();
        data.set('connected', true);
        this.emitEvent(MethodKey.onConnected, data);
      },
      onDisconnected: (errorCode: number): void => {
        if (errorCode === ChatError.USER_LOGIN_ANOTHER_DEVICE ||
          errorCode === ChatError.USER_DEVICE_CHANGED) {
          // Delivered through onLogout, same as android.
        } else if (errorCode === ChatError.USER_REMOVED) {
          this.emitEvent(MethodKey.onUserDidRemoveFromServer, null);
        } else if (errorCode === ChatError.SERVER_SERVICE_RESTRICTED) {
          this.emitEvent(MethodKey.onUserDidForbidByServer, null);
        } else if (errorCode === ChatError.USER_KICKED_BY_CHANGE_PASSWORD) {
          this.emitEvent(MethodKey.onUserDidChangePassword, null);
        } else if (errorCode === ChatError.USER_LOGIN_TOO_MANY_DEVICES) {
          this.emitEvent(MethodKey.onUserDidLoginTooManyDevice, null);
        } else if (errorCode === ChatError.USER_KICKED_BY_OTHER_DEVICE) {
          this.emitEvent(MethodKey.onUserKickedByOtherDevice, null);
        } else if (errorCode === ChatError.USER_AUTHENTICATION_FAILED) {
          this.emitEvent(MethodKey.onUserAuthenticationFailed, null);
        } else {
          this.emitEvent(MethodKey.onDisconnected, null);
        }
      },
      onLogout: (errorCode: number, info: LoginExtInfo): void => {
        if (errorCode === ChatError.USER_LOGIN_ANOTHER_DEVICE ||
          errorCode === ChatError.USER_DEVICE_CHANGED) {
          this.emitEvent(
            MethodKey.onUserDidLoginFromOtherDevice,
            LoginExtensionInfoHelper.toJson(info),
          );
        }
      },
      onTokenExpired: (): void => {
        this.emitEvent(MethodKey.onTokenDidExpire, null);
      },
      onTokenWillExpire: (): void => {
        this.emitEvent(MethodKey.onTokenWillExpire, null);
      },
      onOfflineMessageSyncStart: (): void => {
        this.emitEvent(MethodKey.onOfflineMessageSyncStart, null);
      },
      onOfflineMessageSyncFinish: (): void => {
        this.emitEvent(MethodKey.onOfflineMessageSyncFinish, null);
      },
    };
    ChatClient.getInstance().addConnectionListener(this.connectionListener);

    if (this.multiDevicesListener !== undefined) {
      ChatClient.getInstance().removeMultiDevicesListener(this.multiDevicesListener);
    }
    this.multiDevicesListener = {
      onContactEvent: (event: MultiDevicesEvent, target: string, ext: string): void => {
        let data = new Map<string, Object>();
        data.set('event', event as number);
        data.set('target', target);
        data.set('ext', ext);
        this.emitEvent(MethodKey.onMultiDeviceContactEvent, data);
      },
      onGroupEvent: (event: MultiDevicesEvent, target: string, userIds: Array<string>): void => {
        let data = new Map<string, Object>();
        data.set('event', event as number);
        data.set('target', target);
        data.set('userIds', userIds);
        this.emitEvent(MethodKey.onMultiDeviceGroupEvent, data);
      },
      onMessageRemoved: (conversationId: string, deviceId: string): void => {
        let data = new Map<string, Object>();
        data.set('convId', conversationId);
        data.set('deviceId', deviceId);
        this.emitEvent(MethodKey.onMultiDeviceRemoveMessagesEvent, data);
      },
      onConversationEvent: (event: MultiDevicesEvent, conversationId: string,
        type: ConversationType): void => {
        // ConversationType ordinals (Chat=0, GroupChat=1, ChatRoom=2) match the
        // Dart ChatConversationType indexes one to one.
        let data = new Map<string, Object>();
        data.set('event', event as number);
        data.set('convId', conversationId);
        data.set('convType', type as number);
        this.emitEvent(MethodKey.onMultiDevicesConversationEvent, data);
      },
    };
    ChatClient.getInstance().addMultiDevicesListener(this.multiDevicesListener);
  }

  override unRegisterEaseListener(): void {
    if (this.connectionListener !== undefined) {
      ChatClient.getInstance().removeConnectionListener(this.connectionListener);
      this.connectionListener = undefined;
    }
    if (this.multiDevicesListener !== undefined) {
      ChatClient.getInstance().removeMultiDevicesListener(this.multiDevicesListener);
      this.multiDevicesListener = undefined;
    }
  }
}
