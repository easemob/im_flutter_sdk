import { ChatOptions } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
import type { Any } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import { GetSafetyValue, IsObj, ObjToMap } from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/SafetyMapTool&1.0.0";
class ExtSettings {
    static kAppIDForOhOS = "appIDForOhOS";
}
export default class ChatOptionsHelper {
    static fromJson(param: Map<string, Object>): ChatOptions {
        let appKey: string | undefined;
        let appId: string | undefined;
        if (param.has("appKey")) {
            appKey = param.get("appKey") as string;
        }
        else {
            appId = param.get("appId") as string;
        }
        let options = new ChatOptions({ appKey: appKey, appId: appId });
        options.setAutoLogin(GetSafetyValue(param, "autoLogin"));
        options.setRequireReadAck(GetSafetyValue(param, "requireAck"));
        options.setRequireDeliveryAck(GetSafetyValue(param, "requireDeliveryAck"));
        options.setSortMessageByServerTime(GetSafetyValue(param, "sortMessageByServerTime"));
        options.setAcceptInvitationAlways(GetSafetyValue(param, "acceptInvitationAlways"));
        options.setAutoAcceptGroupInvitations(GetSafetyValue(param, "autoAcceptGroupInvitation"));
        options.setDeleteMessagesOnLeaveGroup(GetSafetyValue(param, "deleteMessagesAsExitGroup"));
        options.setDeleteMessagesOnLeaveChatroom(GetSafetyValue(param, "deleteMessagesAsExitChatRoom"));
        options.setAutoDownloadThumbnail(GetSafetyValue(param, "isAutoDownload"));
        options.allowChatroomOwnerLeave(GetSafetyValue(param, "isChatRoomOwnerLeaveAllowed"));
        options.setAutoTransferMessageAttachments(GetSafetyValue(param, "serverTransfer"));
        options.setAreaCode(GetSafetyValue(param, "areaCode"));
        options.setUsingHttpsOnly(GetSafetyValue(param, "usingHttpsOnly"));
        options.setCustomDeviceName(GetSafetyValue(param, "deviceName"));
        options.setCustomOSPlatform(GetSafetyValue(param, "osType"));
        options.setImPort(GetSafetyValue(param, "imPort"));
        options.setIMServer(GetSafetyValue(param, "imServer"));
        options.setRestServer(GetSafetyValue(param, "restServer"));
        options.setDnsURL(GetSafetyValue(param, "dnsUrl"));
        options.setEnableTLSConnection(GetSafetyValue(param, "enableTLS"));
        options.setUseReplacedMessageContents(GetSafetyValue(param, "useReplacedMessageContents"));
        options.setIncludeSendMessageInMessageListener(GetSafetyValue(param, "messagesReceiveCallbackIncludeSend"));
        let extSettings: Any = GetSafetyValue(param, "extSettings");
        if (IsObj(extSettings)) {
            let map = ObjToMap(extSettings);
            if (map.has(ExtSettings.kAppIDForOhOS)) {
                let appId = map.get(ExtSettings.kAppIDForOhOS);
                options.setAppIDForPush(GetSafetyValue(map, ExtSettings.kAppIDForOhOS));
            }
        }
        // TODO
        // options.setAppIDForPush(param.get("dnsUrl") as string);
        // TODO
        // if(typeof param.get("regardImportMessagesAsRead") === 'boolean') {
        // }
        // TODO
        // if(typeof param.get("loginExtensionInfo") === 'string') {
        // }
        return options;
    }
}
