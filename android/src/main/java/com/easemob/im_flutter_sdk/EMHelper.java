package com.easemob.im_flutter_sdk;

import static com.hyphenate.chat.EMOptions.AreaCode.AREA_CODE_GLOB;

import android.content.Context;

import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMChatThreadEvent;
import com.hyphenate.chat.EMCmdMessageBody;
import com.hyphenate.chat.EMCombineMessageBody;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMCustomMessageBody;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.chat.EMFetchMessageOption;
import com.hyphenate.chat.EMFileMessageBody;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupInfo;
import com.hyphenate.chat.EMGroupManager;
import com.hyphenate.chat.EMGroupOptions;
import com.hyphenate.chat.EMGroupReadAck;
import com.hyphenate.chat.EMImageMessageBody;
import com.hyphenate.chat.EMLanguage;
import com.hyphenate.chat.EMLocationMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessage.Type;
import com.hyphenate.chat.EMMessageBody;
import com.hyphenate.chat.EMMessageReaction;
import com.hyphenate.chat.EMMessageReactionChange;
import com.hyphenate.chat.EMMessageReactionOperation;
import com.hyphenate.chat.EMMucSharedFile;
import com.hyphenate.chat.EMNormalFileMessageBody;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMPageResult;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.chat.EMPushConfigs;
import com.hyphenate.chat.EMPushManager;
import com.hyphenate.chat.EMSilentModeParam;
import com.hyphenate.chat.EMSilentModeResult;
import com.hyphenate.chat.EMSilentModeTime;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMVideoMessageBody;
import com.hyphenate.chat.EMVoiceMessageBody;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.push.EMPushConfig;
import com.hyphenate.chat.EMUserInfo;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

class EMOptionsHelper {

    static EMOptions fromJson(JSONObject json, Context context) throws JSONException {
        EMOptions options = new EMOptions();
        options.setAppKey(json.getString("appKey"));
        options.setAutoLogin(json.getBoolean("autoLogin"));
        options.setRequireAck(json.getBoolean("requireAck"));
        options.setRequireDeliveryAck(json.getBoolean("requireDeliveryAck"));
        options.setSortMessageByServerTime(json.getBoolean("sortMessageByServerTime"));
        options.setAcceptInvitationAlways(json.getBoolean("acceptInvitationAlways"));
        options.setAutoAcceptGroupInvitation(json.getBoolean("autoAcceptGroupInvitation"));
        options.setDeleteMessagesAsExitGroup(json.getBoolean("deleteMessagesAsExitGroup"));
        options.setDeleteMessagesAsExitChatRoom(json.getBoolean("deleteMessagesAsExitChatRoom"));
        options.setAutoDownloadThumbnail(json.getBoolean("isAutoDownload"));
        options.allowChatroomOwnerLeave(json.getBoolean("isChatRoomOwnerLeaveAllowed"));
        options.setAutoTransferMessageAttachments(json.getBoolean("serverTransfer"));
        options.setAreaCode(json.getInt("areaCode"));
        options.setUsingHttpsOnly(json.getBoolean("usingHttpsOnly"));
        options.enableDNSConfig(json.getBoolean("enableDNSConfig"));
        options.setLoadEmptyConversations(json.optBoolean("loadEmptyConversations", false));
        if (json.has("deviceName")) {
            options.setCustomDeviceName(json.optString("deviceName"));
        }
        if (json.has("osType")) {
            options.setCustomOSPlatform(json.optInt("osType"));
        }
        if (!json.getBoolean("enableDNSConfig")) {
            if (json.has("imPort")) {
                options.setImPort(json.getInt("imPort"));
            }
            if (json.has("imServer")) {
                options.setIMServer(json.getString("imServer"));
            }
            if (json.has("restServer")) {
                options.setRestServer(json.getString("restServer"));
            }
            if (json.has("dnsUrl")){
                options.setDnsUrl(json.getString("dnsUrl"));
            }
        }

        if (json.has("pushConfig")) {
            EMPushConfig.Builder builder = new EMPushConfig.Builder(context);
            JSONObject pushConfig = json.getJSONObject("pushConfig");
            if (pushConfig.getBoolean("enableMiPush")) {
                builder.enableMiPush(pushConfig.getString("miAppId"), pushConfig.getString("miAppKey"));
            }
            if (pushConfig.getBoolean("enableFCM")) {
                builder.enableFCM(pushConfig.getString("fcmId"));
            }
            if (pushConfig.getBoolean("enableOppoPush")) {
                builder.enableOppoPush(pushConfig.getString("oppoAppKey"), pushConfig.getString("oppoAppSecret"));
            }
            if (pushConfig.getBoolean("enableHWPush")) {
                builder.enableHWPush();
            }
            if (pushConfig.getBoolean("enableMeiZuPush")) {
                builder.enableMeiZuPush(pushConfig.getString("mzAppId"), pushConfig.getString("mzAppKey"));
            }
            if (pushConfig.getBoolean("enableVivoPush")) {
                builder.enableVivoPush();
            }
            options.setPushConfig(builder.build());
        }
        return options;

    }

    /*
    static Map<String, Object> toJson(EMOptions options) {
        Map<String, Object> data = new HashMap<>();
        data.put("appKey", options.getAppKey());
        data.put("autoLogin", options.getAutoLogin());
        data.put("requireAck", options.getRequireAck());
        data.put("requireDeliveryAck", options.getRequireDeliveryAck());
        data.put("sortMessageByServerTime", options.isSortMessageByServerTime());
        data.put("acceptInvitationAlways", options.getAcceptInvitationAlways());
        data.put("autoAcceptGroupInvitation", options.isAutoAcceptGroupInvitation());
        data.put("deleteMessagesAsExitGroup", options.isDeleteMessagesAsExitGroup());
        data.put("deleteMessagesAsExitChatRoom", options.isDeleteMessagesAsExitChatRoom());
        data.put("isAutoDownload", options.getAutodownloadThumbnail());
        data.put("isChatRoomOwnerLeaveAllowed", options.isChatroomOwnerLeaveAllowed());
        // data.put("serverTransfer", "");
        // data.put("debugModel", options.);
        // data.put("serverTransfer", options.);
        data.put("usingHttpsOnly", options.getUsingHttpsOnly());
        // data.put("EMPushConfig", "");
        // data.put("enableDNSConfig", "");
        data.put("imPort", options.getImPort());
        data.put("imServer", options.getImServer());
        data.put("restServer", options.getRestServer());
        data.put("dnsUrl", options.getDnsUrl());

        return data;
    }
     */
}


