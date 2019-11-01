package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCmdMessageBody;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMConversation.EMConversationType;
import com.hyphenate.chat.EMConversation.EMSearchDirection;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupInfo;
import com.hyphenate.chat.EMImageMessageBody;
import com.hyphenate.chat.EMLocationMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessage.Type;
import com.hyphenate.chat.EMMessageBody;
import com.hyphenate.chat.EMMucSharedFile;
import com.hyphenate.chat.EMNormalFileMessageBody;
import com.hyphenate.chat.EMPageResult;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMVideoMessageBody;
import com.hyphenate.chat.EMVoiceMessageBody;
import com.hyphenate.chat.adapter.EMAGroup;
import com.hyphenate.util.EMLog;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

@SuppressWarnings("unchecked")
class EMHelper {
    //Incomplete implementation
    static EMMessage convertDataMapToMessage(JSONObject args) {
        EMMessage message = null;
        try {
            EMLog.d("convertDataMapToMessage", args.toString());

            int data_type = Integer.parseInt(args.getString("type"));
            int data_chatType = Integer.parseInt(args.getString("chatType"));
            EMMessage.ChatType emChatType = EMMessage.ChatType.Chat;
            switch (data_chatType){
                case 0:
                    emChatType = EMMessage.ChatType.Chat;
                    break;
                case 1:
                    emChatType = EMMessage.ChatType.GroupChat;
                    break;
                case 2:
                    emChatType = EMMessage.ChatType.ChatRoom;
                    break;
            }
            String data_to = args.getString("to");
            JSONObject data_body = args.getJSONObject("body");
            String content = data_body.getString("message");

//            String data_msgid = args.getString("msgid");
//            JSONObject data_attributes = args.getJSONObject("attributes");
//            TXT, IMAGE, VIDEO, LOCATION, VOICE, FILE, CMD
            switch(data_type){
                case 0:
                    message = EMMessage.createSendMessage(EMMessage.Type.TXT);
                    EMTextMessageBody body = new EMTextMessageBody(content);
                    message.addBody(body);
                    message.setChatType(emChatType);
                    message.setTo(data_to);
                    break;
                case 1:
                    break;
                case 2:
                    break;
                case 3:
                    break;
                case 4:
                    break;
                case 5:
                    break;
                case 6:
                    break;
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        return message;
    }

    /**
     * 将EMMessage 对象解析并包装成 Map
     * @param message
     * @return
     */
    static Map<String, Object> convertEMMessageToStringMap(EMMessage message) {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("attributes", message.ext());
        result.put("conversationId", message.conversationId());
        result.put("type", getType(message));
        result.put("userName", message.getUserName());
        result.put("acked", Boolean.valueOf(message.isAcked()));
        result.put("body", convertEMMessageBodyToStringMap(message.getBody()));
        result.put("chatType", getChatType(message));
        result.put("delivered", Boolean.valueOf(message.isDelivered()));
        result.put("direction", getDirect(message));
        result.put("from", message.getFrom());
        result.put("listened", Boolean.valueOf(message.isListened()));
        result.put("localTime", message.localTime());
        result.put("msgId", message.getMsgId());
        result.put("msgTime", message.getMsgTime());
        result.put("progress", message.progress());
        result.put("status", getEMMessageStatus(message));
        result.put("to", message.getTo());
        result.put("unread", Boolean.valueOf(message.isUnread()));
        EMLog.e("EMHelper",result.toString());
        return result;
    }

    /**
     * 将EMMessageBody 对象解析并包装成 Map
     * @param mb
     * @return
     */
    static Map<String, Object> convertEMMessageBodyToStringMap(EMMessageBody mb) {
        Map<String, Object> body = new HashMap<String, Object>();
        // check EMMessageBody type
        if (mb instanceof EMTextMessageBody) {
            EMTextMessageBody txtMessageBody = (EMTextMessageBody) mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.TXT));
            body.put("message", txtMessageBody.getMessage());
        } else if (mb instanceof EMCmdMessageBody) {
            EMCmdMessageBody cmdMessageBody = (EMCmdMessageBody) mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.CMD));
            body.put("action", cmdMessageBody.action());
            body.put("params", cmdMessageBody.getParams());
            body.put("isDeliverOnlineOnly", Boolean.valueOf(cmdMessageBody.isDeliverOnlineOnly()));
        }else if(mb instanceof EMLocationMessageBody) {
            EMLocationMessageBody locationMessageBody = (EMLocationMessageBody) mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.LOCATION));
            body.put("address", locationMessageBody.getAddress());
            body.put("latitude", locationMessageBody.getLatitude());
            body.put("longitude", locationMessageBody.getLongitude());
        }else if(mb instanceof EMNormalFileMessageBody) {
            EMNormalFileMessageBody normalFileMessageBody = (EMNormalFileMessageBody)mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.FILE));
            // base EMFileMessageBody fields
            body.put("displayName", normalFileMessageBody.displayName());
            body.put("status", normalFileMessageBody.downloadStatus());
            body.put("fileName", normalFileMessageBody.getFileName());
            body.put("localUrl", normalFileMessageBody.getLocalUrl());
            body.put("remoteUrl", normalFileMessageBody.getRemoteUrl());
            body.put("secret", normalFileMessageBody.getSecret());
            // subclass fields
            body.put("fileSize", normalFileMessageBody.getFileSize());
        }else if(mb instanceof EMImageMessageBody) {
            EMImageMessageBody imageMessageBody = (EMImageMessageBody)mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.IMAGE));
            // base EMFileMessageBody fields
            body.put("displayName", imageMessageBody.displayName());
            body.put("status", imageMessageBody.downloadStatus());
            body.put("fileName", imageMessageBody.getFileName());
            body.put("localUrl", imageMessageBody.getLocalUrl());
            body.put("remoteUrl", imageMessageBody.getRemoteUrl());
            body.put("secret", imageMessageBody.getSecret());
            // specific subclass fields
            body.put("height", imageMessageBody.getHeight());
            body.put("width", imageMessageBody.getWidth());
            body.put("sendOriginalImage", Boolean.valueOf(imageMessageBody.isSendOriginalImage()));
            body.put("thumbnailLocalPath", imageMessageBody.thumbnailLocalPath());
            body.put("thumbnailSecret", imageMessageBody.getThumbnailSecret());
            body.put("thumbnailUrl", imageMessageBody.getThumbnailUrl());
        }else if(mb instanceof EMVoiceMessageBody) {
            EMVoiceMessageBody voiceMessageBody = (EMVoiceMessageBody)mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.VOICE));
            // base EMFileMessageBody fields
            body.put("displayName", voiceMessageBody.displayName());
            body.put("status", voiceMessageBody.downloadStatus());
            body.put("fileName", voiceMessageBody.getFileName());
            body.put("localUrl", voiceMessageBody.getLocalUrl());
            body.put("remoteUrl", voiceMessageBody.getRemoteUrl());
            body.put("secret", voiceMessageBody.getSecret());
            // subclass fields
            body.put("length", voiceMessageBody.getLength());
        }else if(mb instanceof EMVideoMessageBody) {
            EMVideoMessageBody videoMessageBody = (EMVideoMessageBody)mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.VIDEO));
            // base EMFileMessageBody fields
            body.put("displayName", videoMessageBody.displayName());
            body.put("status", videoMessageBody.downloadStatus());
            body.put("fileName", videoMessageBody.getFileName());
            body.put("localUrl", videoMessageBody.getLocalUrl());
            body.put("remoteUrl", videoMessageBody.getRemoteUrl());
            body.put("secret", videoMessageBody.getSecret());
            // subclass fields
            body.put("duration", videoMessageBody.getDuration());
            body.put("localThumb", videoMessageBody.getLocalThumb());
            body.put("thumbnailHeight", videoMessageBody.getThumbnailHeight());
            body.put("thumbnailWidth", videoMessageBody.getThumbnailWidth());
            body.put("thumbnailSecret", videoMessageBody.getThumbnailSecret());
            body.put("thumbnailUrl", videoMessageBody.getThumbnailUrl());
            body.put("videoFileLength", videoMessageBody.getVideoFileLength());
            body.put("status", videoMessageBody.thumbnailDownloadStatus());
        }
        return body;
    }

    /**
     * 将conversation 对象解析并包装成 Map
     * @param conversation
     * @return
     */
    static Map<String, Object> convertEMConversationToStringMap(EMConversation conversation) {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", conversation.conversationId());
        result.put("type", conversation.getType());
        result.put("ext", conversation.getExtField());
        return result;
    }

    /**
     * 将EMChatRoom 对象解析并包装成 Map
     * @param emChatRoom
     * @return
     */
    static Map<String, Object> convertEMChatRoomToStringMap(EMChatRoom emChatRoom) {
        Map<String, Object> chatRoomMap = new HashMap<String, Object>();
        chatRoomMap.put("roomId",emChatRoom.getId());
        chatRoomMap.put("roomName",emChatRoom.getName());
        chatRoomMap.put("description",emChatRoom.getDescription());
        chatRoomMap.put("owner",emChatRoom.getOwner());
        chatRoomMap.put("adminList",emChatRoom.getAdminList());
        chatRoomMap.put("affiliationsCount",emChatRoom.getMemberCount());
        chatRoomMap.put("maxUsers",emChatRoom.getMaxUsers());
        chatRoomMap.put("memberList",emChatRoom.getMemberList());
        chatRoomMap.put("blackList",emChatRoom.getBlackList());
        chatRoomMap.put("muteList",emChatRoom.getMuteList());
        chatRoomMap.put("announcement",emChatRoom.getAnnouncement());
        String currentUser = EMClient.getInstance().getCurrentUser();
        for (String s : emChatRoom.getMemberList()) {
            if (currentUser.equals(s)){
                chatRoomMap.put("permissionType",0);
            }
        }
        for (String s : emChatRoom.getAdminList()) {
            if (currentUser.equals(s)){
                chatRoomMap.put("permissionType",1);
            }
        }
        if (currentUser.equals(emChatRoom.getOwner())){
            chatRoomMap.put("permissionType",2);
        }
        return chatRoomMap;
    }

    /**
     * 将EMPageResult 对象解析并包装成 Map
     * @param result
     * @return
     */
    static Map<String, Object> convertEMPageResultToStringMap(EMPageResult result) {
        List list = (List)result.getData();
        String className = list.get(0).getClass().getSimpleName();
        Map<String, Object> pageResult = new HashMap<String, Object>();
        pageResult.put("pageCount", result.getPageCount());
        if(className.equals("EMChatRoom")){
            List list1 = new LinkedList();
            for (Object o : list) {
                list1.add(convertEMChatRoomToStringMap((EMChatRoom) o));
            }
            pageResult.put("data",list1);
        }
        return pageResult;
    }


    /**
     * \~chinese
     * 获取聊天类型
     * @return ChatType
     *
     * \~english
     * get chat type  默认单聊
     *  @return ChatType   0: Chat(单聊)  1: GroupChat(群聊)  2: ChatRoom(聊天室)
     */
    static int getChatType(EMMessage message){
        switch (message.getChatType()){
            case GroupChat:
                return 1;
            case ChatRoom:
                return 2;
            default:
                return 0;
        }
    }

    /**
     * \~chinese
     * 消息方向
     *
     * \~english
     * the message direction  0：发送方   1：接收方
     */
    static int getDirect(EMMessage message){
        switch (message.direct()){
            case SEND:
                return 0;
            case RECEIVE:
                return 1;
            default:
                return -1;
        }
    }

    /**
     * \~chinese
     * 消息的发送/接收状态：成功，失败，发送/接收过程中，创建成功待发送
     *
     * \~english
     * message status  0：成功  1：失败  2：发送/接收过程中 3：创建成功待发送
     */
    static int getEMMessageStatus(EMMessage message){
        switch (message.status()){
            case SUCCESS:
                return 0;
            case FAIL:
                return 1;
            case INPROGRESS:
                return 2;
            default:
                return 3;
        }
    }

    /**
     * \chinese
     * 获取消息类型
     * @return
     *
     * \~english
     * get message chat type
     * @return
     */
    static int getType(EMMessage message){
        switch (message.getType()){
            case TXT:
                return 0;
            case IMAGE:
                return 1;
            case VIDEO:
                return 2;
            case LOCATION:
                return 3;
            case VOICE:
                return 4;
            case FILE:
                return 5;
            case CMD:
                return 6;
            default:
                return -1;
        }
    }

    /**
     *  枚举消息类型转int（Flutter不支持传枚举类型）
     * @param type
     * @return
     */
    static int enumMessageTypeToInt(EMMessage.Type type) {
        switch (type) {
            case TXT:
                return 0;
            case IMAGE:
                return 1;
            case VIDEO:
                return 2;
            case LOCATION:
                return 3;
            case VOICE:
                return 4;
            case FILE:
                return 5;
            case CMD:
                return 6;
            default:
                return -1;
        }
    }
    /**
     * 将EMGroup 对象解析并包装成 Map
     * @param group
     * @return
     */
    static Map<String, Object> convertEMGroupToStringMap(EMGroup group){
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("groupId", group.getGroupId());
        result.put("groupName", group.getGroupName());
        result.put("description", group.getDescription());
        result.put("isPublic", group.isPublic());
        result.put("isMemberAllowToInvite", group.isMemberAllowToInvite());
        result.put("isMemberOnly", group.isMemberOnly());
        result.put("maxUserCount", group.getMaxUserCount());
        result.put("isMsgBlocked", group.isMsgBlocked());
        result.put("owner", group.getOwner());
        result.put("members", group.getMembers());
        result.put("memberCount", group.getMemberCount());
        result.put("adminList", group.getAdminList());
        result.put("blackList", group.getBlackList());
        result.put("muteList", group.getMuteList());
        result.put("extension", group.getExtension());
        result.put("announcement", group.getAnnouncement());
        List<Map<String, Object>> fileList = new LinkedList<>();
        for(EMMucSharedFile file : group.getShareFileList()){
            fileList.add(convertEMMucSharedFileToStringMap(file));
        }
        result.put("sharedFileList", fileList);

        List occupants = new LinkedList();
        occupants.add(group.getOwner());
        occupants.addAll(group.getAdminList());
        occupants.addAll(group.getMembers());
        result.put("occupants", occupants);

        int permissionType = -1;
        if(group.getMembers().contains(EMClient.getInstance().getCurrentUser())){
            permissionType = 0;
        }
        if(group.getAdminList().contains(EMClient.getInstance().getCurrentUser())){
            permissionType = 1;
        }
        if(EMClient.getInstance().getCurrentUser().equals(group.getOwner())){
            permissionType = 2;
        }
        result.put("permissionType", permissionType);

        List noPushGroups = EMClient.getInstance().pushManager().getNoPushGroups();
        boolean isPushNotificationEnabled = false;
        if (noPushGroups != null) {
            if(noPushGroups.contains(group.getGroupId())){
                isPushNotificationEnabled = true;
            }
        }
        result.put("isPushNotificationEnabled", isPushNotificationEnabled);
        return result;
    }

    static EMConversationType convertIntToEMConversationType(int type){
        if(type == 0){
            return EMConversationType.Chat;
        }
        if(type == 1){
            return EMConversationType.GroupChat;
        }
        if(type == 2){
            return EMConversationType.ChatRoom;
        }
        if(type == 3){
            return EMConversationType.DiscussionGroup;
        }
        if(type == 4){
            return EMConversationType.HelpDesk;
        }
        return EMConversationType.Chat;
    }

    static int convertEMConversationTypeToInt(EMConversationType type){
        if(type == EMConversationType.Chat){
            return 0;
        }
        if(type == EMConversationType.GroupChat){
            return 1;
        }
        if(type == EMConversationType.ChatRoom){
            return 2;
        }
        if(type == EMConversationType.DiscussionGroup){
            return 3;
        }
        if(type == EMConversationType.HelpDesk){
            return 4;
        }
        return 0;
    }


    static int convertEMSearchDirectionToInt(EMSearchDirection type){
        if(type == EMSearchDirection.UP){
            return 0;
        }
        if(type == EMSearchDirection.DOWN){
            return 1;
        }
        return 0;
    }

    static EMSearchDirection convertIntToEMSearchDirection(int type){
        if(type == 0){
            return EMSearchDirection.UP;
        }
        if(type == 1){
            return EMSearchDirection.DOWN;
        }
        return EMSearchDirection.UP;
    }

    static int convertEMMessageTypeToInt(Type type){
        if(type == Type.TXT){
            return 0;
        }
        if(type == Type.IMAGE){
            return 1;
        }
        if(type == Type.VIDEO){
            return 2;
        }
        if(type == Type.LOCATION){
            return 3;
        }
        if(type == Type.VOICE){
            return 4;
        }
        if(type == Type.FILE){
            return 5;
        }
        if(type == Type.CMD){
            return 6;
        }
        return 0;
    }

    static Type convertIntToEMMessageType(int type){

        if(type == 0){
            return Type.TXT;
        }
        if(type == 1){
            return Type.IMAGE;
        }
        if(type == 2){
            return Type.VIDEO;
        }
        if(type == 3){
            return Type.LOCATION;
        }
        if(type == 4){
            return Type.VOICE;
        }
        if(type == 5){
            return Type.FILE;
        }
        if(type == 6){
            return Type.CMD;
        }
        return Type.TXT;
    }

    /**
     * 将EMCursorResult 对象解析并包装成 Map
     * @param emCursorResult
     * @return
     */
    static Map<String, Object> convertEMCursorResultToStringMap(EMCursorResult emCursorResult){
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("cursor", emCursorResult.getCursor());
        List list = (List)emCursorResult.getData();
        String className = list.get(0).getClass().getSimpleName();
        if(className.equals("String")){
            result.put("data", list);
        }
        if(className.equals("EMGroupInfo")){
            List<EMGroupInfo> infoList = list;
            List<Map<String, Object>> data = new LinkedList();
            for(EMGroupInfo info : infoList){
                data.add(convertGroupInfoToStringMap(info));
            }
            result.put("data", data);
        }
        return result;
    }

    static Map<String, Object> convertGroupInfoToStringMap(EMGroupInfo info){
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("groupId", info.getGroupId());
        result.put("groupName", info.getGroupName());
        return result;
    }

    /**
     * 将EMMucSharedFile 对象解析并包装成 Map
     * @param file
     * @return
     */
    static Map<String, Object> convertEMMucSharedFileToStringMap(EMMucSharedFile file){
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("fileId", file.getFileId());
        result.put("fileName", file.getFileName());
        result.put("fileOwner", file.getFileOwner());
        result.put("updateTime", file.getFileUpdateTime());
        result.put("fileSize", file.getFileSize());
        return result;
    }

}
