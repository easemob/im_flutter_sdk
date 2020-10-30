package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMCmdMessageBody;
import com.hyphenate.chat.EMContact;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMCustomMessageBody;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.chat.EMFileMessageBody;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupManager;
import com.hyphenate.chat.EMGroupOptions;
import com.hyphenate.chat.EMImageMessageBody;
import com.hyphenate.chat.EMLocationMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessage.Type;
import com.hyphenate.chat.EMNormalFileMessageBody;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMPageResult;
import com.hyphenate.chat.EMPushConfigs;
import com.hyphenate.chat.EMPushManager;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMVideoMessageBody;
import com.hyphenate.chat.EMVoiceMessageBody;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

class EMOptionsHelper {

    static EMOptions fromJson(JSONObject json) throws JSONException {
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
//            options.setAutoLogin(json.getBoolean(""));  isChatRoomOwnerLeaveAllowed
//            options.setAutoLogin(json.getBoolean(""));  debugModel
//            options.setAutoLogin(json.getBoolean(""));  serverTransfer
        options.setUsingHttpsOnly(json.getBoolean("usingHttpsOnly"));
//            options.setAutoLogin(json.getBoolean(""));  EMPushConfig
//            options.setAutoLogin(json.getBoolean(""));  enableDNSConfig
        options.setImPort(json.getInt("imPort"));
        options.setIMServer(json.getString("imServer"));
        options.setRestServer(json.getString("restServer"));
        options.setDnsUrl(json.getString("dnsUrl"));

        return options;

    }

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
//        data.put("serverTransfer", "");
//        data.put("debugModel", options.);
//        data.put("serverTransfer", options.);
        data.put("usingHttpsOnly", options.getUsingHttpsOnly());
//        data.put("EMPushConfig", "");
//        data.put("enableDNSConfig", "");
        data.put("imPort", options.getImPort());
        data.put("imServer", options.getImServer());
        data.put("restServer", options.getRestServer());
        data.put("dnsUrl", options.getDnsUrl());

        return data;
    }
}


class EMContactHelper {
    static EMContact fromJson(JSONObject json) throws JSONException {
        EMContact contact = new EMContact(json.getString("eid"));
        contact.setNickname(json.getString("nickname"));
        return contact;
    }

    static Map<String, Object> toJson(EMContact contact) {
        Map<String, Object> data = new HashMap<>();
        data.put("eid", contact.getUsername());
        data.put("nickname", contact.getNickname());
        return data;
    }
}


class EMGroupHelper {
    static Map<String, Object> toJson(EMGroup group) {
        Map<String, Object> data = new HashMap<>();
        data.put("groupId", group.getGroupId());
        data.put("name", group.getGroupName());
        data.put("desc", group.getDescription());
        data.put("owner", group.getOwner());
        data.put("announcement", group.getAnnouncement());
        data.put("memberCount", group.getMemberCount());
        data.put("memberList", group.getMembers());
        data.put("adminList", group.getAdminList());
        data.put("blacklist", group.getBlackList());
        data.put("muteList", group.getMuteList());
        data.put("sharedFileList", group.getShareFileList());
//        data.put("", group.getnoticeEnable);
        data.put("messageBlocked", group.isMsgBlocked());
        data.put("isAllMemberMuted", group.isAllMemberMuted());
//        data.put("", group.getOptions());
//        data.put("", group.getPermissionType());

        EMGroupOptions options = new EMGroupOptions();
        options.extField = group.getExtension();
        options.maxUsers = group.getMaxUserCount();

        if (group.isPublic()) {
            if (group.isMemberOnly()) {
                options.style =  EMGroupManager.EMGroupStyle.EMGroupStylePublicJoinNeedApproval;
            }else {
                options.style =  EMGroupManager.EMGroupStyle.EMGroupStylePublicOpenJoin;
            }
        }else {
            if (group.isMemberAllowToInvite()) {
                options.style =  EMGroupManager.EMGroupStyle.EMGroupStylePrivateMemberCanInvite;
            }else {
                options.style =  EMGroupManager.EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite;
            }
        }

        data.put("options", EMGroupOptionsHelper.toJson(options));

        return data;
    }
}

class EMGroupOptionsHelper {

    static Map<String, Object> toJson(EMGroupOptions options) {
        Map<String, Object> data = new HashMap<>();
        data.put("maxCount", options.maxUsers);
        data.put("inviteNeedConfirm", options.inviteNeedConfirm);
        data.put("ext", options.extField);
        data.put("style", styleToInt(options.style));
        return data;
    }

    private static EMGroupManager.EMGroupStyle styleFromInt(int style) {
        switch (style){
            case 0: return EMGroupManager.EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite;
            case 1: return EMGroupManager.EMGroupStyle.EMGroupStylePrivateMemberCanInvite;
            case 2: return EMGroupManager.EMGroupStyle.EMGroupStylePublicJoinNeedApproval;
            case 3: return EMGroupManager.EMGroupStyle.EMGroupStylePublicOpenJoin;
        }

        return EMGroupManager.EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite;
    }