class EMGroupHelper {
    static Map<String, Object> toJson(EMGroup group) {
        Map<String, Object> data = new HashMap<>();
        EMCommonUtil.putObjectToMap(data, "groupId", group.getGroupId());
        EMCommonUtil.putObjectToMap(data, "name", group.getGroupName());
        EMCommonUtil.putObjectToMap(data, "desc", group.getDescription());
        EMCommonUtil.putObjectToMap(data, "owner", group.getOwner());
        EMCommonUtil.putObjectToMap(data, "announcement", group.getAnnouncement());
        EMCommonUtil.putObjectToMap(data, "memberCount", group.getMemberCount());
        EMCommonUtil.putObjectToMap(data, "memberList", group.getMembers());
        EMCommonUtil.putObjectToMap(data, "adminList", group.getAdminList());
        EMCommonUtil.putObjectToMap(data, "blockList", group.getBlackList());
        EMCommonUtil.putObjectToMap(data, "muteList", group.getMuteList());
        EMCommonUtil.putObjectToMap(data, "messageBlocked", group.isMsgBlocked());
        EMCommonUtil.putObjectToMap(data, "isDisabled", group.isDisabled());
        EMCommonUtil.putObjectToMap(data, "isAllMemberMuted", group.isAllMemberMuted());
        EMCommonUtil.putObjectToMap(data, "permissionType", intTypeFromGroupPermissionType(group.getGroupPermissionType()));
        EMCommonUtil.putObjectToMap(data, "maxUserCount", group.getMemberCount());
        EMCommonUtil.putObjectToMap(data, "isMemberOnly", group.isMemberOnly());
        EMCommonUtil.putObjectToMap(data, "isMemberAllowToInvite", group.isMemberAllowToInvite());
        EMCommonUtil.putObjectToMap(data, "ext", group.getExtension());
        return data;
    }

    static int intTypeFromGroupPermissionType(EMGroup.EMGroupPermissionType type) {
        int ret = -1;
        switch (type) {
        case none: {
            ret = -1;
        }
            break;
        case member: {
            ret = 0;
        }
            break;
        case admin: {
            ret = 1;
        }
            break;
        case owner: {
            ret = 2;
        }
            break;
        }
        return ret;
    }
}

class EMGroupInfoHelper {
    static Map<String, Object> toJson(EMGroupInfo group) {
        Map<String, Object> data = new HashMap<>();
        data.put("groupId", group.getGroupId());
        data.put("name", group.getGroupName());
        return data;
    }
}

class EMMucSharedFileHelper {
    static Map<String, Object> toJson(EMMucSharedFile file) {
        Map<String, Object> data = new HashMap<>();
        data.put("fileId", file.getFileId());
        data.put("name", file.getFileName());
        data.put("owner", file.getFileOwner());
        data.put("createTime", file.getFileUpdateTime());
        data.put("fileSize", file.getFileSize());

        return data;
    }
}

class EMGroupOptionsHelper {

    static EMGroupOptions fromJson(JSONObject json) throws JSONException {
        EMGroupOptions options = new EMGroupOptions();
        options.maxUsers = json.getInt("maxCount");
        options.inviteNeedConfirm = json.getBoolean("inviteNeedConfirm");
        if (json.has("ext")){
            options.extField = json.getString("ext");
        }
        options.style = styleFromInt(json.getInt("style"));
        return options;
    }

    static Map<String, Object> toJson(EMGroupOptions options) {
        Map<String, Object> data = new HashMap<>();
        data.put("maxCount", options.maxUsers);
        data.put("inviteNeedConfirm", options.inviteNeedConfirm);
        data.put("ext", options.extField);
        data.put("style", styleToInt(options.style));
        return data;
    }

    private static EMGroupManager.EMGroupStyle styleFromInt(int style) {
        switch (style) {
        case 0:
            return EMGroupManager.EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite;
        case 1:
            return EMGroupManager.EMGroupStyle.EMGroupStylePrivateMemberCanInvite;
        case 2:
            return EMGroupManager.EMGroupStyle.EMGroupStylePublicJoinNeedApproval;
        case 3:
            return EMGroupManager.EMGroupStyle.EMGroupStylePublicOpenJoin;
        }

        return EMGroupManager.EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite;
    }

    private static int styleToInt(EMGroupManager.EMGroupStyle style) {
        switch (style) {
        case EMGroupStylePrivateOnlyOwnerInvite:
            return 0;
        case EMGroupStylePrivateMemberCanInvite:
            return 1;
        case EMGroupStylePublicJoinNeedApproval:
            return 2;
        case EMGroupStylePublicOpenJoin:
            return 3;
        }

        return 0;
    }
}

class EMChatRoomHelper {

    // chatroom 都是native -> flutter, 不需要fromJson
    // static EMChatRoom fromJson(JSONObject json) throws JSONException {
    // EMChatRoom chatRoom = new EMChatRoom();
    // }

    static Map<String, Object> toJson(EMChatRoom chatRoom) {
        Map<String, Object> data = new HashMap<>();
        data.put("roomId", chatRoom.getId());
        data.put("name", chatRoom.getName());
        data.put("desc", chatRoom.getDescription());
        data.put("owner", chatRoom.getOwner());
        data.put("maxUsers", chatRoom.getMaxUsers());
        data.put("memberCount", chatRoom.getMemberCount());
        data.put("adminList", chatRoom.getAdminList());
        data.put("memberList", chatRoom.getMemberList());
        data.put("blockList", chatRoom.getBlacklist());
        data.put("muteList", chatRoom.getMuteList().keySet().toArray());
        data.put("isAllMemberMuted", chatRoom.isAllMemberMuted());
        data.put("announcement", chatRoom.getAnnouncement());
        data.put("permissionType", intTypeFromPermissionType(chatRoom.getChatRoomPermissionType()));

        return data;
    }

    static int intTypeFromPermissionType(EMChatRoom.EMChatRoomPermissionType type) {
        int ret = -1;
        switch (type) {
        case none: {
            ret = -1;
        }
            break;
        case member: {
            ret = 0;
        }
            break;
        case admin: {
            ret = 1;
        }
            break;
        case owner: {
            ret = 2;
        }
            break;
        default:
            break;
        }
        return ret;
    }
}

class EMMessageHelper {

