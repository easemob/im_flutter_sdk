package com.easemob.im_flutter_sdk;

import android.content.Context;
import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMChatThread;
import com.hyphenate.chat.EMChatThreadEvent;
import com.hyphenate.chat.EMCmdMessageBody;
import com.hyphenate.chat.EMCombineMessageBody;
import com.hyphenate.chat.EMContact;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMConversationFilter;
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
import com.hyphenate.chat.EMLoginExtensionInfo;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessage.Type;
import com.hyphenate.chat.EMMessageBody;
import com.hyphenate.chat.EMMessagePinInfo;
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
import com.hyphenate.chat.EMRecallMessageInfo;
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

class OptionsHelper {

    static EMOptions fromJson(JSONObject json, Context context) throws JSONException {
        EMOptions options = new EMOptions();
        if(json.has("appKey")) {
            options.setAppKey(json.getString("appKey"));
        }else {
            options.setAppId(json.optString("appId"));
        }
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
                boolean agreePrivacyStatement = pushConfig.getBoolean("agreePrivacyStatement");
                builder.enableVivoPush(agreePrivacyStatement);
            }
            if(pushConfig.getBoolean("enableHonorPush")) {
                builder.enableHonorPush();
            }
            options.setPushConfig(builder.build());
        }

        // 450
        options.setEnableTLSConnection(json.optBoolean("enableTLS", false));
        options.setUseReplacedMessageContents(json.optBoolean("useReplacedMessageContents", false));
        options.setIncludeSendMessageInMessageListener(json.optBoolean("messagesReceiveCallbackIncludeSend", false));
        options.setRegardImportedMsgAsRead(json.optBoolean("regardImportMessagesAsRead", false));
        // 481
        if(json.has("loginExtensionInfo")) {
            options.setLoginCustomExt(json.getString("loginExtensionInfo"));
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


class GroupHelper {
    static Map<String, Object> toJson(EMGroup group) {
        Map<String, Object> data = new HashMap<>();
        CommonUtil.putObjectToMap(data, "groupId", group.getGroupId());
        CommonUtil.putObjectToMap(data, "name", group.getGroupName());
        CommonUtil.putObjectToMap(data, "desc", group.getDescription());
        CommonUtil.putObjectToMap(data, "owner", group.getOwner());
        CommonUtil.putObjectToMap(data, "announcement", group.getAnnouncement());
        CommonUtil.putObjectToMap(data, "memberCount", group.getMemberCount());
        CommonUtil.putObjectToMap(data, "memberList", group.getMembers());
        CommonUtil.putObjectToMap(data, "adminList", group.getAdminList());
        CommonUtil.putObjectToMap(data, "blockList", group.getBlackList());
        CommonUtil.putObjectToMap(data, "muteList", group.getMuteList());
        CommonUtil.putObjectToMap(data, "messageBlocked", group.isMsgBlocked());
        CommonUtil.putObjectToMap(data, "isDisabled", group.isDisabled());
        CommonUtil.putObjectToMap(data, "isAllMemberMuted", group.isAllMemberMuted());
        CommonUtil.putObjectToMap(data, "permissionType", EnumTools.groupPermissionTypeToInt(group.getGroupPermissionType()));
        CommonUtil.putObjectToMap(data, "maxUserCount", group.getMaxUserCount());
        CommonUtil.putObjectToMap(data, "isMemberOnly", group.isMemberOnly());
        CommonUtil.putObjectToMap(data, "isMemberAllowToInvite", group.isMemberAllowToInvite());
        CommonUtil.putObjectToMap(data, "ext", group.getExtension());
        return data;
    }
}

class GroupInfoHelper {
    static Map<String, Object> toJson(EMGroupInfo group) {
        Map<String, Object> data = new HashMap<>();
        data.put("groupId", group.getGroupId());
        data.put("name", group.getGroupName());
        return data;
    }
}

class MucSharedFileHelper {
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

class GroupOptionsHelper {

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

class ContactHelper {
    static Map<String, Object> toJson(EMContact contact) {
        Map<String, Object> data = new HashMap<>();
        data.put("userId", contact.getUsername());
        String remark = contact.getRemark();
        if (remark != null) {
            data.put("remark", remark);
        }
        return data;
    }

    static EMContact fromJson(JSONObject json) {
        String userId = json.optString("userId");
        String remark = json.optString("remark");
        EMContact contact = new EMContact(userId);
        if (!remark.isEmpty()) {
            contact.setRemark(remark);
        }
        return contact;
    }
}

class ChatRoomHelper {

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
        data.put("permissionType", EnumTools.chatRoomPermissionTypeToInt(chatRoom.getChatRoomPermissionType()));
        data.put("createTimestamp", chatRoom.getCreateTimestamp());
        data.put("muteExpireTimestamp", chatRoom.getMuteExpireTimestamp());
        data.put("isInWhitelist", chatRoom.isInWhitelist());

        return data;
    }

}

class MessageHelper {

    static Type getTypeFromInt(int iType) {
        switch (iType) {
            case 1:
                return Type.IMAGE;
            case 2:
                return Type.VIDEO;
            case 3:
                return Type.LOCATION;
            case 4:
                return Type.VOICE;
            case 5:
                return Type.FILE;
            case 6:
                return Type.CMD;
            case 7:
                return Type.CUSTOM;
            case 8:
                return Type.COMBINE;
            default:
                return Type.TXT;
        }
    }

    static EMMessage fromJson(JSONObject json) throws JSONException {
        EMMessage message = null;

        JSONObject bodyJson = json.getJSONObject("body");
        EMMessage.Type type = EnumTools.messageBodyTypeFromInt(bodyJson.getInt("type"));
        EMMessage.Direct direct = EnumTools.messageDirectFromInt(json.getInt("direction"));
        if (direct == EMMessage.Direct.SEND) {
            switch (type) {
                case TXT: {
                    message = EMMessage.createSendMessage(Type.TXT);
                    message.addBody(MessageBodyHelper.textBodyFromJson(bodyJson));
                }
                    break;
                case IMAGE: {
                    message = EMMessage.createSendMessage(Type.IMAGE);
                    message.addBody(MessageBodyHelper.imageBodyFromJson(bodyJson));
                }
                    break;
                case LOCATION: {
                    message = EMMessage.createSendMessage(Type.LOCATION);
                    message.addBody(MessageBodyHelper.localBodyFromJson(bodyJson));
                }
                    break;
                case VIDEO: {
                    message = EMMessage.createSendMessage(Type.VIDEO);
                    message.addBody(MessageBodyHelper.videoBodyFromJson(bodyJson));
                }
                    break;
                case VOICE: {
                    message = EMMessage.createSendMessage(Type.VOICE);
                    message.addBody(MessageBodyHelper.voiceBodyFromJson(bodyJson));
                }
                    break;
                case FILE: {
                    message = EMMessage.createSendMessage(Type.FILE);
                    message.addBody(MessageBodyHelper.fileBodyFromJson(bodyJson));
                }
                    break;
                case CMD: {
                    message = EMMessage.createSendMessage(Type.CMD);
                    message.addBody(MessageBodyHelper.cmdBodyFromJson(bodyJson));
                }
                    break;
                case CUSTOM: {
                    message = EMMessage.createSendMessage(Type.CUSTOM);
                    message.addBody(MessageBodyHelper.customBodyFromJson(bodyJson));
                }
                    break;
                case COMBINE: {
                    message = EMMessage.createSendMessage(Type.COMBINE);
                    message.addBody(MessageBodyHelper.combineBodyFromJson(bodyJson));
                }
            }
            if (message != null) {
                message.setDirection(EMMessage.Direct.SEND);
            }
        } else {
            switch (type) {
                case TXT: {
                    message = EMMessage.createReceiveMessage(Type.TXT);
                    message.addBody(MessageBodyHelper.textBodyFromJson(bodyJson));
                    break;
                }
                case IMAGE: {
                    message = EMMessage.createReceiveMessage(Type.IMAGE);
                    message.addBody(MessageBodyHelper.imageBodyFromJson(bodyJson));
                    break;
                }

                case LOCATION: {
                    message = EMMessage.createReceiveMessage(Type.LOCATION);
                    message.addBody(MessageBodyHelper.localBodyFromJson(bodyJson));
                    break;
                }

                case VIDEO: {
                    message = EMMessage.createReceiveMessage(Type.VIDEO);
                    message.addBody(MessageBodyHelper.videoBodyFromJson(bodyJson));
                    break;
                }

                case VOICE: {
                    message = EMMessage.createReceiveMessage(Type.VOICE);
                    message.addBody(MessageBodyHelper.voiceBodyFromJson(bodyJson));
                    break;
                }
                case FILE: {
                    message = EMMessage.createReceiveMessage(Type.FILE);
                    message.addBody(MessageBodyHelper.fileBodyFromJson(bodyJson));
                    break;
                }
                case CMD: {
                    message = EMMessage.createReceiveMessage(Type.CMD);
                    message.addBody(MessageBodyHelper.cmdBodyFromJson(bodyJson));
                    break;
                }
                case CUSTOM: {
                    message = EMMessage.createReceiveMessage(Type.CUSTOM);
                    message.addBody(MessageBodyHelper.customBodyFromJson(bodyJson));
                    break;
                }

                case COMBINE: {
                    message = EMMessage.createReceiveMessage(Type.COMBINE);
                    message.addBody(MessageBodyHelper.combineBodyFromJson(bodyJson));
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
        if (EnumTools.messageStatusFromInt(json.getInt("status")) == EMMessage.Status.SUCCESS) {
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

        message.setStatus(EnumTools.messageStatusFromInt(json.getInt("status")));
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
        message.setChatType(EnumTools.chatTypeFromInt(json.getInt("chatType")));
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
                data.put("body", MessageBodyHelper.textBodyToJson((EMTextMessageBody) message.getBody()));
            }
                break;
            case IMAGE: {
                data.put("body", MessageBodyHelper.imageBodyToJson((EMImageMessageBody) message.getBody()));
            }
                break;
            case LOCATION: {
                data.put("body", MessageBodyHelper.localBodyToJson((EMLocationMessageBody) message.getBody()));
            }
                break;
            case CMD: {
                data.put("body", MessageBodyHelper.cmdBodyToJson((EMCmdMessageBody) message.getBody()));
            }
                break;
            case CUSTOM: {
                data.put("body", MessageBodyHelper.customBodyToJson((EMCustomMessageBody) message.getBody()));
            }
                break;
            case FILE: {
                data.put("body", MessageBodyHelper.fileBodyToJson((EMNormalFileMessageBody) message.getBody()));
            }
                break;
            case VIDEO: {
                data.put("body", MessageBodyHelper.videoBodyToJson((EMVideoMessageBody) message.getBody()));
            }
                break;
            case VOICE: {
                data.put("body", MessageBodyHelper.voiceBodyToJson((EMVoiceMessageBody) message.getBody()));
            }
                break;
            case COMBINE:{
                data.put("body", MessageBodyHelper.combineBodyToJson((EMCombineMessageBody) message.getBody()));
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
        data.put("status", EnumTools.messageStatusToInt(message.status()));
        data.put("chatType", EnumTools.chatTypeToInt(message.getChatType()));
        data.put("direction", EnumTools.messageDirectToInt(message.direct()));
        data.put("conversationId", message.conversationId());
        data.put("msgId", message.getMsgId());
        data.put("hasRead", !message.isUnread());
        data.put("needGroupAck", message.isNeedGroupAck());
        data.put("onlineState", message.isOnlineState());
        data.put("broadcast", message.isBroadcast());
        data.put("isContentReplaced", message.isContentReplaced());

        // 通过EMMessageWrapper获取
        // data.put("groupAckCount", message.groupAckCount());
        data.put("isThread", message.isChatThreadMessage());
        return data;
    }
}

class GroupAckHelper {
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


 class MessageBodyHelper {

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
        data.put("type", EnumTools.messageBodyTypeToInt(Type.TXT));
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
        data.put("type", EnumTools.messageBodyTypeToInt(Type.LOCATION));
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
        data.put("type", EnumTools.messageBodyTypeToInt(Type.CMD));
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
        data.put("type", EnumTools.messageBodyTypeToInt(Type.CUSTOM));
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
        body.setDownloadStatus(EnumTools.downloadStatusFromInt(json.getInt("fileStatus")));
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
        data.put("fileStatus", EnumTools.downloadStatusToInt(body.downloadStatus()));
        data.put("type", EnumTools.messageBodyTypeToInt(Type.FILE));
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
            body.setDownloadStatus(EnumTools.downloadStatusFromInt(json.getInt("fileStatus")));
        }

        return body;
    }

    static Map<String, Object> imageBodyToJson(EMImageMessageBody body) {
        Map<String, Object> data = getParentMap(body);
        data.put("localPath", body.getLocalUrl());
        data.put("displayName", body.getFileName());
        data.put("remotePath", body.getRemoteUrl());
        data.put("secret", body.getSecret());
        data.put("fileStatus", EnumTools.downloadStatusToInt(body.downloadStatus()));
        data.put("thumbnailLocalPath", body.thumbnailLocalPath());
        data.put("thumbnailRemotePath", body.getThumbnailUrl());
        data.put("thumbnailSecret", body.getThumbnailSecret());
        data.put("thumbnailStatus", EnumTools.downloadStatusToInt(body.thumbnailDownloadStatus()));
        data.put("height", body.getHeight());
        data.put("width", body.getWidth());
        data.put("sendOriginalImage", body.isSendOriginalImage());
        data.put("fileSize", body.getFileSize());
        data.put("type", EnumTools.messageBodyTypeToInt(Type.IMAGE));
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
            body.setDownloadStatus(EnumTools.downloadStatusFromInt(json.getInt("fileStatus")));
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
        data.put("thumbnailStatus", EnumTools.downloadStatusToInt(body.thumbnailDownloadStatus()));
        data.put("displayName", body.getFileName());
        data.put("height", body.getThumbnailHeight());
        data.put("width", body.getThumbnailWidth());
        data.put("remotePath", body.getRemoteUrl());
        data.put("fileStatus", EnumTools.downloadStatusToInt(body.downloadStatus()));
        data.put("secret", body.getSecret());
        data.put("fileSize", body.getVideoFileLength());
        data.put("type", EnumTools.messageBodyTypeToInt(Type.VIDEO));

        return data;
    }

    static EMVoiceMessageBody voiceBodyFromJson(JSONObject json) throws JSONException {
        String localPath = json.getString("localPath");
        File file = new File(localPath);
        int duration = json.getInt("duration");
        EMVoiceMessageBody body = new EMVoiceMessageBody(file, duration);
        body.setDownloadStatus(EnumTools.downloadStatusFromInt(json.getInt("fileStatus")));
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
        data.put("fileStatus", EnumTools.downloadStatusToInt(body.downloadStatus()));
        data.put("secret", body.getSecret());
        data.put("type", EnumTools.messageBodyTypeToInt(Type.VOICE));
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
         ret.setDownloadStatus(EnumTools.downloadStatusFromInt(json.getInt("fileStatus")));

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

        data.put("fileStatus", EnumTools.downloadStatusToInt(body.downloadStatus()));
        data.put("type", EnumTools.messageBodyTypeToInt(Type.COMBINE));

        return data;
    }
}

class ConversationHelper {

    static Map<String, Object> toJson(EMConversation conversation) {
        Map<String, Object> data = new HashMap<>();
        data.put("convId", conversation.conversationId());
        data.put("type", EnumTools.conversationTypeToInt(conversation.getType()));
        data.put("isThread", conversation.isChatThread());
        data.put("isPinned", conversation.isPinned());
        data.put("pinnedTime", conversation.getPinnedTime());
        if(conversation.marks() != null) {
            ArrayList<Integer> list = new ArrayList<>();
            for (EMConversation.EMMarkType type: conversation.marks()) {
                list.add(type.ordinal());
            }
            data.put("marks", list);
        }
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

class DeviceInfoHelper {

    static Map<String, Object> toJson(EMDeviceInfo device) {
        Map<String, Object> data = new HashMap<>();
        data.put("resource", device.getResource());
        data.put("deviceUUID", device.getDeviceUUID());
        data.put("deviceName", device.getDeviceName());

        return data;
    }
}

class CursorResultHelper {

    static Map<String, Object> toJson(EMCursorResult result) {
        Map<String, Object> data = new HashMap<>();
        data.put("cursor", result.getCursor());
        List<Object> jsonList = new ArrayList<>();
        if (result.getData() != null){
            List list = (List) result.getData();
            for (Object obj : list) {
                if (obj instanceof EMMessage) {
                    jsonList.add(MessageHelper.toJson((EMMessage) obj));
                }

                if (obj instanceof EMGroup) {
                    jsonList.add(GroupHelper.toJson((EMGroup) obj));
                }

                if (obj instanceof EMChatRoom) {
                    jsonList.add(ChatRoomHelper.toJson((EMChatRoom) obj));
                }

                if (obj instanceof EMGroupReadAck) {
                    jsonList.add(GroupAckHelper.toJson((EMGroupReadAck) obj));
                }

                if (obj instanceof String) {
                    jsonList.add(obj);
                }

                if (obj instanceof EMGroupInfo) {
                    jsonList.add(GroupInfoHelper.toJson((EMGroupInfo) obj));
                }

                if (obj instanceof EMMessageReaction) {
                    jsonList.add(MessageReactionHelper.toJson((EMMessageReaction) obj));
                }

                if (obj instanceof EMChatThread) {
                    jsonList.add(ChatThreadHelper.toJson((EMChatThread) obj));
                }

                if (obj instanceof EMConversation) {
                    jsonList.add(ConversationHelper.toJson((EMConversation) obj));
                }

                if (obj instanceof EMContact) {
                    jsonList.add(ContactHelper.toJson((EMContact) obj));
                }
            }
        }
        data.put("list", jsonList);

        return data;
    }
}

class PageResultHelper {

    static Map<String, Object> toJson(EMPageResult result) {
        Map<String, Object> data = new HashMap<>();
        data.put("count", result.getPageCount());
        List<Map> jsonList = new ArrayList<>();
        if (result.getData() != null){
            List list = (List) result.getData();
            for (Object obj : list) {
                if (obj instanceof EMMessage) {
                    jsonList.add(MessageHelper.toJson((EMMessage) obj));
                }

                if (obj instanceof EMGroup) {
                    jsonList.add(GroupHelper.toJson((EMGroup) obj));
                }

                if (obj instanceof EMChatRoom) {
                    jsonList.add(ChatRoomHelper.toJson((EMChatRoom) obj));
                }
            }
        }
        data.put("list", jsonList);
        return data;
    }
}

class ErrorHelper {
    static Map<String, Object> toJson(int errorCode, String desc) {
        Map<String, Object> data = new HashMap<>();
        data.put("code", errorCode);
        data.put("description", desc);
        return data;
    }
}

class PushConfigsHelper {
    static Map<String, Object> toJson(EMPushConfigs pushConfigs) {
        Map<String, Object> data = new HashMap<>();
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

class UserInfoHelper {
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

class PresenceHelper {

    static Map<String, Object> toJson(EMPresence presence) {
        Map<String, Object> data = new HashMap<>();
        data.put("publisher", presence.getPublisher());
        data.put("statusDescription", presence.getExt());
        data.put("lastTime", presence.getLatestTime());
        data.put("expiryTime", presence.getExpiryTime());
        Map<String, Integer> statusList = new HashMap<String, Integer>(presence.getStatusList());
        data.put("statusDetails", statusList);
        return data;
    }

}

class LanguageHelper {
    static Map<String, Object> toJson(EMLanguage language) {
        Map<String, Object> data = new HashMap<>();
        data.put("code", language.LanguageCode);
        data.put("name", language.LanguageName);
        data.put("nativeName", language.LanguageLocalName);
        return data;
    }
}

class MessageReactionHelper {
    static Map<String, Object> toJson(EMMessageReaction reaction) {
        Map<String, Object> data = new HashMap<>();
        data.put("reaction", reaction.getReaction());
        data.put("count", reaction.getUserCount());
        data.put("isAddedBySelf", reaction.isAddedBySelf());
        data.put("userList", reaction.getUserList());
        return data;
    }
}

class MessageReactionChangeHelper {
    static Map<String, Object> toJson(EMMessageReactionChange change) {
        Map<String, Object> data = new HashMap<>();
        data.put("conversationId", change.getConversionID());
        data.put("messageId", change.getMessageId());
        ArrayList<Map<String, Object>> reactions = new ArrayList<>();
        for (int i = 0; i < change.getMessageReactionList().size(); i++) {
            reactions.add(MessageReactionHelper.toJson(change.getMessageReactionList().get(i)));
        }
        data.put("reactions", reactions);

        ArrayList<Map<String, Object>> operations = new ArrayList<>();
        for (int i = 0; i < change.getOperations().size(); i++) {
            operations.add(MessageReactionOperationHelper.toJson(change.getOperations().get(i)));
        }
        data.put("operations", operations);

        return data;
    }
}

class MessageReactionOperationHelper {
    static Map<String, Object> toJson(EMMessageReactionOperation operation) {
        Map<String, Object> data = new HashMap<>();
        data.put("userId", operation.getUserId());
        data.put("reaction", operation.getReaction());
        data.put("operate", EnumTools.reactionOperationToInt(operation.getOperation()));
        return data;
    }
}

class ChatThreadHelper {
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
        if (thread.getLastMessage() != null && thread.getLastMessage().getMsgId().length() > 0) {
            data.put("lastMessage", MessageHelper.toJson(thread.getLastMessage()));
        }
        return data;
    }
}

class ChatThreadEventHelper {
    static Map<String, Object> toJson(EMChatThreadEvent event) {
        Map<String, Object> data = new HashMap<>();
        data.put("type", EnumTools.threadOperationToInt(event.getType()));
        data.put("from", event.getFrom());
        if (event.getChatThread() != null) {
            data.put("thread", ChatThreadHelper.toJson(event.getChatThread()));
        }
        return data;
    }
}


class SilentModeParamHelper {
    static EMSilentModeParam fromJson(JSONObject obj) throws JSONException {
        EMSilentModeParam.EMSilentModeParamType type = EnumTools.silentModeParamTypeFromInt(obj.getInt("paramType"));
        EMSilentModeParam param = new EMSilentModeParam(type);
        if (obj.has("startTime") && obj.has("endTime")) {
            EMSilentModeTime startTime = SilentModeTimeHelper.fromJson(obj.getJSONObject("startTime"));
            EMSilentModeTime endTime = SilentModeTimeHelper.fromJson(obj.getJSONObject("endTime"));
            param.setSilentModeInterval(startTime, endTime);
        }

        if (obj.has("remindType")) {
            param.setRemindType(EnumTools.remindTypeFromInt(obj.getInt("remindType")));
        }

        if (obj.has("duration")) {
            int duration = obj.getInt("duration");
            param.setSilentModeDuration(duration);
        }
        return param;
    }
}

class SilentModeTimeHelper {
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

class SilentModeResultHelper {
    static Map<String, Object> toJson(EMSilentModeResult modeResult) {
        Map<String, Object> data = new HashMap<>();
        data.put("expireTs", modeResult.getExpireTimestamp());
        if (modeResult.getConversationId() != null) {
            data.put("conversationId", modeResult.getConversationId());
        }
        if (modeResult.getConversationType() != null) {
            data.put("conversationType", EnumTools.conversationTypeToInt(modeResult.getConversationType()));
        }
        if (modeResult.getSilentModeStartTime() != null) {
            data.put("startTime", SilentModeTimeHelper.toJson(modeResult.getSilentModeStartTime()));
        }
        if (modeResult.getSilentModeEndTime() != null) {
            data.put("endTime", SilentModeTimeHelper.toJson(modeResult.getSilentModeEndTime()));
        }if (modeResult.getRemindType() != null) {
            data.put("remindType", EnumTools.remindTypeToInt(modeResult.getRemindType()));
        }

        return data;
    }
}

class FetchHistoryOptionsHelper {
    static EMFetchMessageOption fromJson(JSONObject json) throws JSONException {
        EMFetchMessageOption options = new EMFetchMessageOption();
        EMConversation.EMSearchDirection direction = EnumTools.searchDirectionFromInt(json.optInt("direction"));
        options.setDirection(direction);
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
                Type type = EnumTools.messageBodyTypeFromInt(array.getInt(i));
                list.add(type);
            }
            if (list.size() > 0) {
                options.setMsgTypes(list);
            }
        }

        return options;
    }
}

// 450
class MessagePinInfoHelper {
    static Map<String, Object> toJson(EMMessagePinInfo info) {
        Map<String, Object> data = new HashMap<>();
        data.put("pinTime", info.pinTime());
        data.put("operatorId", info.operatorId());
        return data;
    }
}

class ConversationFilterHelper {
    static EMConversationFilter fromJson(JSONObject json) throws JSONException {
        EMConversation.EMMarkType markType = EMConversation.EMMarkType.values()[json.getInt("mark")];
        int pageSize = json.getInt("pageSize");
        EMConversationFilter filter = new EMConversationFilter(markType, pageSize);
        return filter;
    }

    static String cursor(JSONObject json) throws JSONException {
        if(json.has("cursor")){
            return  json.getString("cursor");
        }else {
            return null;
        }
    }

    static Boolean pinned(JSONObject json) throws JSONException {
        if(json.has("pinned")) {
            return json.getBoolean("pinned");
        }
        else {
            return false;
        }
    }

    static Boolean hasMark(JSONObject json) throws JSONException {
        return json.has("mark");
    }

    static int pageSize(JSONObject json) throws  JSONException {
        if(json.has("pageSize")) {
            return json.getInt("pageSize");
        }else {
            return 0;
        }
    }
}

 class RecallMessageInfoHelper {
    static Map<String, Object> toJson(EMRecallMessageInfo info) {
        Map<String, Object> data = new HashMap<>();
        data.put("recallMsgId", info.getRecallMessageId());
        data.put("recallBy", info.getRecallBy());
        if(info.getExt() != null) {
            data.put("ext", info.getExt());
        }
        if(info.getRecallMessage() != null) {
            data.put("msg", MessageHelper.toJson(info.getRecallMessage()));
        }

        // 4.10
        if(info.getConversationId() != null) {
            data.put("conversationId", info.getConversationId());
        }
        return data;
    }
 }


 // 481
class LoginExtensionInfoHelper {
     static Map<String, Object> toJson(EMLoginExtensionInfo info) {
         Map<String, Object> data = new HashMap<>();
         data.put("deviceName", info.getDeviceInfo());
         data.put("ext", info.getDeviceExt());

         return data;
     }
 }