    private static int styleToInt(EMGroupManager.EMGroupStyle style) {
        switch (style) {
            case EMGroupStylePrivateOnlyOwnerInvite: return 0;
            case EMGroupStylePrivateMemberCanInvite: return 1;
            case EMGroupStylePublicJoinNeedApproval: return 2;
            case EMGroupStylePublicOpenJoin: return 3;
        }

        return 0;
    }
}

class EMChatRoomHelper{

//   chatroom 都是native -> flutter, 不需要fromJson
//    static EMChatRoom fromJson(JSONObject json) throws JSONException {
//        EMChatRoom chatRoom = new EMChatRoom();
//    }

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
        data.put("blacklist", chatRoom.getBlackList());
        data.put("muteList", chatRoom.getMuteList());
        data.put("isAllMemberMuted", chatRoom.isAllMemberMuted());
        data.put("announcement", chatRoom.getAnnouncement());
//        data.put("permissionType", chatRoom);

        return data;
    }

//    static int premissionTypeToInt()
}

class EMMessageHelper {

    static EMMessage fromJson(JSONObject json) throws JSONException {
        EMMessage message = null;
        JSONObject bodyJson = json.getJSONObject("body");
        String type = bodyJson.getString("type");
        switch (type){
            case "txt": {
                message = EMMessage.createReceiveMessage(Type.TXT);
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
            message.setFrom(json.getString("from"));
            message.setTo(json.getString("to"));
            message.setAcked(json.getBoolean("hasReadAck"));
            message.setUnread(!json.getBoolean("hasRead"));
            message.setDeliverAcked(json.getBoolean("hasDeliverAck"));
            message.setLocalTime(json.getLong("localTime"));
            message.setMsgTime(json.getLong("serverTime"));
            message.setStatus(statusFromInt(json.getInt("status")));
            message.setChatType(chatTypeFromInt(json.getInt("chatType")));
            message.setDirection(json.getString("direction").equals("send") ? EMMessage.Direct.SEND : EMMessage.Direct.RECEIVE);
        }

        return message;
    }

    static Map<String, Object> toJson(EMMessage message) {
        Map<String, Object> data = new HashMap<>();
        String type = "";
        switch (message.getType()){
            case TXT: {
                type = "txt";
                data.put("body", EMMessageBodyHelper.textBodyToJson((EMTextMessageBody) message.getBody()));
            } break;
            case IMAGE: {
                type = "img";
                data.put("body", EMMessageBodyHelper.imageBodyToJson((EMImageMessageBody) message.getBody()));
            } break;
            case LOCATION: {
                type = "loc";
                data.put("body", EMMessageBodyHelper.localBodyToJson((EMLocationMessageBody) message.getBody()));
            } break;
            case CMD: {
                type = "cmd";
                data.put("body", EMMessageBodyHelper.cmdBodyToJson((EMCmdMessageBody) message.getBody()));
            } break;
            case CUSTOM: {
                type = "custom";
                data.put("body", EMMessageBodyHelper.customBodyToJson((EMCustomMessageBody) message.getBody()));
            } break;
            case FILE: {
                type = "file";
                data.put("body", EMMessageBodyHelper.fileBodyToJson((EMNormalFileMessageBody) message.getBody()));
            } break;
            case VIDEO: {
                type = "video";
                data.put("body", EMMessageBodyHelper.videoBodyToJson((EMVideoMessageBody) message.getBody()));
            } break;
            case VOICE: {
                type = "voice";
                data.put("body", EMMessageBodyHelper.voiceBodyToJson((EMVoiceMessageBody) message.getBody()));
            } break;
        }

        data.put("type", type);
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

        return data;
    }

    private static EMMessage.ChatType chatTypeFromInt(int type) {
        switch (type){
            case 0: return EMMessage.ChatType.Chat;
            case 1: return EMMessage.ChatType.GroupChat;
            case 2: return EMMessage.ChatType.ChatRoom;
        }
        return EMMessage.ChatType.Chat;
    }

    private static int chatTypeToInt(EMMessage.ChatType type) {
        switch (type) {
            case Chat: return 0;
            case GroupChat: return 1;
            case ChatRoom: return 2;
        }
        return 0;
    }

    private static EMMessage.Status statusFromInt(int status) {
        switch (status) {
            case 0: return EMMessage.Status.CREATE;
            case 1: return EMMessage.Status.INPROGRESS;
            case 2: return EMMessage.Status.SUCCESS;
            case 3: return EMMessage.Status.FAIL;
        }
        return EMMessage.Status.CREATE;
    }

    private static int statusToInt(EMMessage.Status status) {
        switch (status) {
            case CREATE: return 0;
            case INPROGRESS: return 1;
            case SUCCESS: return 2;
            case FAIL: return 3;
        }
        return 0;
    }

}

class EMMessageBodyHelper {