    static EMMessage fromJson(JSONObject json) throws JSONException {
        EMMessage message = null;

        JSONObject bodyJson = json.getJSONObject("body");
        String type = bodyJson.getString("type");
        if (json.getString("direction").equals("send")) {
            switch (type) {
                case "txt": {
                    message = EMMessage.createSendMessage(Type.TXT);
                    message.addBody(EMMessageBodyHelper.textBodyFromJson(bodyJson));
                }
                    break;
                case "img": {
                    message = EMMessage.createSendMessage(Type.IMAGE);
                    message.addBody(EMMessageBodyHelper.imageBodyFromJson(bodyJson));
                }
                    break;
                case "loc": {
                    message = EMMessage.createSendMessage(Type.LOCATION);
                    message.addBody(EMMessageBodyHelper.localBodyFromJson(bodyJson));
                }
                    break;
                case "video": {
                    message = EMMessage.createSendMessage(Type.VIDEO);
                    message.addBody(EMMessageBodyHelper.videoBodyFromJson(bodyJson));
                }
                    break;
                case "voice": {
                    message = EMMessage.createSendMessage(Type.VOICE);
                    message.addBody(EMMessageBodyHelper.voiceBodyFromJson(bodyJson));
                }
                    break;
                case "file": {
                    message = EMMessage.createSendMessage(Type.FILE);
                    message.addBody(EMMessageBodyHelper.fileBodyFromJson(bodyJson));
                }
                    break;
                case "cmd": {
                    message = EMMessage.createSendMessage(Type.CMD);
                    message.addBody(EMMessageBodyHelper.cmdBodyFromJson(bodyJson));
                }
                    break;
                case "custom": {
                    message = EMMessage.createSendMessage(Type.CUSTOM);
                    message.addBody(EMMessageBodyHelper.customBodyFromJson(bodyJson));
                }
                    break;
                case "combine": {
                    message = EMMessage.createSendMessage(Type.COMBINE);
                    message.addBody(EMMessageBodyHelper.combineBodyFromJson(bodyJson));
                }
            }
            if (message != null) {
                message.setDirection(EMMessage.Direct.SEND);
            }
        } else {
            switch (type) {
                case "txt": {
                    message = EMMessage.createReceiveMessage(Type.TXT);
                    message.addBody(EMMessageBodyHelper.textBodyFromJson(bodyJson));
                    break;
                }
                case "img": {
                    message = EMMessage.createReceiveMessage(Type.IMAGE);
                    message.addBody(EMMessageBodyHelper.imageBodyFromJson(bodyJson));
                    break;
                }

                case "loc": {
                    message = EMMessage.createReceiveMessage(Type.LOCATION);
                    message.addBody(EMMessageBodyHelper.localBodyFromJson(bodyJson));
                    break;
                }

                case "video": {
                    message = EMMessage.createReceiveMessage(Type.VIDEO);
                    message.addBody(EMMessageBodyHelper.videoBodyFromJson(bodyJson));
                    break;
                }

                case "voice": {
                    message = EMMessage.createReceiveMessage(Type.VOICE);
                    message.addBody(EMMessageBodyHelper.voiceBodyFromJson(bodyJson));
                    break;
                }
                case "file": {
                    message = EMMessage.createReceiveMessage(Type.FILE);
                    message.addBody(EMMessageBodyHelper.fileBodyFromJson(bodyJson));
                    break;
                }
                case "cmd": {
                    message = EMMessage.createReceiveMessage(Type.CMD);
                    message.addBody(EMMessageBodyHelper.cmdBodyFromJson(bodyJson));
                    break;
                }
                case "custom": {
                    message = EMMessage.createReceiveMessage(Type.CUSTOM);
                    message.addBody(EMMessageBodyHelper.customBodyFromJson(bodyJson));
                    break;
                }

                case "combine": {
                    message = EMMessage.createReceiveMessage(Type.COMBINE);
                    message.addBody(EMMessageBodyHelper.combineBodyFromJson(bodyJson));
                    break;
                }
            }
            if (message != null) {
                message.setDirection(EMMessage.Direct.RECEIVE);
            }
        }

        if (json.has("to")) {
            message.setTo(json.getString("to"));
        }

        if (json.has("from")) {
            message.setFrom(json.getString("from"));
        }
        message.setAcked(json.getBoolean("hasReadAck"));
        if (statusFromInt(json.getInt("status")) == EMMessage.Status.SUCCESS) {
            message.setUnread(!json.getBoolean("hasRead"));
        }
        // message.setDeliverAcked(json.getBoolean("hasDeliverAck"));
        message.setIsNeedGroupAck(json.getBoolean("needGroupAck"));
        if (json.has("groupAckCount")) {
            message.setGroupAckCount(json.getInt("groupAckCount"));
        }

        message.setIsChatThreadMessage(json.getBoolean("isThread"));

        message.deliverOnlineOnly(json.getBoolean("deliverOnlineOnly"));

        message.setLocalTime(json.getLong("localTime"));
        if (json.has("serverTime")){
            message.setMsgTime(json.getLong("serverTime"));
        }

        message.setStatus(statusFromInt(json.getInt("status")));
        if (json.has("chatroomMessagePriority")) {
            int intPriority = json.getInt("chatroomMessagePriority");
            if (intPriority == 0) {
                message.setPriority(EMMessage.EMChatRoomMessagePriority.PriorityHigh);
            }else if (intPriority == 1) {
                message.setPriority(EMMessage.EMChatRoomMessagePriority.PriorityNormal);
            }else if (intPriority == 2) {
                message.setPriority(EMMessage.EMChatRoomMessagePriority.PriorityLow);
            }
        }
        message.setChatType(chatTypeFromInt(json.getInt("chatType")));
        if (json.has("msgId")){
            message.setMsgId(json.getString("msgId"));
        }

        if(json.has("attributes")){
            JSONObject data = json.getJSONObject("attributes");
            Iterator iterator = data.keys();
            while (iterator.hasNext()) {
                String key = iterator.next().toString();
                Object result = data.get(key);
                if (result.getClass().getSimpleName().equals("Integer")) {
                    message.setAttribute(key, (Integer) result);
                } else if (result.getClass().getSimpleName().equals("Boolean")) {
                    message.setAttribute(key, (Boolean) result);
                } else if (result.getClass().getSimpleName().equals("Long")) {
                    message.setAttribute(key, (Long) result);
                } else if (result.getClass().getSimpleName().equals("JSONObject")) {
                    message.setAttribute(key, (JSONObject) result);
                } else if (result.getClass().getSimpleName().equals("JSONArray")) {
                    message.setAttribute(key, (JSONArray) result);
                } else {
                    message.setAttribute(key, data.getString(key));
                }
            }
        }

        if (json.has("receiverList")) {
            ArrayList<String> receiverList = new ArrayList<>();
            JSONArray ja = json.getJSONArray("receiverList");
            for (int i = 0; i < ja.length(); i++) {
                receiverList.add((String) ja.get(i));
            }
            message.setReceiverList(receiverList);
        }

        return message;
    }

