package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMCmdMessageBody;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMImageMessageBody;
import com.hyphenate.chat.EMLocationMessageBody;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessageBody;
import com.hyphenate.chat.EMNormalFileMessageBody;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.chat.EMVideoMessageBody;
import com.hyphenate.chat.EMVoiceMessageBody;
import com.hyphenate.util.EMLog;

import java.util.HashMap;
import java.util.Map;

class EMHelper {
    static EMMessage convertDataMapToMessage(Map<String, Object> args) {
        return null;
    }

    static Map<String, Object> convertEMMessageToStringMap(EMMessage message) {
        Map<String, Object> ss = new HashMap<String, Object>();
        ss.put("dfs","asd");
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("attributes",ss);
        result.put("conversationId", message.conversationId());
        result.put("type", 0);
        result.put("type", getType(message));
        result.put("userName", message.getUserName());
        result.put("acked", Boolean.valueOf(message.isAcked()));
        result.put("body", convertEMMessageBodyToStringMap(message.getBody()));
        result.put("chatType", 0);
        result.put("chatType", getChatType(message));
        result.put("delivered", Boolean.valueOf(message.isDelivered()));
        result.put("direction", 0);
        result.put("direction", getDirect(message));
        result.put("from", message.getFrom());
        result.put("listened", Boolean.valueOf(message.isListened()));
        result.put("localTime", message.localTime());
        result.put("msgId", message.getMsgId());
        result.put("msgTime", message.getMsgTime());
        result.put("progress", message.progress());
        result.put("status", 0);
        result.put("status", getEMMessageStatus(message));
        result.put("to", message.getTo());
        result.put("unread", Boolean.valueOf(message.isUnread()));
        EMLog.e("EMHelper",result.toString());
        return result;
    }

    static Map<String, Object> convertEMMessageBodyToStringMap(EMMessageBody mb) {
        Map<String, Object> result = new HashMap<String, Object>();
        Map<String, Object> body = new HashMap<String, Object>();
        // check EMMessageBody type
        if (mb instanceof EMTextMessageBody) {
            EMTextMessageBody txtMessageBody = (EMTextMessageBody) mb;
//            body.put("type", EMMessage.Type.TXT);
            body.put("type", 0);
            body.put("message", txtMessageBody.getMessage());
        } else if (mb instanceof EMCmdMessageBody) {
            EMCmdMessageBody cmdMessageBody = (EMCmdMessageBody) mb;
            body.put("type", EMMessage.Type.CMD);
            body.put("action", cmdMessageBody.action());
            body.put("params", cmdMessageBody.getParams());
            body.put("isDeliverOnlineOnly", Boolean.valueOf(cmdMessageBody.isDeliverOnlineOnly()));
        }else if(mb instanceof EMLocationMessageBody) {
            EMLocationMessageBody locationMessageBody = (EMLocationMessageBody) mb;
            body.put("type", EMMessage.Type.LOCATION);
            body.put("address", locationMessageBody.getAddress());
            body.put("latitude", locationMessageBody.getLatitude());
            body.put("longitude", locationMessageBody.getLongitude());
        }else if(mb instanceof EMNormalFileMessageBody) {
            EMNormalFileMessageBody normalFileMessageBody = (EMNormalFileMessageBody)mb;
            body.put("type", EMMessage.Type.FILE);
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
            body.put("type", EMMessage.Type.IMAGE);
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
            body.put("type", EMMessage.Type.VOICE);
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
            body.put("type", EMMessage.Type.VIDEO);
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
        result.put("body", body);
        return result;
    }

    static Map<String, Object> convertEMConversationToStringMap(EMConversation conversation) {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", conversation.conversationId());
        result.put("type", conversation.getType());
        result.put("ext", conversation.getExtField());
        return result;
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
    static Integer getChatType(EMMessage message){
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
    static Integer getDirect(EMMessage message){
        switch (message.direct()){
            case SEND:
                return 0;
            case RECEIVE:
                return 1;
            default:
                return null;
        }
    }

    /**
     * \~chinese
     * 消息的发送/接收状态：成功，失败，发送/接收过程中，创建成功待发送
     *
     * \~english
     * message status  0：成功  1：失败  2：发送/接收过程中 3：创建成功待发送
     */
    static Integer getEMMessageStatus(EMMessage message){
        switch (message.status()){
            case SUCCESS:
                return 0;
            case FAIL:
                return 1;
            case INPROGRESS:
                return 2;
            case CREATE:
                return 3;
            default:
                return null;
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
    static Integer getType(EMMessage message){
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
                return null;
        }
    }

}