    static EMTextMessageBody textBodyFromJson(JSONObject json) throws JSONException {
        String content = json.getString("content");
        EMTextMessageBody body = new EMTextMessageBody(content);
        return body;
    }


    static Map<String, Object> textBodyToJson(EMTextMessageBody body) {
        Map<String, Object> data = new HashMap<>();
        data.put("content", body.getMessage());
        return data;
    }


    static EMLocationMessageBody localBodyFromJson(JSONObject json) throws JSONException {
        double latitude = json.getDouble("latitude");
        double longitude = json.getDouble("longitude");
        String address = json.getString("address");

        EMLocationMessageBody body = new EMLocationMessageBody(address, latitude, longitude);
        return body;
    }

    static Map<String, Object> localBodyToJson(EMLocationMessageBody body) {
        Map<String, Object> data = new HashMap<>();
        data.put("latitude", body.getLatitude());
        data.put("longitude", body.getLongitude());
        data.put("address", body.getAddress());
        return data;
    }

    static EMCmdMessageBody cmdBodyFromJson(JSONObject json) throws JSONException  {
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
        return data;
    }

    static EMCustomMessageBody customBodyFromJson(JSONObject json) throws JSONException  {
        String event = json.getString("event");
        JSONObject jsonObject = json.getJSONObject("params");
        Map<String, String> params =new HashMap<>();
        Iterator iterator = jsonObject.keys();
        while (iterator.hasNext()){
            String key = iterator.next().toString();
            params.put(key, jsonObject.getString(key));
        }

        EMCustomMessageBody body = new EMCustomMessageBody(event);
        body.setParams(params);

        return body;
    }

    static Map<String, Object> customBodyToJson(EMCustomMessageBody body) {
        Map<String, Object> data = new HashMap<>();
        data.put("event", body.event());
        data.put("params", body.getParams());
        return data;
    }

    static EMFileMessageBody fileBodyFromJson(JSONObject json) throws JSONException  {
        String localPath = json.getString("localPath");
        File file = new File(localPath);

        EMNormalFileMessageBody body = new EMNormalFileMessageBody(file);
        body.setFileLength(json.getLong("fileSize"));
        body.setFileName(json.getString("displayName"));
        body.setRemoteUrl(json.getString("remotePath"));
        body.setSecret(json.getString("secret"));
        body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));
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
        return data;
    }

    static EMImageMessageBody imageBodyFromJson(JSONObject json) throws JSONException  {
        String localPath = json.getString("localPath");
        File file = new File(localPath);

        EMImageMessageBody body = new EMImageMessageBody(file);
        body.setFileLength(json.getLong("fileSize"));
        body.setFileName(json.getString("displayName"));
        body.setRemoteUrl(json.getString("remotePath"));
        body.setSecret(json.getString("secret"));
        body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));

        body.setThumbnailLocalPath(json.getString("thumbnailLocalPath"));
        body.setThumbnailUrl(json.getString("thumbnailRemotePath"));
        body.setThumbnailSecret(json.getString("thumbnailSecret"));

        int width = json.getInt("height");
        int height = json.getInt("width");
        body.setThumbnailSize(width, height);
        body.setSendOriginalImage(json.getBoolean("sendOriginalImage"));

        return body;
    }

    static Map<String, Object> imageBodyToJson(EMImageMessageBody body) {
        Map<String, Object> data = new HashMap<>();
        data.put("localPath", body.getLocalUrl());
//        data.put("fileSize", body.get());
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
        return data;
    }

    static EMVideoMessageBody videoBodyFromJson(JSONObject json) throws JSONException  {
        String localPath = json.getString("localPath");
        String thumbnailLocalPath = json.getString("thumbnailLocalPath");
        int duration = json.getInt("duration");
        int fileSize = json.getInt("fileSize");
        EMVideoMessageBody body = new EMVideoMessageBody(localPath, thumbnailLocalPath, duration, fileSize);
        body.setThumbnailUrl(json.getString("thumbnailRemotePath"));
        body.setThumbnailSecret(json.getString("thumbnailSecret"));
        body.setFileName(json.getString("displayName"));
        int width = json.getInt("height");
        int height = json.getInt("width");
        body.setThumbnailSize(width, height);
        body.setRemoteUrl(json.getString("remotePath"));
        body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));
        body.setSecret(json.getString("secret"));

        return body;
    }

    static Map<String, Object> videoBodyToJson(EMVideoMessageBody body) {
        Map<String, Object> data = new HashMap<>();
        data.put("localPath", body.getLocalUrl());
//        data.put("thumbnailLocalPath", body.getLocalThumbUri());
        data.put("duration", body.getDuration());
        data.put("fileSize", body.getVideoFileLength());
        data.put("thumbnailRemotePath", body.getThumbnailUrl());
        data.put("thumbnailSecret", body.getThumbnailSecret());
        data.put("displayName", body.getFileName());
        data.put("height", body.getThumbnailHeight());
        data.put("width", body.getThumbnailWidth());
        data.put("remotePath", body.getRemoteUrl());
        data.put("fileStatus", downloadStatusToInt(body.downloadStatus()));
        data.put("secret", body.getSecret());

        return data;
    }

    static EMVoiceMessageBody voiceBodyFromJson(JSONObject json) throws JSONException  {
        String localPath = json.getString("localPath");
        File file = new File(localPath);
        int duration = json.getInt("duration");
        EMVoiceMessageBody body = new EMVoiceMessageBody(file, duration);
        body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));
        body.setFileName(json.getString("displayName"));
        body.setFileLength(json.getLong("fileSize"));
        body.setSecret(json.getString("secret"));
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

        return data;
    }

    private static EMFileMessageBody.EMDownloadStatus downloadStatusFromInt(int downloadStatus) {
        switch (downloadStatus) {
            case 0: return EMFileMessageBody.EMDownloadStatus.DOWNLOADING;
            case 1: return EMFileMessageBody.EMDownloadStatus.SUCCESSED;
            case 2: return EMFileMessageBody.EMDownloadStatus.FAILED;
            case 3: return EMFileMessageBody.EMDownloadStatus.PENDING;
        }
        return EMFileMessageBody.EMDownloadStatus.DOWNLOADING;
    }

    private static int downloadStatusToInt(EMFileMessageBody.EMDownloadStatus downloadStatus) {
        switch (downloadStatus){
            case DOWNLOADING: return 0;
            case SUCCESSED: return 1;
            case FAILED: return 2;
            case PENDING: return 3;
        }
        return 0;
    }
}