    static Map<String, Object> toJson(EMMessage message) {
        Map<String, Object> data = new HashMap<>();
        switch (message.getType()) {
            case TXT: {
                data.put("body", EMMessageBodyHelper.textBodyToJson((EMTextMessageBody) message.getBody()));
            }
                break;
            case IMAGE: {
                data.put("body", EMMessageBodyHelper.imageBodyToJson((EMImageMessageBody) message.getBody()));
            }
                break;
            case LOCATION: {
                data.put("body", EMMessageBodyHelper.localBodyToJson((EMLocationMessageBody) message.getBody()));
            }
                break;
            case CMD: {
                data.put("body", EMMessageBodyHelper.cmdBodyToJson((EMCmdMessageBody) message.getBody()));
            }
                break;
            case CUSTOM: {
                data.put("body", EMMessageBodyHelper.customBodyToJson((EMCustomMessageBody) message.getBody()));
            }
                break;
            case FILE: {
                data.put("body", EMMessageBodyHelper.fileBodyToJson((EMNormalFileMessageBody) message.getBody()));
            }
                break;
            case VIDEO: {
                data.put("body", EMMessageBodyHelper.videoBodyToJson((EMVideoMessageBody) message.getBody()));
            }
                break;
            case VOICE: {
                data.put("body", EMMessageBodyHelper.voiceBodyToJson((EMVoiceMessageBody) message.getBody()));
            }
                break;
            case COMBINE:{
                data.put("body", EMMessageBodyHelper.combineBodyToJson((EMCombineMessageBody) message.getBody()));
            }
                break;
        }

        if (message.ext().size() > 0 && null != message.ext()) {
            data.put("attributes", message.ext());
        }
        data.put("from", message.getFrom());
        data.put("to", message.getTo());
        data.put("hasReadAck", message.isAcked());
        data.put("hasDeliverAck", message.isDelivered());
        data.put("localTime", message.localTime());
        data.put("serverTime", message.getMsgTime());
        data.put("status", statusToInt(message.status()));
        data.put("chatType", chatTypeToInt(message.getChatType()));
        data.put("direction", message.direct() == EMMessage.Direct.SEND ? "send" : "rec");
        data.put("conversationId", message.conversationId());
        data.put("msgId", message.getMsgId());
        data.put("hasRead", !message.isUnread());
        data.put("needGroupAck", message.isNeedGroupAck());
        data.put("onlineState", message.isOnlineState());

        // 通过EMMessageWrapper获取
        // data.put("groupAckCount", message.groupAckCount());
        data.put("isThread", message.isChatThreadMessage());
        return data;
    }

    private static EMMessage.ChatType chatTypeFromInt(int type) {
        switch (type) {
        case 0:
            return EMMessage.ChatType.Chat;
        case 1:
            return EMMessage.ChatType.GroupChat;
        case 2:
            return EMMessage.ChatType.ChatRoom;
        }
        return EMMessage.ChatType.Chat;
    }

    private static int chatTypeToInt(EMMessage.ChatType type) {
        switch (type) {
        case Chat:
            return 0;
        case GroupChat:
            return 1;
        case ChatRoom:
            return 2;
        }
        return 0;
    }

    private static EMMessage.Status statusFromInt(int status) {
        switch (status) {
        case 0:
            return EMMessage.Status.CREATE;
        case 1:
            return EMMessage.Status.INPROGRESS;
        case 2:
            return EMMessage.Status.SUCCESS;
        case 3:
            return EMMessage.Status.FAIL;
        }
        return EMMessage.Status.CREATE;
    }

    private static int statusToInt(EMMessage.Status status) {
        switch (status) {
        case CREATE:
            return 0;
        case INPROGRESS:
            return 1;
        case SUCCESS:
            return 2;
        case FAIL:
            return 3;
        }
        return 0;
    }

}

