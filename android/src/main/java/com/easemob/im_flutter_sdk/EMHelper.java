package com.easemob.im_flutter_sdk;

import android.content.Context;
import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.text.TextUtils;

import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMCmdMessageBody;
import com.hyphenate.chat.EMContact;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMConversation.EMConversationType;
import com.hyphenate.chat.EMConversation.EMSearchDirection;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupInfo;
import com.hyphenate.chat.EMImageMessageBody;
import com.hyphenate.chat.EMLocationMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessage.Type;
import com.hyphenate.chat.EMMessageBody;
import com.hyphenate.chat.EMMucSharedFile;
import com.hyphenate.chat.EMNormalFileMessageBody;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMPageResult;
import com.hyphenate.chat.EMPushConfigs;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMVideoMessageBody;
import com.hyphenate.chat.EMVoiceMessageBody;
import com.hyphenate.push.EMPushConfig;
import com.hyphenate.util.EMLog;
import com.hyphenate.util.PathUtil;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

@SuppressWarnings("unchecked")
class EMHelper {

    private static EMMessage.ChatType emChatType;

    //Incomplete implementation
    static EMMessage convertDataMapToMessage(JSONObject args) {
        EMMessage message = null;
        try {
            EMLog.d("convertDataMapToMessage", args.toString());

            int data_type =args.getInt("type");
            int data_chatType = args.getInt("chatType");


            emChatType = EMMessage.ChatType.Chat;
            intToChatType(data_chatType);

            String data_to = args.getString("to");
            JSONObject data_body = args.getJSONObject("body");

            switch(data_type){
                case 0:
                    message = EMMessage.createSendMessage(EMMessage.Type.TXT);
                    String content = data_body.getString("message");
                    EMTextMessageBody body = new EMTextMessageBody(content);
                    message.addBody(body);
                    setCurrency(message,emChatType,data_to);
                    setExt(args,message);
                    break;
                case 1:
                    message = EMMessage.createSendMessage(Type.IMAGE);
                    String localUrl = data_body.getString("localUrl");
                    File imageFile = new File(localUrl);
                    if (imageFile.exists()){
                        EMImageMessageBody imageMessageBody = new EMImageMessageBody(imageFile);
                        message.addBody(imageMessageBody);
                        setCurrency(message,emChatType,data_to);
                    }
                    setExt(args,message);
                    break;
                case 2:
                    message = EMMessage.createSendMessage(Type.VIDEO);
                    String videoUrl = data_body.getString("localUrl");
                    int videoDuration = data_body.getInt("videoDuration");
                    String fileLength = data_body.getString("fileLength");
                    File videoFile = new File(videoUrl);
                    if (videoFile.exists()){
                        EMVideoMessageBody videoMessageBody = new EMVideoMessageBody(videoUrl,getThumbBitmap(videoUrl),videoDuration,Integer.parseInt(fileLength));
                        message.addBody(videoMessageBody);
                        setCurrency(message,emChatType,data_to);
                    }
                    setExt(args,message);
                    break;
                case 3:
                    message = EMMessage.createSendMessage(Type.LOCATION);
                    String address = data_body.getString("address");
                    double latitude = data_body.getDouble("latitude");
                    double longitude = data_body.getDouble("longitude");
                    EMLocationMessageBody emLocationMessageBody = new EMLocationMessageBody(address, latitude, longitude);
                    message.addBody(emLocationMessageBody);
                    setCurrency(message,emChatType,data_to);
                    setExt(args,message);
                    break;
                case 4:
                    message = EMMessage.createSendMessage(Type.VOICE);
                    String voiceUrl = data_body.getString("localUrl");
                    int voiceDuration = data_body.getInt("voiceDuration");
                    File voiceFile = new File(voiceUrl);
                    if (voiceFile.exists()){
                        EMVoiceMessageBody videoMessageBody = new EMVoiceMessageBody(voiceFile,voiceDuration);
                        message.addBody(videoMessageBody);
                        setCurrency(message,emChatType,data_to);
                    }
                    setExt(args,message);
                    break;
                case 5:
                    message = EMMessage.createSendMessage(Type.FILE);
                    String fileUrl = data_body.getString("localUrl");
                    File file = new File(fileUrl);
                    if (file.exists()){
                        EMNormalFileMessageBody fileMessageBody = new EMNormalFileMessageBody(file);
                        message.addBody(fileMessageBody);
                        setCurrency(message,emChatType,data_to);
                    }
                    setExt(args,message);
                    break;
                case 6:
                    message = EMMessage.createSendMessage(Type.CMD);
                    String action = data_body.getString("action");
                    EMCmdMessageBody cmdMessageBody = new EMCmdMessageBody(action);
                    message.addBody(cmdMessageBody);
                    setCurrency(message,emChatType,data_to);
                    setExt(args,message);
                    break;
            }
            if(message == null) return null;

            if (args.getString("msgId") != null && !TextUtils.isEmpty(args.getString("msgId"))) {
                message.setMsgId(args.getString("msgId"));
            }


            if (!TextUtils.isEmpty(args.getString("msgTime"))) {
                String msgTime = args.getString("msgTime");
                message.setMsgTime(Long.parseLong(msgTime));
            }

            if (!TextUtils.isEmpty(args.getString("localTime"))) {
                String localTime = args.getString("localTime");
                message.setLocalTime(Long.parseLong(localTime));
            }

            if (args.getInt("direction") == 0) {
                message.setDirection(EMMessage.Direct.SEND);
            } else {
                message.setDirection(EMMessage.Direct.RECEIVE);
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        return message;
    }

    static EMMessage updateDataMapToMessage(JSONObject args){
        EMMessage message = null;
        try {
            String msgid = args.getString("msgId");
            message = EMClient.getInstance().chatManager().getMessage(msgid);
            if(message == null){
                EMLog.e("EMHelper","Message is null object");
                return null;
            }
            message.setAcked(args.getBoolean("acked"));
            message.setDeliverAcked(args.getBoolean("deliverAcked"));
            message.setDelivered(args.getBoolean("delivered"));
            message.setListened(args.getBoolean("listened"));
            message.setLocalTime(Long.valueOf(args.getString("localTime")));
            message.setMsgTime(Long.valueOf(args.getString("msgTime")));
            message.setUnread(args.getBoolean("unread"));
            setExt(args,message);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return message;
    }

    private static void setExt(JSONObject args, EMMessage message){
        try {
            if (null != args.getJSONObject("attributes")){
                JSONObject data = args.getJSONObject("attributes");
                Iterator iterator = data.keys();
                while (iterator.hasNext()){
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
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private static void setCurrency(EMMessage message,EMMessage.ChatType type,String to){
        message.setChatType(type);
        message.setTo(to);
    }

    public static void intToChatType(int type){
        switch (type){
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
    }

    private static String getThumbBitmap(String videoPath){
        File file = new File(PathUtil.getInstance().getImagePath(), "thvideo" + System.currentTimeMillis());
        try {
            FileOutputStream fos = new FileOutputStream(file);
            Bitmap ThumbBitmap = ThumbnailUtils.createVideoThumbnail(videoPath, 3);
            ThumbBitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
            fos.close();
            return file.getAbsolutePath();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 将EMMessage 对象解析并包装成 Map
     * @param message
     * @return
     */
    static Map<String, Object> convertEMMessageToStringMap(EMMessage message) {
        Map<String, Object> result = new HashMap<String, Object>();
        if (message.ext().size() > 0 && null != message.ext()){
            result.put("attributes", message.ext());
        }else{
            ///扩展不能为空 设置一个默认值
            HashMap<String,String> map = new HashMap<>();
            map.put("easemob","flutter");
            result.put("attributes", map);
        }
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
        result.put("localTime", String.valueOf(message.localTime()));
        result.put("msgId", message.getMsgId());
        result.put("msgTime", String.valueOf(message.getMsgTime()));
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
            body.put("downloadStatus", normalFileMessageBody.downloadStatus());
            body.put("localUrl", normalFileMessageBody.getLocalUrl());
            body.put("remoteUrl", normalFileMessageBody.getRemoteUrl());
            // subclass fields
            body.put("fileSize", normalFileMessageBody.getFileSize());
        }else if(mb instanceof EMImageMessageBody) {
            EMImageMessageBody imageMessageBody = (EMImageMessageBody)mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.IMAGE));
            // base EMFileMessageBody fields
            body.put("displayName", imageMessageBody.displayName());
            body.put("downloadStatus", imageMessageBody.downloadStatus());
            body.put("localUrl", imageMessageBody.getLocalUrl());
            body.put("remoteUrl", imageMessageBody.getRemoteUrl());
            // specific subclass fields
            body.put("height", imageMessageBody.getHeight());
            body.put("width", imageMessageBody.getWidth());
            body.put("sendOriginalImage", Boolean.valueOf(imageMessageBody.isSendOriginalImage()));
            body.put("thumbnailLocalPath", imageMessageBody.thumbnailLocalPath());
            body.put("thumbnailUrl", imageMessageBody.getThumbnailUrl());
        }else if(mb instanceof EMVoiceMessageBody) {
            EMVoiceMessageBody voiceMessageBody = (EMVoiceMessageBody)mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.VOICE));
            // base EMFileMessageBody fields
            body.put("displayName", voiceMessageBody.displayName());
            body.put("downloadStatus", voiceMessageBody.downloadStatus());
            body.put("localUrl", voiceMessageBody.getLocalUrl());
            body.put("remoteUrl", voiceMessageBody.getRemoteUrl());
            // subclass fields
            body.put("length", voiceMessageBody.getLength());
            body.put("voiceDuration", voiceMessageBody.getLength());
        }else if(mb instanceof EMVideoMessageBody) {
            EMVideoMessageBody videoMessageBody = (EMVideoMessageBody)mb;
            body.put("type", enumMessageTypeToInt(EMMessage.Type.VIDEO));
            // base EMFileMessageBody fields
            body.put("displayName", videoMessageBody.displayName());
            body.put("downloadStatus", videoMessageBody.downloadStatus());
            body.put("localUrl", videoMessageBody.getLocalUrl());
            body.put("remoteUrl", videoMessageBody.getRemoteUrl());
            // subclass fields
            body.put("videoDuration", videoMessageBody.getDuration());
            body.put("localThumb", videoMessageBody.getLocalThumb());
            body.put("thumbnailHeight", videoMessageBody.getThumbnailHeight());
            body.put("thumbnailWidth", videoMessageBody.getThumbnailWidth());
            body.put("thumbnailUrl", videoMessageBody.getThumbnailUrl());
            body.put("fileLength", videoMessageBody.getVideoFileLength());
//            body.put("status", videoMessageBody.thumbnailDownloadStatus());
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
        result.put("type", convertEMConversationTypeToInt(conversation.getType()));
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
        if (emChatRoom.getMuteList() != null && emChatRoom.getMuteList().size() > 0) {
            List list = new LinkedList();
//            emChatRoom.getMuteList().forEach((k, v) ->{
//                list.add(k);
//            });
            for (Map.Entry<String, Long> m :  emChatRoom.getMuteList().entrySet()){
                list.add(m.getKey());
            }
            chatRoomMap.put("muteList",list);
        }
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
        if(list.size() == 0){
            list = new LinkedList();
            result.put("data", list);
            return result;
        }

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

    /**
     * 将JSONObject 解析并封装给EMOptions
     * @param json
     * @return
     */
    static EMOptions convertStringMapToEMOptions(JSONObject json, Context context){
        EMOptions options = new EMOptions();
        try {
            options.setAppKey(json.getString("appKey"));
            if(!json.getString("acceptInvitationAlways").isEmpty()){
                options.setAcceptInvitationAlways(json.getBoolean("acceptInvitationAlways"));
            }
            if(!json.getString("autoAcceptGroupInvitation").isEmpty()){
                options.setAutoAcceptGroupInvitation(json.getBoolean("autoAcceptGroupInvitation"));
            }
            if(!json.getString("requireAck").isEmpty()){
                options.setRequireAck(json.getBoolean("requireAck"));
            }
            if(!json.getString("requireDeliveryAck").isEmpty()){
                options.setRequireDeliveryAck(json.getBoolean("requireDeliveryAck"));
            }
            if(!json.getString("deleteMessagesAsExitGroup").isEmpty()){
                options.setDeleteMessagesAsExitGroup(json.getBoolean("deleteMessagesAsExitGroup"));
            }
            if(!json.getString("isChatRoomOwnerLeaveAllowed").isEmpty()){
                options.allowChatroomOwnerLeave(json.getBoolean("isChatRoomOwnerLeaveAllowed"));
            }
            if(!json.getString("autoLogin").isEmpty()){
                options.setAutoLogin(json.getBoolean("autoLogin"));
            }
            if(!json.getString("sortMessageByServerTime").isEmpty()){
                options.setSortMessageByServerTime(json.getBoolean("sortMessageByServerTime"));
            }
            if(!json.getString("enableDNSConfig").isEmpty()){
                options.enableDNSConfig(json.getBoolean("enableDNSConfig"));
            }
            if(!json.getString("dnsUrl").isEmpty()){
                options.setDnsUrl(json.getString("dnsUrl"));
            }
            if(!json.getString("restServer").isEmpty()) {
                options.setRestServer(json.getString("restServer"));
            }
            if(!json.getString("imServer").isEmpty()) {
                options.setIMServer(json.getString("imServer"));
            }
            if(!(json.getInt("imPort") == 0)) {
                options.setImPort(json.getInt("imPort"));
            }
            if(json.getBoolean("usingHttpsOnly")) {
                options.setUsingHttpsOnly(true);
            }
            if(!json.getBoolean("serverTransfer")) {
                options.setAutoTransferMessageAttachments(false);
            }
            if(!json.getBoolean("isAutoDownload")) {
                options.setAutoDownloadThumbnail(false);
            }
            JSONObject pushConfig = json.getJSONObject("pushConfig");
            EMPushConfig.Builder builder = new EMPushConfig.Builder(context);
            if(pushConfig.getBoolean("enableVivoPush")){
                builder.enableVivoPush();
            }
            if(pushConfig.getBoolean("enableMeiZuPush")){
                builder.enableMeiZuPush(pushConfig.getString("mzAppId"), pushConfig.getString("mzAppKey"));
            }
            if(pushConfig.getBoolean("enableMiPush")){
                builder.enableMiPush(pushConfig.getString("miAppId"), pushConfig.getString("miAppKey"));
            }
            if(pushConfig.getBoolean("enableOppoPush")){
                builder.enableOppoPush(pushConfig.getString("oppoAppKey"), pushConfig.getString("oppoAppSecret"));
            }
            if(pushConfig.getBoolean("enableHWPush")){
                builder.enableHWPush();
            }
            if(pushConfig.getBoolean("enableFCM")){
                builder.enableFCM(pushConfig.getString("fcmSenderId"));
            }
            options.setPushConfig(builder.build());
        }catch (JSONException e){
            e.printStackTrace();
        }
        return options;
    }

    /**
     * 将EMDeviceInfo 对象解析并包装成 Map
     * @param device
     * @return
     */
    static Map<String, Object> convertDevicesToStringMap(EMDeviceInfo device){
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("resource", device.getResource());
        result.put("UUID", device.getDeviceUUID());
        result.put("name", device.getDeviceName());
        return result;
    }

    static Map<String, Object> convertContactToStringMap(EMContact contact) {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("userName", contact.getUsername());
        result.put("nickName", contact.getNickname());
        return result;
    }

    static Map<String, Object> convertEMPushConfigsToStringMap(EMPushConfigs configs) {
        Map<String, Object> result = new HashMap<String, Object>();
        if(configs == null){
            return result;
        }
        result.put("nickName", configs.getDisplayNickname());
        result.put("noDisturbOn", configs.isNoDisturbOn());
        result.put("startHour", configs.getNoDisturbStartHour());
        result.put("endHour", configs.getNoDisturbEndHour());
        result.put("displayStyle", 0);
        return result;
    }

}