class EMConversationHelper {

//    EMConversation 都是native -> flutter, 不需要fromJson
//    static EMConversation fromJson(JSONObject json) throws JSONException {
//        EMConversation conv = new EMConversation();
//        return conv;
//    }

    static Map<String, Object> toJson(EMConversation conversation) {
        Map<String, Object> data = new HashMap<>();
        data.put("con_id", conversation.conversationId());
        data.put("type", typeToInt(conversation.getType()));
        data.put("unreadCount", conversation.getUnreadMsgCount());
        data.put("ext", conversation.getExtField());
        data.put("latestMessage", EMMessageHelper.toJson(conversation.getLastMessage()));
        data.put("lastReceivedMessage", EMMessageHelper.toJson(conversation.getLatestMessageFromOthers()));
        return data;
    }


    private static EMConversation.EMConversationType typeFromInt(int type) {
        switch (type) {
            case 0: return EMConversation.EMConversationType.Chat;
            case 1: return EMConversation.EMConversationType.GroupChat;
            case 2: return EMConversation.EMConversationType.ChatRoom;
        }

        return EMConversation.EMConversationType.Chat;
    }

    private static int typeToInt(EMConversation.EMConversationType type) {
        switch (type) {
            case Chat: return 0;
            case GroupChat: return 1;
            case ChatRoom: return 2;
        }

        return 0;
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
        data.put("cursor",result.getCursor());
        List list = (List) result.getData();
        List<Object> jsonList = new ArrayList<>();
        for (Object obj: list) {
            if (obj instanceof EMMessage) {
                jsonList.add(EMMessageHelper.toJson((EMMessage)obj));
            }

            if (obj instanceof EMGroup) {
                jsonList.add(EMGroupHelper.toJson((EMGroup)obj));
            }

            if (obj instanceof EMChatRoom) {
                jsonList.add(EMChatRoomHelper.toJson((EMChatRoom)obj));
            }

            if (obj instanceof String) {
                jsonList.add(obj);
            }
        }
        data.put("list",jsonList);

        return data;
    }
}

class EMPageResultHelper {

    static Map<String, Object> toJson(EMPageResult result) {
        Map<String, Object> data = new HashMap<>();
        data.put("count",result.getPageCount());
        List list = (List) result.getData();
        List<Map> jsonList = new ArrayList<>();
        for (Object obj: list) {
            if (obj instanceof EMMessage) {
                jsonList.add(EMMessageHelper.toJson((EMMessage)obj));
            }

            if (obj instanceof EMGroup) {
                jsonList.add(EMGroupHelper.toJson((EMGroup)obj));
            }

            if (obj instanceof EMChatRoom) {
                jsonList.add(EMChatRoomHelper.toJson((EMChatRoom)obj));
            }
        }
        data.put("list",jsonList);
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
        data.put("", pushConfigs.getDisplayNickname());
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