class EMGroupAckHelper {
    static Map<String, Object>toJson(EMGroupReadAck ack) {
        Map<String, Object> data = new HashMap<>();
        data.put("msg_id", ack.getMsgId());
        data.put("ack_id", ack.getAckId());
        data.put("from", ack.getFrom());
        data.put("count", ack.getCount());
        data.put("timestamp", ack.getTimestamp());
        if (ack.getContent() != null) {
            data.put("content", ack.getContent());
        }
        return data;
    }
}


 class EMMessageBodyHelper {

    static Map<String, Object> getParentMap(EMMessageBody body){
        Map<String, Object> data = new HashMap<>();
        if (body.operatorId() != null && body.operatorId().length() > 0) {
            data.put("operatorId", body.operatorId());
        }
        if (body.operationTime() != 0) {
            data.put("operatorTime", body.operationTime());
        }

        if (body.operationCount() != 0) {
            data.put("operatorCount", body.operationCount());
        }
        return data;
    }

     public static EMTextMessageBody textBodyFromJson(JSONObject json) throws JSONException {
        String content = json.getString("content");
        List<String> list = new ArrayList<>();
        if (json.has("targetLanguages")) {
            JSONArray ja = json.getJSONArray("targetLanguages");
            for (int i = 0; i < ja.length(); i++) {
                list.add(ja.getString(i));
            }
        }
        EMTextMessageBody body = new EMTextMessageBody(content);
        body.setTargetLanguages(list);
        return body;
    }

    static Map<String, Object> textBodyToJson(EMTextMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        data.put("content", body.getMessage());
        data.put("type", "txt");
        if (body.getTargetLanguages() != null) {
            data.put("targetLanguages", body.getTargetLanguages());
        }
        if (body.getTranslations() != null) {
            HashMap<String, String> map = new HashMap<>();
            List<EMTextMessageBody.EMTranslationInfo> list = body.getTranslations();
            for (int i = 0; i < list.size(); ++i) {
                String key = list.get(i).languageCode;
                String value = list.get(i).translationText;
                map.put(key, value);
            }
            data.put("translations", map);
        }
        return data;
    }

    static EMLocationMessageBody localBodyFromJson(JSONObject json) throws JSONException {
        double latitude = json.getDouble("latitude");
        double longitude = json.getDouble("longitude");
        String address = null;
        String buildingName = null;
        if (json.has("address")){
            address = json.getString("address");
        }

        if (json.has("buildingName")){
            buildingName = json.getString("buildingName");
        }

        EMLocationMessageBody body = new EMLocationMessageBody(address, latitude, longitude, buildingName);

        return body;
    }

    static Map<String, Object> localBodyToJson(EMLocationMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        data.put("latitude", body.getLatitude());
        data.put("longitude", body.getLongitude());
        data.put("buildingName", body.getBuildingName());
        data.put("address", body.getAddress());
        data.put("type", "loc");
        return data;
    }

    static EMCmdMessageBody cmdBodyFromJson(JSONObject json) throws JSONException {
        String action = json.getString("action");
        boolean deliverOnlineOnly = json.getBoolean("deliverOnlineOnly");

        EMCmdMessageBody body = new EMCmdMessageBody(action);
        body.deliverOnlineOnly(deliverOnlineOnly);

        return body;
    }

    static Map<String, Object> cmdBodyToJson(EMCmdMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        data.put("deliverOnlineOnly", body.isDeliverOnlineOnly());
        data.put("action", body.action());
        data.put("type", "cmd");
        return data;
    }

    static EMCustomMessageBody customBodyFromJson(JSONObject json) throws JSONException {
        String event = json.getString("event");
        EMCustomMessageBody body = new EMCustomMessageBody(event);

        if (json.has("params") && json.get("params") != JSONObject.NULL) {
        JSONObject jsonObject = json.getJSONObject("params");
        Map<String, String> params = new HashMap<>();
        Iterator iterator = jsonObject.keys();
        while (iterator.hasNext()) {
            String key = iterator.next().toString();
            params.put(key, jsonObject.getString(key));
        }
        body.setParams(params);
        }
        return body;
    }

    static Map<String, Object> customBodyToJson(EMCustomMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        data.put("event", body.event());
        data.put("params", body.getParams());
        data.put("type", "custom");
        return data;
    }

    static EMFileMessageBody fileBodyFromJson(JSONObject json) throws JSONException {
        String localPath = json.getString("localPath");
        File file = new File(localPath);

        EMNormalFileMessageBody body = new EMNormalFileMessageBody(file);
        if (json.has("displayName")){
            body.setFileName(json.getString("displayName"));
        }
        if (json.has("remotePath")){
            body.setRemoteUrl(json.getString("remotePath"));
        }
        if (json.has("secret")){
            body.setSecret(json.getString("secret"));
        }
        body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));
        if (json.has("fileSize")){
            body.setFileLength(json.getInt("fileSize"));
        }

        return body;
    }

    static Map<String, Object> fileBodyToJson(EMNormalFileMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        data.put("localPath", body.getLocalUrl());
        data.put("fileSize", body.getFileSize());
        data.put("displayName", body.getFileName());
        data.put("remotePath", body.getRemoteUrl());
        data.put("secret", body.getSecret());
        data.put("fileStatus", downloadStatusToInt(body.downloadStatus()));
        data.put("type", "file");
        return data;
    }

    static EMImageMessageBody imageBodyFromJson(JSONObject json) throws JSONException {
        String localPath = json.getString("localPath");
        File file = new File(localPath);

        EMImageMessageBody body = new EMImageMessageBody(file);
        if (json.has("displayName")){
            body.setFileName(json.getString("displayName"));
        }
        if (json.has("remotePath")){
            body.setRemoteUrl(json.getString("remotePath"));
        }
        if (json.has("secret")){
            body.setSecret(json.getString("secret"));
        }
        if (json.has("thumbnailLocalPath")) {
            body.setThumbnailLocalPath(json.getString("thumbnailLocalPath"));
        }
        if (json.has("thumbnailRemotePath")){
            body.setThumbnailUrl(json.getString("thumbnailRemotePath"));
        }
        if (json.has("thumbnailSecret")){
            body.setThumbnailSecret(json.getString("thumbnailSecret"));
        }
        if (json.has("fileSize")){
            body.setFileLength(json.getInt("fileSize"));
        }
        if (json.has("width") && json.has("height")){
            int width = json.getInt("width");
            int height = json.getInt("height");
            body.setThumbnailSize(width, height);
        }
        if (json.has("sendOriginalImage")){
            body.setSendOriginalImage(json.getBoolean("sendOriginalImage"));
        }

        if (json.has("fileStatus")){
            body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));
        }

        return body;
    }

    static Map<String, Object> imageBodyToJson(EMImageMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        data.put("localPath", body.getLocalUrl());
        data.put("displayName", body.getFileName());
        data.put("remotePath", body.getRemoteUrl());
        data.put("secret", body.getSecret());
        data.put("fileStatus", downloadStatusToInt(body.downloadStatus()));
        data.put("thumbnailLocalPath", body.thumbnailLocalPath());
        data.put("thumbnailRemotePath", body.getThumbnailUrl());
        data.put("thumbnailSecret", body.getThumbnailSecret());
        data.put("height", body.getHeight());
        data.put("width", body.getWidth());
        data.put("sendOriginalImage", body.isSendOriginalImage());
        data.put("fileSize", body.getFileSize());
        data.put("type", "img");
        return data;
    }

    static EMVideoMessageBody videoBodyFromJson(JSONObject json) throws JSONException {
        String localPath = json.getString("localPath");
        int duration = json.getInt("duration");
        EMVideoMessageBody body = new EMVideoMessageBody(localPath, null, duration, 0);

        if (json.has("thumbnailRemotePath")){
            body.setThumbnailUrl(json.getString("thumbnailRemotePath"));
        }
        if (json.has("thumbnailLocalPath")) {
            body.setLocalThumb(json.getString("thumbnailLocalPath"));
        }
        if (json.has("thumbnailSecret")){
            body.setThumbnailSecret(json.getString("thumbnailSecret"));
        }
        if (json.has("displayName")){
            body.setFileName(json.getString("displayName"));
        }
        if (json.has("remotePath")){
            body.setRemoteUrl(json.getString("remotePath"));
        }
        if (json.has("secret")){
            body.setSecret(json.getString("secret"));
        }
        if (json.has("fileSize")){
            body.setVideoFileLength(json.getInt("fileSize"));
        }

        if(json.has("fileStatus")){
            body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));
        }

        if (json.has("width") && json.has("height")){
            int width = json.getInt("width");
            int height = json.getInt("height");
            body.setThumbnailSize(width, height);
        }


        return body;
    }

    static Map<String, Object> videoBodyToJson(EMVideoMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        data.put("localPath", body.getLocalUrl());
        data.put("thumbnailLocalPath", body.getLocalThumb());
        data.put("duration", body.getDuration());
        data.put("thumbnailRemotePath", body.getThumbnailUrl());
        data.put("thumbnailSecret", body.getThumbnailSecret());
        data.put("displayName", body.getFileName());
        data.put("height", body.getThumbnailHeight());
        data.put("width", body.getThumbnailWidth());
        data.put("remotePath", body.getRemoteUrl());
        data.put("fileStatus", downloadStatusToInt(body.downloadStatus()));
        data.put("secret", body.getSecret());
        data.put("fileSize", body.getVideoFileLength());
        data.put("type", "video");

        return data;
    }

    static EMVoiceMessageBody voiceBodyFromJson(JSONObject json) throws JSONException {
        String localPath = json.getString("localPath");
        File file = new File(localPath);
        int duration = json.getInt("duration");
        EMVoiceMessageBody body = new EMVoiceMessageBody(file, duration);
        body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));
        if (json.has("displayName")){
            body.setFileName(json.getString("displayName"));
        }
        if (json.has("secret")){
            body.setSecret(json.getString("secret"));
        }
        if (json.has("remotePath")){
            body.setRemoteUrl(json.getString("remotePath"));
        }
        if (json.has("fileSize")){
            body.setFileLength(json.getLong("fileSize"));
        }

        return body;
    }

    static Map<String, Object> voiceBodyToJson(EMVoiceMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        data.put("localPath", body.getLocalUrl());
        data.put("duration", body.getLength());
        data.put("displayName", body.getFileName());
        data.put("remotePath", body.getRemoteUrl());
        data.put("fileStatus", downloadStatusToInt(body.downloadStatus()));
        data.put("secret", body.getSecret());
        data.put("type", "voice");
        data.put("fileSize", body.getFileSize());
        return data;
    }

     static EMCombineMessageBody combineBodyFromJson(JSONObject json) throws JSONException {
         String title = json.optString("title");
         String summary = json.optString("summary");
         String compatibleText = json.optString("compatibleText");
         String localPath = json.optString("localPath");
         String remotePath = json.optString("remotePath");
         String secret = json.optString("secret");
         List<String> msgIds = new ArrayList<>();
         if (json.has("messageList")){
             JSONArray array = json.getJSONArray("messageList");
             for (int i = 0; i < array.length(); i++) {
                 msgIds.add(array.getString(i));
             }
         }

         EMCombineMessageBody ret = new EMCombineMessageBody();
         ret.setTitle(title);
         ret.setSummary(summary);
         ret.setCompatibleText(compatibleText);
         ret.setLocalUrl(localPath);
         ret.setRemoteUrl(remotePath);
         ret.setSecret(secret);
         ret.setMessageList(msgIds);

         return ret;
     }
    static Map<String, Object> combineBodyToJson(EMCombineMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        if (body.getTitle() != null) {
            data.put("title", body.getTitle());
        }

        if (body.getSummary() != null) {
            data.put("summary", body.getSummary());
        }

        if (body.getCompatibleText() != null) {
            data.put("compatibleText", body.getCompatibleText());
        }

        if (body.getLocalUrl() != null) {
            data.put("localPath", body.getLocalUrl());
        }

        if (body.getRemoteUrl() != null) {
            data.put("remotePath", body.getRemoteUrl());
        }

        if (body.getSecret() != null) {
            data.put("secret", body.getSecret());
        }

        data.put("type", "combine");

        return data;
    }

    private static EMFileMessageBody.EMDownloadStatus downloadStatusFromInt(int downloadStatus) {
        switch (downloadStatus) {
        case 0:
            return EMFileMessageBody.EMDownloadStatus.DOWNLOADING;
        case 1:
            return EMFileMessageBody.EMDownloadStatus.SUCCESSED;
        case 2:
            return EMFileMessageBody.EMDownloadStatus.FAILED;
        case 3:
            return EMFileMessageBody.EMDownloadStatus.PENDING;
        }
        return EMFileMessageBody.EMDownloadStatus.DOWNLOADING;
    }

    private static int downloadStatusToInt(EMFileMessageBody.EMDownloadStatus downloadStatus) {
        switch (downloadStatus) {
        case DOWNLOADING:
            return 0;
        case SUCCESSED:
            return 1;
        case FAILED:
            return 2;
        case PENDING:
            return 3;
        }
        return 0;
    }
}

