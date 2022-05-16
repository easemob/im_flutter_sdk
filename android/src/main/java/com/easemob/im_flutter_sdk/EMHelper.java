package com.easemob.im_flutter_sdk;

import android.content.Context;

import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCmdMessageBody;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMCustomMessageBody;
import com.hyphenate.chat.EMDeviceInfo;
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
import com.hyphenate.chat.EMMucSharedFile;
import com.hyphenate.chat.EMNormalFileMessageBody;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMPageResult;
import com.hyphenate.chat.EMPresence;
import com.hyphenate.chat.EMPushConfigs;
import com.hyphenate.chat.EMPushManager;
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
        options.setUsingHttpsOnly(json.getBoolean("usingHttpsOnly"));
        options.enableDNSConfig(json.getBoolean("enableDNSConfig"));
        if (!json.getBoolean("enableDNSConfig")) {
            options.setImPort(json.getInt("imPort"));
            options.setIMServer(json.getString("imServer"));
            options.setRestServer(json.getString("restServer"));
            options.setDnsUrl(json.getString("dnsUrl"));
        }

        if (json.has("pushConfig")) {
            EMPushConfig.Builder builder = new EMPushConfig.Builder(context);
            JSONObject pushConfig = json.getJSONObject("pushConfig");
            if (pushConfig.getBoolean("enableMiPush")) {
                builder.enableMiPush(pushConfig.getString("miAppId"), pushConfig.getString("miAppKey"));
            }
            if (pushConfig.getBoolean("enableFCM")) {
                builder.enableFCM(pushConfig.getString("fcmId"));
                options.setUseFCM(true);
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
        data.put("muteList", chatRoom.getMuteList().values());
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
            }
            if (message != null) {
                message.setDirection(EMMessage.Direct.SEND);
            }
        } else {
            switch (type) {
                case "txt": {
                    message = EMMessage.createReceiveMessage(Type.TXT);
                    message.addBody(EMMessageBodyHelper.textBodyFromJson(bodyJson));
                }
                    break;
                case "img": {
                    message = EMMessage.createReceiveMessage(Type.IMAGE);
                    message.addBody(EMMessageBodyHelper.imageBodyFromJson(bodyJson));
                }
                    break;
                case "loc": {
                    message = EMMessage.createReceiveMessage(Type.LOCATION);
                    message.addBody(EMMessageBodyHelper.localBodyFromJson(bodyJson));
                }
                    break;
                case "video": {
                    message = EMMessage.createReceiveMessage(Type.VIDEO);
                    message.addBody(EMMessageBodyHelper.videoBodyFromJson(bodyJson));
                }
                    break;
                case "voice": {
                    message = EMMessage.createReceiveMessage(Type.VOICE);
                    message.addBody(EMMessageBodyHelper.voiceBodyFromJson(bodyJson));
                }
                    break;
                case "file": {
                    message = EMMessage.createReceiveMessage(Type.FILE);
                    message.addBody(EMMessageBodyHelper.fileBodyFromJson(bodyJson));
                }
                    break;
                case "cmd": {
                    message = EMMessage.createReceiveMessage(Type.CMD);
                    message.addBody(EMMessageBodyHelper.cmdBodyFromJson(bodyJson));
                }
                    break;
                case "custom": {
                    message = EMMessage.createReceiveMessage(Type.CUSTOM);
                    message.addBody(EMMessageBodyHelper.customBodyFromJson(bodyJson));
                }
                break;
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
        message.setDeliverAcked(json.getBoolean("hasDeliverAck"));
        message.setIsNeedGroupAck(json.getBoolean("needGroupAck"));
        if (json.has("groupAckCount")) {
            message.setGroupAckCount(json.getInt("groupAckCount"));
        }

        message.setLocalTime(json.getLong("localTime"));
        if (json.has("serverTime")){
            message.setMsgTime(json.getLong("serverTime"));
        }

        message.setStatus(statusFromInt(json.getInt("status")));
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
        data.put("groupAckCount", message.groupAckCount());

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

    static EMTextMessageBody textBodyFromJson(JSONObject json) throws JSONException {
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
        Map<String, Object> data = new HashMap<>();
        data.put("content", body.getMessage());
        data.put("type", "txt");
        if (body.getTargetLanguages() != null) {
            data.put("targetLanguages", body.getTargetLanguages());
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
        Map<String, Object> data = new HashMap<>();
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
        Map<String, Object> data = new HashMap<>();
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
        Map<String, Object> data = new HashMap<>();
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
        Map<String, Object> data = new HashMap<>();
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
        Map<String, Object> data = new HashMap<>();
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
        Map<String, Object> data = new HashMap<>();
        data.put("localPath", body.getLocalUrl());
        data.put("thumbnailLocalPath", body.getLocalThumbUri());
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
        Map<String, Object> data = new HashMap<>();
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
        data.put("con_id", conversation.conversationId());
        data.put("type", typeToInt(conversation.getType()));
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

    private static int typeToInt(EMConversation.EMConversationType type) {
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
        if (obj.has("userId")){
            userInfo.setUserId(obj.getString("userId"));
        }
        if (obj.has("nickName")){
            userInfo.setNickname(obj.getString("nickName"));
        }

        if (obj.has("gender")){
            userInfo.setGender(obj.getInt("gender"));
        }
        if (obj.has("mail")){
            userInfo.setEmail(obj.optString("mail"));
        }
        if (obj.has("phone")){
            userInfo.setPhoneNumber(obj.optString("phone"));
        }
        if (obj.has("sign")){
            userInfo.setSignature(obj.optString("sign"));
        }
        if (obj.has("avatarUrl")){
            userInfo.setAvatarUrl(obj.optString("avatarUrl"));
        }
        if (obj.has("ext")){
            userInfo.setExt(obj.getString("ext"));
        }
        if (obj.has("birth")){
            userInfo.setBirth(obj.getString("birth"));
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

class EMChatThreadHelper {

}

class EMChatThreadEventHelper {

}
