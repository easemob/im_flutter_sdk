import { AreaCode, ChatOptions, ChatLogLevel, SDKPlatform } from '@easemob/chatsdk';
import { Any } from '@ohos/flutter_ohos';
import SafetyMapTool from '../SafetyMapTool';

/**
 * Builds chatsdk ChatOptions from the Dart ChatOptions.toJson() payload.
 *
 * Mirrors android OptionsHelper.fromJson. Push certificate fields (pushConfig,
 * apnsCertName, pushKitCertName, extSettings) have no HarmonyOS counterpart and
 * are intentionally ignored. Fields without a chatsdk counterpart
 * (loadEmptyConversations, workPathCopiable) are ignored as well.
 */
export default class ChatOptionsHelper {
  static fromJson(args: Any): ChatOptions {
    let appKey = SafetyMapTool.getString(args, 'appKey');
    let appId = SafetyMapTool.getString(args, 'appId');
    let options: ChatOptions;
    if (appKey !== undefined && appKey.length > 0) {
      options = new ChatOptions({ appKey: appKey });
    } else if (appId !== undefined && appId.length > 0) {
      options = new ChatOptions({ appId: appId });
    } else {
      options = new ChatOptions({});
    }

    // Marks the embedding platform, mirroring android EMSDKPlatformFlutter.
    options.setSDKPlatform(SDKPlatform.SDK_Platform_Flutter);

    ChatOptionsHelper.applyBoolean(args, 'autoLogin', (v) => options.setAutoLogin(v));
    ChatOptionsHelper.applyBoolean(args, 'requireAck', (v) => options.setRequireReadAck(v));
    ChatOptionsHelper.applyBoolean(args, 'requireDeliveryAck', (v) => options.setRequireDeliveryAck(v));
    ChatOptionsHelper.applyBoolean(args, 'sortMessageByServerTime', (v) => options.setSortMessageByServerTime(v));
    ChatOptionsHelper.applyBoolean(args, 'acceptInvitationAlways', (v) => options.setAcceptInvitationAlways(v));
    ChatOptionsHelper.applyBoolean(args, 'autoAcceptGroupInvitation', (v) => options.setAutoAcceptGroupInvitations(v));
    ChatOptionsHelper.applyBoolean(args, 'deleteMessagesAsExitGroup', (v) => options.setDeleteMessagesOnLeaveGroup(v));
    ChatOptionsHelper.applyBoolean(args, 'deleteMessagesAsExitChatRoom', (v) => options.setDeleteMessagesOnLeaveChatroom(v));
    ChatOptionsHelper.applyBoolean(args, 'isAutoDownload', (v) => options.setAutoDownloadThumbnail(v));
    ChatOptionsHelper.applyBoolean(args, 'isChatRoomOwnerLeaveAllowed', (v) => options.allowChatroomOwnerLeave(v));
    ChatOptionsHelper.applyBoolean(args, 'serverTransfer', (v) => options.setAutoTransferMessageAttachments(v));
    ChatOptionsHelper.applyBoolean(args, 'usingHttpsOnly', (v) => options.setUsingHttpsOnly(v));
    ChatOptionsHelper.applyBoolean(args, 'enableUserInfo', (v) => options.setEnableUserInfo(v));
    ChatOptionsHelper.applyBoolean(args, 'enableAutoSyncContacts', (v) => options.setEnableAutoSyncContacts(v));
    ChatOptionsHelper.applyBoolean(args, 'enableChatroomConversation', (v) => options.setEnableChatroomConversation(v));
    ChatOptionsHelper.applyBoolean(args, 'autoLoadConversations', (v) => options.setAutoLoadAllConversations(v));
    // 1.16.0
    ChatOptionsHelper.applyNumber(args, 'disconnectNotifyThreshold', (v) => options.setDisconnectNotifyThreshold(v));
    ChatOptionsHelper.applyBoolean(args, 'usePushInBackground', (v) => options.setUsePushInBackground(v));
    ChatOptionsHelper.applyBoolean(args, 'enableTLS', (v) => options.setEnableTLSConnection(v));
    ChatOptionsHelper.applyBoolean(args, 'useReplacedMessageContents', (v) => options.setUseReplacedMessageContents(v));
    ChatOptionsHelper.applyBoolean(args, 'messagesReceiveCallbackIncludeSend',
      (v) => options.setIncludeSendMessageInMessageListener(v));
    ChatOptionsHelper.applyBoolean(args, 'regardImportMessagesAsRead', (v) => options.setRegardImportedMsgAsRead(v));

    ChatOptionsHelper.applyString(args, 'deviceName', (v) => options.setCustomDeviceName(v));
    ChatOptionsHelper.applyString(args, 'loginExtensionInfo', (v) => options.setLoginCustomExt(v));
    ChatOptionsHelper.applyNumber(args, 'osType', (v) => options.setCustomOSPlatform(v));
    ChatOptionsHelper.applyNumber(args, 'areaCode', (v) => options.setAreaCode(v as AreaCode));

    let ntpServers = SafetyMapTool.getStringArray(args, 'ntpServers');
    if (ntpServers !== undefined && ntpServers.length > 0) {
      options.setNtpServers(ntpServers);
    }

    // Custom server addresses only take effect when the DNS config is disabled,
    // same as android.
    let enableDNSConfig = SafetyMapTool.getBoolean(args, 'enableDNSConfig', true);
    options.setEnableDnsConfig(enableDNSConfig ?? true);
    if (!(enableDNSConfig ?? true)) {
      ChatOptionsHelper.applyString(args, 'imServer', (v) => options.setIMServer(v));
      ChatOptionsHelper.applyNumber(args, 'imPort', (v) => options.setImPort(v));
      ChatOptionsHelper.applyString(args, 'webSocketServer', (v) => options.setWebSocketServer(v));
      ChatOptionsHelper.applyNumber(args, 'webSocketPort', (v) => options.setWebSocketPort(v));
      ChatOptionsHelper.applyString(args, 'restServer', (v) => options.setRestServer(v));
      ChatOptionsHelper.applyString(args, 'dnsUrl', (v) => options.setDnsURL(v));
    }

    // chatsdk has no debug-mode switch; the closest equivalent is the log level.
    let debugModel = SafetyMapTool.getBoolean(args, 'debugModel', false);
    if (debugModel ?? false) {
      options.setLogLevel(ChatLogLevel.DEBUG_LEVEL);
    }

    return options;
  }

  private static applyBoolean(args: Any, key: string, apply: (value: boolean) => void): void {
    let value = SafetyMapTool.getBoolean(args, key);
    if (value !== undefined) {
      apply(value);
    }
  }

  private static applyString(args: Any, key: string, apply: (value: string) => void): void {
    let value = SafetyMapTool.getString(args, key);
    if (value !== undefined) {
      apply(value);
    }
  }

  private static applyNumber(args: Any, key: string, apply: (value: number) => void): void {
    let value = SafetyMapTool.getNumber(args, key);
    if (value !== undefined) {
      apply(value);
    }
  }
}