class EMConversationHelper {

    // EMConversation 都是native -> flutter, 不需要fromJson
    // static EMConversation fromJson(JSONObject json) throws JSONException {
    // EMConversation conv = new EMConversation();
    // return conv;
    // }

    static Map<String, Object> toJson(EMConversation conversation) {
        Map<String, Object> data = new HashMap<>();
        data.put("convId", conversation.conversationId());
        data.put("type", typeToInt(conversation.getType()));
        data.put("isThread", conversation.isChatThread());
        data.put("isPinned", conversation.isPinned());
        data.put("pinnedTime", conversation.getPinnedTime());
        try {
            data.put("ext", jsonStringToMap(conversation.getExtField()));
        } catch (JSONException e) {

        } finally {
            // 不返回，每次取得时候都从原生取最新的
//            data.put("unreadCount", conversation.getUnreadMsgCount());
//            data.put("latestMessage", EMMessageHelper.toJson(conversation.getLastMessage()));
//            data.put("lastReceivedMessage", EMMessageHelper.toJson(conversation.getLatestMessageFromOthers()));
            return data;
        }
    }

    static EMConversation.EMConversationType typeFromInt(int type) {
        switch (type) {
        case 0:
            return EMConversation.EMConversationType.Chat;
        case 1:
            return EMConversation.EMConversationType.GroupChat;
        case 2:
            return EMConversation.EMConversationType.ChatRoom;
        }

        return EMConversation.EMConversationType.Chat;
    }

    static int typeToInt(EMConversation.EMConversationType type) {
        switch (type) {
        case Chat:
            return 0;
        case GroupChat:
            return 1;
        case ChatRoom:
            return 2;
        }

        return 0;
    }

    private static Map<String, Object> jsonStringToMap(String content) throws JSONException {
        if (content == null)
            return null;
        content = content.trim();
        Map<String, Object> result = new HashMap<>();
        try {
            if (content.charAt(0) == '[') {
                JSONArray jsonArray = new JSONArray(content);
                for (int i = 0; i < jsonArray.length(); i++) {
                    Object value = jsonArray.get(i);
                    if (value instanceof JSONArray || value instanceof JSONObject) {
                        result.put(i + "", jsonStringToMap(value.toString().trim()));
                    } else {
                        result.put(i + "", jsonArray.getString(i));
                    }
                }
            } else if (content.charAt(0) == '{') {
                JSONObject jsonObject = new JSONObject(content);
                Iterator<String> iterator = jsonObject.keys();
                while (iterator.hasNext()) {
                    String key = iterator.next();
                    Object value = jsonObject.get(key);
                    if (value instanceof JSONArray || value instanceof JSONObject) {
                        result.put(key, jsonStringToMap(value.toString().trim()));
                    } else {
                        result.put(key, value.toString().trim());
                    }
                }
            } else {
                throw new JSONException("");
            }
        } catch (JSONException e) {
            throw new JSONException("");
        }
        return result;
    }
}

class EMDeviceInfoHelper {

    static Map<String, Object> toJson(EMDeviceInfo device) {
        Map<String, Object> data = new HashMap<>();
        data.put("resource", device.getResource());
        data.put("deviceUUID", device.getDeviceUUID());
        data.put("deviceName", device.getDeviceName());

        return data;
    }
}

class EMCursorResultHelper {

    static Map<String, Object> toJson(EMCursorResult result) {
        Map<String, Object> data = new HashMap<>();
        data.put("cursor", result.getCursor());
        List<Object> jsonList = new ArrayList<>();
        if (result.getData() != null){
            List list = (List) result.getData();
            for (Object obj : list) {
                if (obj instanceof EMMessage) {
                    jsonList.add(EMMessageHelper.toJson((EMMessage) obj));
                }

                if (obj instanceof EMGroup) {
                    jsonList.add(EMGroupHelper.toJson((EMGroup) obj));
                }

                if (obj instanceof EMChatRoom) {
                    jsonList.add(EMChatRoomHelper.toJson((EMChatRoom) obj));
                }

                if (obj instanceof EMGroupReadAck) {
                    jsonList.add(EMGroupAckHelper.toJson((EMGroupReadAck) obj));
                }

                if (obj instanceof String) {
                    jsonList.add(obj);
                }

                if (obj instanceof EMGroupInfo) {
                    jsonList.add(EMGroupInfoHelper.toJson((EMGroupInfo) obj));
                }

                if (obj instanceof EMMessageReaction) {
                    jsonList.add(EMMessageReactionHelper.toJson((EMMessageReaction) obj));
                }

                if (obj instanceof EMChatThread) {
                    jsonList.add(EMChatThreadHelper.toJson((EMChatThread) obj));
                }

                if (obj instanceof EMConversation) {
                    jsonList.add(EMConversationHelper.toJson((EMConversation) obj));
                }
            }
        }
        data.put("list", jsonList);

        return data;
    }
}

