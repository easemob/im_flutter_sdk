import { ChatClient } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { ChatError, ConnectionListener, MultiDevicesListener } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { FlutterPluginBinding, MethodCall, MethodResult } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import ChatManagerWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/ChatManagerWrapper&1.0.0";
import ChatRoomManagerWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/ChatRoomManagerWrapper&1.0.0";
import ChatThreadManagerWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/ChatThreadManagerWrapper&1.0.0";
import ContactManagerWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/ContactManagerWrapper&1.0.0";
import ConversationWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/ConversationWrapper&1.0.0";
import GroupManagerWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/GroupManagerWrapper&1.0.0";
import MessageWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/MessageWrapper&1.0.0";
import MethodKey from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/MethodKeys&1.0.0";
import ChatOptionsHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/ChatOptionsHelper&1.0.0";
import PresenceManagerWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/PresenceManagerWrapper&1.0.0";
import ProgressManager from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/ProgressManager&1.0.0";
import PushManagerWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/PushManagerWrapper&1.0.0";
import UserInfoManagerWrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/UserInfoManagerWrapper&1.0.0";
import Wrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/Wrapper&1.0.0";
import LoginExtensionInfoHelper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/models/LoginExtensionInfoHelper&1.0.0";
export default class ClientWrapper extends Wrapper {
    private chatManager: ChatManagerWrapper | undefined;
    private groupManager: GroupManagerWrapper | undefined;
    private roomManager: ChatRoomManagerWrapper | undefined;
    private pushManager: PushManagerWrapper | undefined;
    private presenceManager: PresenceManagerWrapper | undefined;
    private threadManager: ChatThreadManagerWrapper | undefined;
    private contactManager: ContactManagerWrapper | undefined;
    private userInfoManager: UserInfoManagerWrapper | undefined;
    private conversationManager: ConversationWrapper | undefined;
    private messageWrapper: MessageWrapper | undefined;
    public progressManager: ProgressManager | undefined;
    private multiDeviceListener: MultiDevicesListener | undefined;
    private connectionListener: ConnectionListener | undefined;
    constructor(binding: FlutterPluginBinding, channelName: string) {
        super(binding, channelName);
    }
    public sendDataToFlutter(data: Map<string, Object>) {
        if (data != null) {
            this.channel?.invokeMethod(MethodKey.onSendDataToFlutter, data);
        }
    }
    bindingManagers() {
        this.chatManager = new ChatManagerWrapper(this.binding!, "chat_manager");
        this.contactManager = new ContactManagerWrapper(this.binding!, "chat_contact_manager");
        this.roomManager = new ChatRoomManagerWrapper(this.binding!, "chat_room_manager");
        this.groupManager = new GroupManagerWrapper(this.binding!, "chat_group_manager");
        this.groupManager.clientWrapper = this;
        this.conversationManager = new ConversationWrapper(this.binding!, "chat_conversation");
        this.pushManager = new PushManagerWrapper(this.binding!, "chat_push_manager");
        this.userInfoManager = new UserInfoManagerWrapper(this.binding!, "chat_userInfo_manager");
        this.presenceManager = new PresenceManagerWrapper(this.binding!, "chat_presence_manager");
        this.messageWrapper = new MessageWrapper(this.binding!, "chat_message");
        this.threadManager = new ChatThreadManagerWrapper(this.binding!, "chat_thread_manager");
        this.progressManager = new ProgressManager(this.binding!, "file_progress_manager");
    }
    public unRegisterEaseListener() {
        this.chatManager?.unRegisterEaseListener();
        this.contactManager?.unRegisterEaseListener();
        this.roomManager?.unRegisterEaseListener();
        this.groupManager?.unRegisterEaseListener();
        if (this.groupManager != null) {
            this.groupManager!.clientWrapper = null;
        }
        this.conversationManager?.unRegisterEaseListener();
        this.pushManager?.unRegisterEaseListener();
        this.userInfoManager?.unRegisterEaseListener();
        this.presenceManager?.unRegisterEaseListener();
        this.messageWrapper?.unRegisterEaseListener();
        this.threadManager?.unRegisterEaseListener();
        this.progressManager?.unRegisterEaseListener();
        ChatClient.getInstance().removeMultiDevicesListener(this.multiDeviceListener);
        ChatClient.getInstance().removeConnectionListener(this.connectionListener);
    }
    registerEaseListener() {
        let weakRef = new WeakRef(this);
        if (this.multiDeviceListener != null) {
            ChatClient.getInstance().removeMultiDevicesListener(this.multiDeviceListener);
        }
        this.multiDeviceListener = {
            onContactEvent(event, target, ext): void {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("event", event);
                data.set("target", target);
                data.set("ext", ext);
                retrievedObject?.channel?.invokeMethod(MethodKey.onMultiDeviceContactEvent, data);
            },
            onGroupEvent(event, target, userIds) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("event", event);
                data.set("target", target);
                data.set("users", userIds);
                retrievedObject?.channel?.invokeMethod(MethodKey.onMultiDeviceGroupEvent, data);
            },
            onMessageRemoved(conversationId, deviceId) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("convId", conversationId);
                data.set("deviceId", deviceId);
                retrievedObject?.channel?.invokeMethod(MethodKey.onMultiDeviceRemoveMessagesEvent, data);
            },
            onConversationEvent(event, conversationId, type) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("event", event);
                data.set("convId", conversationId);
                data.set("type", type);
                retrievedObject?.channel?.invokeMethod(MethodKey.onMultiDevicesConversationEvent, data);
            }
        };
        ChatClient.getInstance().addMultiDevicesListener(this.multiDeviceListener);
        if (this.connectionListener != null) {
            ChatClient.getInstance().removeConnectionListener(this.connectionListener);
        }
        this.connectionListener = {
            onConnected() {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                data.set("connected", true);
                retrievedObject?.channel?.invokeMethod(MethodKey.onConnected, data);
            },
            onDisconnected(errCode) {
                let retrievedObject = weakRef.deref();
                let data = new Map<string, Object>();
                if (errCode == 206) {
                    // 这部分实现放到onLogout中。
                }
                else if (errCode == 207) {
                    retrievedObject?.channel?.invokeMethod(MethodKey.onConnected, data);
                }
                else if (errCode == 305) {
                    retrievedObject?.channel?.invokeMethod(MethodKey.onUserDidForbidByServer, data);
                }
                else if (errCode == 216) {
                    retrievedObject?.channel?.invokeMethod(MethodKey.onUserDidChangePassword, data);
                }
                else if (errCode == 214) {
                    retrievedObject?.channel?.invokeMethod(MethodKey.onUserDidLoginTooManyDevice, data);
                }
                else if (errCode == 217) {
                    retrievedObject?.channel?.invokeMethod(MethodKey.onUserKickedByOtherDevice, data);
                }
                else if (errCode == 202) {
                    retrievedObject?.channel?.invokeMethod(MethodKey.onUserAuthenticationFailed, data);
                }
                else if (errCode == 8) {
                    retrievedObject?.channel?.invokeMethod(MethodKey.onAppActiveNumberReachLimit, data);
                }
                else {
                    retrievedObject?.channel?.invokeMethod(MethodKey.onDisconnected, data);
                }
            },
            onTokenExpired() {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onTokenDidExpire, null);
            },
            onTokenWillExpire() {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onTokenWillExpire, null);
            },
            onLogout(errorCode, loginInfo) {
                let retrievedObject = weakRef.deref();
                if (errorCode == 206) {
                    retrievedObject?.channel?.invokeMethod(MethodKey.onTokenWillExpire, LoginExtensionInfoHelper.toJson(loginInfo));
                }
            },
            onOfflineMessageSyncStart() {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onOfflineMessageSyncStart, null);
            },
            onOfflineMessageSyncFinish() {
                let retrievedObject = weakRef.deref();
                retrievedObject?.channel?.invokeMethod(MethodKey.onOfflineMessageSyncFinish, null);
            }
        };
        ChatClient.getInstance().addConnectionListener(this.connectionListener);
    }
    onMethodCall(call: MethodCall, result: MethodResult): void {
        if (MethodKey.init == call.method) {
            this.init(call, result);
        }
        else if (MethodKey.createAccount == call.method) {
            this.createAccount(call, result);
        }
        else if (MethodKey.login == call.method) {
            this.login(call, result);
        }
        else if (MethodKey.logout == call.method) {
            this.logout(call, result);
        }
        else if (MethodKey.changeAppKey == call.method) {
            this.changeAppKey(call, result);
        }
        else if (MethodKey.uploadLog == call.method) {
            this.uploadLog(call, result);
        }
        else if (MethodKey.compressLogs == call.method) {
            this.compressLogs(call, result);
        }
        else if (MethodKey.getLoggedInDevicesFromServer == call.method) {
            this.getLoggedInDevicesFromServer(call, result);
        }
        else if (MethodKey.kickDevice == call.method) {
            this.kickDevice(call, result);
        }
        else if (MethodKey.kickAllDevices == call.method) {
            this.kickAllDevices(call, result);
        }
        else if (MethodKey.isLoggedInBefore == call.method) {
            this.isLoggedInBefore(call, result);
        }
        else if (MethodKey.getCurrentUser == call.method) {
            this.getCurrentUser(call, result);
        }
        else if (MethodKey.loginWithAgoraToken == call.method) {
            this.loginWithAgoraToken(call, result);
        }
        else if (MethodKey.getToken == call.method) {
            this.getToken(call, result);
        }
        else if (MethodKey.isConnected == call.method) {
            this.isConnected(call, result);
        }
        else if (MethodKey.renewToken == call.method) {
            this.renewToken(call, result);
        }
        else if (MethodKey.startCallback == call.method) {
            this.startCallback(call, result);
        }
        else if (MethodKey.updateUsingHttpsOnlySetting == call.method) {
            this.updateUsingHttpsOnlySetting(call, result);
        }
        else if (MethodKey.updateLoginExtensionInfo == call.method) {
            this.updateLoginExtensionInfo(call, result);
        }
        else if (MethodKey.updateDeleteMessagesWhenLeaveGroupSetting == call.method) {
            this.updateDeleteMessagesWhenLeaveGroupSetting(call, result);
        }
        else if (MethodKey.updateDeleteMessageWhenLeaveRoomSetting == call.method) {
            this.updateDeleteMessageWhenLeaveRoomSetting(call, result);
        }
        else if (MethodKey.updateRoomOwnerCanLeaveSetting == call.method) {
            this.updateRoomOwnerCanLeaveSetting(call, result);
        }
        else if (MethodKey.updateAutoAcceptGroupInvitationSetting == call.method) {
            this.updateAutoAcceptGroupInvitationSetting(call, result);
        }
        else if (MethodKey.acceptInvitationAlways == call.method) {
            this.acceptInvitationAlways(call, result);
        }
        else if (MethodKey.updateAutoDownloadAttachmentThumbnailSetting == call.method) {
            this.updateAutoDownloadAttachmentThumbnailSetting(call, result);
        }
        else if (MethodKey.updateRequireAckSetting == call.method) {
            this.updateRequireAckSetting(call, result);
        }
        else if (MethodKey.updateDeliveryAckSetting == call.method) {
            this.updateDeliveryAckSetting(call, result);
        }
        else if (MethodKey.updateSortMessageByServerTimeSetting == call.method) {
            this.updateSortMessageByServerTimeSetting(call, result);
        }
        else if (MethodKey.updateMessagesReceiveCallbackIncludeSendSetting == call.method) {
            this.updateMessagesReceiveCallbackIncludeSendSetting(call, result);
        }
        else if (MethodKey.updateRegradeMessagesSetting == call.method) {
            this.updateRegradeMessagesSetting(call, result);
        }
        else if (MethodKey.changeAppId == call.method) {
            this.changeAppId(call, result);
        }
        else {
            super.onMethodCall(call, result);
        }
    }
    private init(call: MethodCall, result: MethodResult) {
        let options = ChatOptionsHelper.fromJson(call.args as Map<string, Object>);
        ChatClient.getInstance().init(this.context, options);
        this.bindingManagers();
        this.registerEaseListener();
        this.onSuccess(result, call.method);
    }
    private createAccount(call: MethodCall, result: MethodResult) {
        let userId = call.argument("username") as string;
        let password = call.argument("password") as string;
        ChatClient.getInstance().createAccount(userId, password)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private login(call: MethodCall, result: MethodResult) {
        let isPwd = call.argument("isPassword") as boolean;
        let userId = call.argument("username") as string;
        let pwdOrToken = call.argument("pwdOrToken") as string;
        if (isPwd) {
            ChatClient.getInstance().login(userId, pwdOrToken)
                .then(() => this.onSuccess(result, call.method))
                .catch((e: ChatError) => this.onError(result, e));
        }
        else {
            ChatClient.getInstance().loginWithToken(userId, pwdOrToken)
                .then(() => this.onSuccess(result, call.method))
                .catch((e: ChatError) => this.onError(result, e));
        }
    }
    private logout(call: MethodCall, result: MethodResult) {
        let unbindToken = call.argument("unbindToken") as boolean;
        ChatClient.getInstance().logout(unbindToken)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private changeAppKey(call: MethodCall, result: MethodResult) {
        let appKey = call.argument("appKey") as string;
        let chatError = ChatClient.getInstance().changeAppkey(appKey);
        if (chatError == null) {
            this.onSuccess(result, call.method);
        }
        else {
            this.onError(result, chatError);
        }
    }
    private uploadLog(call: MethodCall, result: MethodResult) {
        ChatClient.getInstance().uploadLog()
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private compressLogs(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private getLoggedInDevicesFromServer(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private kickDevice(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private kickAllDevices(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private isLoggedInBefore(call: MethodCall, result: MethodResult) {
        let options = ChatClient.getInstance().getOptions();
        this.onSuccess(result, call.method, ChatClient.getInstance().isLoggedIn() && options?.isAutoLogin());
    }
    private getCurrentUser(call: MethodCall, result: MethodResult) {
        this.onSuccess(result, call.method, ChatClient.getInstance().getCurrentUser());
    }
    private loginWithAgoraToken(call: MethodCall, result: MethodResult) {
        let username = call.argument("username") as string;
        let agoraToken = call.argument("agora_token") as string;
        ChatClient.getInstance().loginWithToken(username, agoraToken)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private getToken(call: MethodCall, result: MethodResult) {
        let token = ChatClient.getInstance().getAccessToken();
        this.onSuccess(result, call.method, token);
    }
    private isConnected(call: MethodCall, result: MethodResult) {
        this.onSuccess(result, call.method, ChatClient.getInstance().isConnected());
    }
    private renewToken(call: MethodCall, result: MethodResult) {
        let token = call.argument("agora_token") as string;
        ChatClient.getInstance().renewToken(token)
            .then(() => this.onSuccess(result, call.method))
            .catch((e: ChatError) => this.onError(result, e));
    }
    private startCallback(call: MethodCall, result: MethodResult) {
        this.onSuccess(result, call.method);
    }
    private updateUsingHttpsOnlySetting(call: MethodCall, result: MethodResult) {
        let usingHttpsOnly = call.argument("usingHttpsOnly") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setUsingHttpsOnly(usingHttpsOnly);
        this.onSuccess(result, call.method);
    }
    private updateLoginExtensionInfo(call: MethodCall, result: MethodResult) {
        let extension = call.argument("extension") as string;
        let options = ChatClient.getInstance().getOptions();
        options?.setLoginCustomExt(extension);
        this.onSuccess(result, call.method);
    }
    private updateDeleteMessagesWhenLeaveGroupSetting(call: MethodCall, result: MethodResult) {
        let deleteMessagesWhenLeaveGroup = call.argument("deleteMessagesWhenLeaveGroup") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setDeleteMessagesOnLeaveGroup(deleteMessagesWhenLeaveGroup);
        this.onSuccess(result, call.method);
    }
    private updateDeleteMessageWhenLeaveRoomSetting(call: MethodCall, result: MethodResult) {
        let deleteMessageWhenLeaveRoom = call.argument("deleteMessageWhenLeaveRoom") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setDeleteMessagesOnLeaveChatroom(deleteMessageWhenLeaveRoom);
        this.onSuccess(result, call.method);
    }
    private updateRoomOwnerCanLeaveSetting(call: MethodCall, result: MethodResult) {
        let roomOwnerCanLeave = call.argument("roomOwnerCanLeave") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.allowChatroomOwnerLeave(roomOwnerCanLeave);
        this.onSuccess(result, call.method);
    }
    private updateAutoAcceptGroupInvitationSetting(call: MethodCall, result: MethodResult) {
        let autoAcceptGroupInvitation = call.argument("autoAcceptGroupInvitation") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setAutoAcceptGroupInvitations(autoAcceptGroupInvitation);
        this.onSuccess(result, call.method);
    }
    private acceptInvitationAlways(call: MethodCall, result: MethodResult) {
        let acceptInvitationAlways = call.argument("acceptInvitationAlways") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setAcceptInvitationAlways(acceptInvitationAlways);
        this.onSuccess(result, call.method);
    }
    private updateAutoDownloadAttachmentThumbnailSetting(call: MethodCall, result: MethodResult) {
        let autoDownloadThumbnail = call.argument("autoDownloadThumbnail") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setAutoDownloadThumbnail(autoDownloadThumbnail);
        this.onSuccess(result, call.method);
    }
    private updateRequireAckSetting(call: MethodCall, result: MethodResult) {
        let requireAck = call.argument("requireAck") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setRequireReadAck(requireAck);
        this.onSuccess(result, call.method);
    }
    private updateDeliveryAckSetting(call: MethodCall, result: MethodResult) {
        let requireDeliveryAck = call.argument("requireDeliveryAck") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setRequireDeliveryAck(requireDeliveryAck);
        this.onSuccess(result, call.method);
    }
    private updateSortMessageByServerTimeSetting(call: MethodCall, result: MethodResult) {
        let sortMessageByServerTime = call.argument("sortMessageByServerTime") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setSortMessageByServerTime(sortMessageByServerTime);
        this.onSuccess(result, call.method);
    }
    private updateMessagesReceiveCallbackIncludeSendSetting(call: MethodCall, result: MethodResult) {
        let includeSend = call.argument("includeSend") as boolean;
        let options = ChatClient.getInstance().getOptions();
        options?.setIncludeSendMessageInMessageListener(includeSend);
        this.onSuccess(result, call.method);
    }
    private updateRegradeMessagesSetting(_: MethodCall, result: MethodResult) {
        this.noSupport(result);
    }
    private changeAppId(call: MethodCall, result: MethodResult) {
        let appId = call.argument("appId") as string;
        let err = ChatClient.getInstance().changeAppId(appId);
        if (err == null) {
            this.onSuccess(result, call.method);
        }
        else {
            this.onError(result, err);
        }
    }
}
