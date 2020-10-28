package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMCmdMessageBody;
import com.hyphenate.chat.EMContact;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMCustomMessageBody;
import com.hyphenate.chat.EMFileMessageBody;
import com.hyphenate.chat.EMImageMessageBody;
import com.hyphenate.chat.EMLocationMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessage.Type;
import com.hyphenate.chat.EMNormalFileMessageBody;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMVideoMessageBody;
import com.hyphenate.chat.EMVoiceMessageBody;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

class EMOptionsHelper {

    static EMOptions fromJson(JSONObject json) throws JSONException {
        EMOptions options = new EMOptions();
        options.setAppKey(json.getString("appKey"));
        options.setAutoLogin(json.getBoolean(""));
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

class EMChatRoomHelper{

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
            message.setDeliverAcked(json.getBoolean("hasDeliverAck"));
            message.setLocalTime(json.getLong("localTime"));
            message.setMsgTime(json.getLong("serverTime"));
            message.setStatus(statusFromInt(json.getInt("status")));
            message.setChatType(chatTypeFromInt(json.getInt("chatType")));
            message.setDirection(json.getString("direction").equals("send") ? EMMessage.Direct.SEND : EMMessage.Direct.RECEIVE);
        }

        return message;
    }

    private static Map<String, Object> toJson(EMMessage message) {
        Map<String, Object> data = new HashMap<>();
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

    static EMLocationMessageBody localBodyFromJson(JSONObject json) throws JSONException {
        double latitude = json.getDouble("latitude");
        double longitude = json.getDouble("longitude");
        String address = json.getString("address");

        EMLocationMessageBody body = new EMLocationMessageBody(address, latitude, longitude);
        return body;
    }

    static EMCmdMessageBody cmdBodyFromJson(JSONObject json) throws JSONException  {
        String action = json.getString("action");
        boolean deliverOnlineOnly = json.getBoolean("deliverOnlineOnly");

        EMCmdMessageBody body = new EMCmdMessageBody(action);
        body.deliverOnlineOnly(deliverOnlineOnly);

        return body;
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
        body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));
        return body;
    }

    static EMVoiceMessageBody voiceBodyFromJson(JSONObject json) throws JSONException  {
        String localPath = json.getString("localPath");
        File file = new File(localPath);
        int duration = json.getInt("duration");
        EMVoiceMessageBody body = new EMVoiceMessageBody(file, duration);
        body.setDownloadStatus(downloadStatusFromInt(json.getInt("fileStatus")));
        body.setFileName(json.getString("displayName"));
        body.setFileLength(json.getLong("fileSize"));
        return body;
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

    static int downloadStatusToInt(EMFileMessageBody.EMDownloadStatus downloadStatus) {
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
    static Map<String, Object> toJson(EMConversation conversation) {
        Map<String, Object> data = new HashMap<>();
        data.put("con_id", conversation.conversationId());
        data.put("unreadCount", conversation.getUnreadMsgCount());
        data.put("ext", conversation.getExtField());
        data.put("latestMessage", conversation.getLastMessage());
        data.put("lastReceivedMessage", conversation.getLatestMessageFromOthers());
        return data;
    }
}