class EMPageResultHelper {

    static Map<String, Object> toJson(EMPageResult result) {
        Map<String, Object> data = new HashMap<>();
        data.put("count", result.getPageCount());
        List<Map> jsonList = new ArrayList<>();
        if (result.getData() != null){
            List list = (List) result.getData();
            for (Object obj : list) {
                if (obj instanceof EMMessage) {
                    jsonList.add(EMMessageHelper.toJson((EMMessage) obj));
                }

                if (obj instanceof EMGroup) {
                    jsonList.add(EMGroupHelper.toJson((EMGroup) obj));
                }

                if (obj instanceof EMChatRoom) {
                    jsonList.add(EMChatRoomHelper.toJson((EMChatRoom) obj));
                }
            }
        }
        data.put("list", jsonList);
        return data;
    }
}

class EMErrorHelper {
    static Map<String, Object> toJson(int errorCode, String desc) {
        Map<String, Object> data = new HashMap<>();
        data.put("code", errorCode);
        data.put("description", desc);
        return data;
    }
}

class EMPushConfigsHelper {
    static Map<String, Object> toJson(EMPushConfigs pushConfigs) {
        Map<String, Object> data = new HashMap<>();
        data.put("noDisturb", pushConfigs.isNoDisturbOn());
        data.put("noDisturbEndHour", pushConfigs.getNoDisturbEndHour());
        data.put("noDisturbStartHour", pushConfigs.getNoDisturbStartHour());
        data.put("pushStyle", pushConfigs.getDisplayStyle() != EMPushManager.DisplayStyle.SimpleBanner);
        data.put("displayName", pushConfigs.getDisplayNickname());
        return data;
    }
}

class HyphenateExceptionHelper {
    static Map<String, Object> toJson(HyphenateException e) {
        Map<String, Object> data = new HashMap<>();
        data.put("code", e.getErrorCode());
        data.put("description", e.getDescription());
        return data;
    }
}

class EMUserInfoHelper {
    static EMUserInfo fromJson(JSONObject obj) throws JSONException {
        EMUserInfo userInfo = new EMUserInfo();
        if (obj.has("nickName")){
            userInfo.setNickname(obj.getString("nickName"));
        }
        if (obj.has("avatarUrl")){
            userInfo.setAvatarUrl(obj.optString("avatarUrl"));
        }
        if (obj.has("mail")){
            userInfo.setEmail(obj.optString("mail"));
        }
        if (obj.has("phone")){
            userInfo.setPhoneNumber(obj.optString("phone"));
        }
        if (obj.has("gender")){
            userInfo.setGender(obj.getInt("gender"));
        }
        if (obj.has("sign")){
            userInfo.setSignature(obj.optString("sign"));
        }
        if (obj.has("birth")){
            userInfo.setBirth(obj.getString("birth"));
        }
        if (obj.has("ext")){
            userInfo.setExt(obj.getString("ext"));
        }

        return userInfo;
    }

    static Map<String, Object> toJson(EMUserInfo userInfo) {
        Map<String, Object> data = new HashMap<>();
        data.put("userId", userInfo.getUserId());
        data.put("nickName", userInfo.getNickname());
        data.put("avatarUrl", userInfo.getAvatarUrl());
        data.put("mail", userInfo.getEmail());
        data.put("phone", userInfo.getPhoneNumber());
        data.put("gender", userInfo.getGender());
        data.put("sign", userInfo.getSignature());
        data.put("birth", userInfo.getBirth());
        data.put("ext", userInfo.getExt());

        return data;
    }
}

class EMPresenceHelper {

    static Map<String, Object> toJson(EMPresence presence) {
        Map<String, Object> data = new HashMap<>();
        data.put("publisher", presence.getPublisher());
        data.put("statusDescription", presence.getExt());
        data.put("lastTime", presence.getLatestTime());
        data.put("expiryTime", presence.getExpiryTime());
        Map<String, Integer> statusList = new HashMap<String, Integer>();
        statusList.putAll(presence.getStatusList());
        data.put("statusDetails", statusList);
        return data;
    }

}

class EMLanguageHelper {
    static Map<String, Object> toJson(EMLanguage language) {
        Map<String, Object> data = new HashMap<>();
        data.put("code", language.LanguageCode);
        data.put("name", language.LanguageName);
        data.put("nativeName", language.LanguageLocalName);
        return data;
    }
}

class EMMessageReactionHelper {
    static Map<String, Object> toJson(EMMessageReaction reaction) {
        Map<String, Object> data = new HashMap<>();
        data.put("reaction", reaction.getReaction());
        data.put("count", reaction.getUserCount());
        data.put("isAddedBySelf", reaction.isAddedBySelf());
        data.put("userList", reaction.getUserList());
        return data;
    }
}

class EMMessageReactionChangeHelper {
    static Map<String, Object> toJson(EMMessageReactionChange change) {
        Map<String, Object> data = new HashMap<>();
        data.put("conversationId", change.getConversionID());
        data.put("messageId", change.getMessageId());
        ArrayList<Map<String, Object>> reactions = new ArrayList<>();
        for (int i = 0; i < change.getMessageReactionList().size(); i++) {
            reactions.add(EMMessageReactionHelper.toJson(change.getMessageReactionList().get(i)));
        }
        data.put("reactions", reactions);

        ArrayList<Map<String, Object>> operations = new ArrayList<>();
        for (int i = 0; i < change.getOperations().size(); i++) {
            operations.add(EMMessageReactionOperationHelper.toJson(change.getOperations().get(i)));
        }
        data.put("operations", operations);

        return data;
    }
}

class EMMessageReactionOperationHelper {
    static Map<String, Object> toJson(EMMessageReactionOperation operation) {
        Map<String, Object> data = new HashMap<>();
        data.put("userId", operation.getUserId());
        data.put("reaction", operation.getReaction());
        data.put("operate", operation.getOperation() == EMMessageReactionOperation.Operation.REMOVE ? 0 : 1);

        return data;
    }
}

class EMChatThreadHelper {
    static Map<String, Object> toJson(EMChatThread thread) {
        Map<String, Object> data = new HashMap<>();
        data.put("threadId", thread.getChatThreadId());
        if (thread.getChatThreadName() != null) {
            data.put("threadName", thread.getChatThreadName());
        }
        data.put("owner", thread.getOwner());
        data.put("msgId", thread.getMessageId());
        data.put("parentId", thread.getParentId());
        data.put("memberCount", thread.getMemberCount());
        data.put("messageCount", thread.getMessageCount());
        data.put("createAt", thread.getCreateAt());
        if (thread.getLastMessage() != null) {
            data.put("lastMessage", EMMessageHelper.toJson(thread.getLastMessage()));
        }
        return data;
    }
}

class EMChatThreadEventHelper {
    static Map<String, Object> toJson(EMChatThreadEvent event) {
        Map<String, Object> data = new HashMap<>();
        if(event.getType() != null) {
            switch (event.getType()) {
                case UNKNOWN:
                    data.put("type", 0);
                    break;
                case CREATE:
                    data.put("type", 1);
                    break;
                case UPDATE:
                    data.put("type", 2);
                    break;
                case DELETE:
                    data.put("type", 3);
                    break;
                case UPDATE_MSG:
                    data.put("type", 4);
                    break;
            }
        }else {
            data.put("type", 0);
        }

        data.put("from", event.getFrom());
        if (event.getChatThread() != null) {
            data.put("thread", EMChatThreadHelper.toJson(event.getChatThread()));
        }
        return data;
    }
}


class EMSilentModeParamHelper {
    static EMSilentModeParam fromJson(JSONObject obj) throws JSONException {
        EMSilentModeParam.EMSilentModeParamType type = paramTypeFromInt(obj.getInt("paramType"));
        EMSilentModeParam param = new EMSilentModeParam(type);;
        if (obj.has("startTime") && obj.has("endTime")) {
            EMSilentModeTime startTime = EMSilentModeTimeHelper.fromJson(obj.getJSONObject("startTime"));
            EMSilentModeTime endTime = EMSilentModeTimeHelper.fromJson(obj.getJSONObject("endTime"));
            param.setSilentModeInterval(startTime, endTime);
        }

        if (obj.has("remindType")) {
            param.setRemindType(pushRemindFromInt(obj.getInt("remindType")));
        }

        if (obj.has("duration")) {
            int duration = obj.getInt("duration");
            param.setSilentModeDuration(duration);
        }
        return param;
    }

    static EMSilentModeParam.EMSilentModeParamType paramTypeFromInt(int iParamType) {
        EMSilentModeParam.EMSilentModeParamType ret = EMSilentModeParam.EMSilentModeParamType.REMIND_TYPE;
        if (iParamType == 0) {
            ret = EMSilentModeParam.EMSilentModeParamType.REMIND_TYPE;
        }else if (iParamType == 1) {
            ret = EMSilentModeParam.EMSilentModeParamType.SILENT_MODE_DURATION;
        }else if (iParamType == 2) {
            ret = EMSilentModeParam.EMSilentModeParamType.SILENT_MODE_INTERVAL;
        }
        return ret;
    }

    static int pushRemindTypeToInt(EMPushManager.EMPushRemindType type) {
        int ret = 0;
        if (type == EMPushManager.EMPushRemindType.ALL) {
            ret = 0;
        }else if (type == EMPushManager.EMPushRemindType.MENTION_ONLY) {
            ret = 1;
        }else if (type == EMPushManager.EMPushRemindType.NONE) {
            ret = 2;
        }
        return ret;
    }

    static EMPushManager.EMPushRemindType pushRemindFromInt(int iType) {
        EMPushManager.EMPushRemindType type = EMPushManager.EMPushRemindType.ALL;
        if (iType == 0) {
            type = EMPushManager.EMPushRemindType.ALL;
        }else if (iType == 1) {
            type = EMPushManager.EMPushRemindType.MENTION_ONLY;
        }else if (iType == 2) {
            type = EMPushManager.EMPushRemindType.NONE;
        }
        return type;
    }
}

class EMSilentModeTimeHelper {
    static EMSilentModeTime fromJson(JSONObject obj) throws JSONException {
        int hour = obj.getInt("hour");
        int minute = obj.getInt("minute");
        EMSilentModeTime modeTime = new EMSilentModeTime(hour, minute);
        return modeTime;
    }

    static Map<String, Object> toJson(EMSilentModeTime modeTime) {
        Map<String, Object> data = new HashMap<>();
        data.put("hour", modeTime.getHour());
        data.put("minute", modeTime.getMinute());
        return data;
    }
}

class EMSilentModeResultHelper {
    static Map<String, Object> toJson(EMSilentModeResult modeResult) {
        Map<String, Object> data = new HashMap<>();
        data.put("expireTs", modeResult.getExpireTimestamp());
        if (modeResult.getConversationId() != null) {
            data.put("conversationId", modeResult.getConversationId());
        }
        if (modeResult.getConversationType() != null) {
            data.put("conversationType", EMConversationHelper.typeToInt(modeResult.getConversationType()));
        }
        if (modeResult.getSilentModeStartTime() != null) {
            data.put("startTime", EMSilentModeTimeHelper.toJson(modeResult.getSilentModeStartTime()));
        }
        if (modeResult.getSilentModeEndTime() != null) {
            data.put("endTime", EMSilentModeTimeHelper.toJson(modeResult.getSilentModeEndTime()));
        }if (modeResult.getRemindType() != null) {
            data.put("remindType", EMSilentModeParamHelper.pushRemindTypeToInt(modeResult.getRemindType()));
        }

        return data;
    }
}

class FetchHistoryOptionsHelper {
    static EMFetchMessageOption fromJson(JSONObject json) throws JSONException {
        EMFetchMessageOption options = new EMFetchMessageOption();
        if (json.getString("direction") == "up") {
            options.setDirection(EMConversation.EMSearchDirection.UP);
        }else {
            options.setDirection(EMConversation.EMSearchDirection.DOWN);
        }
        options.setIsSave(json.getBoolean("needSave"));
        options.setStartTime(json.getLong("startTs"));
        options.setEndTime(json.getLong("endTs"));
        if (json.has("from")){
            options.setFrom(json.getString("from"));
        }
        if (json.has("msgTypes")){
            List<EMMessage.Type> list = new ArrayList<>();
            JSONArray array = json.getJSONArray("msgTypes");
            for (int i = 0; i < array.length(); i++) {
                String type = array.getString(i);
                switch (type) {
                    case "txt": {
                        list.add(Type.TXT);
                    }
                    break;
                    case "img": {
                        list.add(Type.IMAGE);
                    }
                    break;
                    case "loc": {
                        list.add(Type.LOCATION);
                    }
                    break;
                    case "video": {
                        list.add(Type.VIDEO);
                    }
                    break;
                    case "voice": {
                        list.add(Type.VOICE);
                    }
                    break;
                    case "file": {
                        list.add(Type.FILE);
                    }
                    break;
                    case "cmd": {
                        list.add(Type.CMD);
                    }
                    break;
                    case "custom": {
                        list.add(Type.CUSTOM);
                    }
                    break;
                    case "combine": {
                        list.add(Type.COMBINE);
                    }
                    break;
                }
            }
            if (list.size() > 0) {
                options.setMsgTypes(list);
            }
        }

        return options;
    }
}