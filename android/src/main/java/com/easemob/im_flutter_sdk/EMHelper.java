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

import java.util.HashMap;
import java.util.Map;

class EMHelper {
    static EMMessage convertDataMapToMessage(Map<String, Object> args) {
        return null;
    }

    static Map<String, Object> convertEMMessageToStringMap(EMMessage message) {
        Map<String, Object> result = new HashMap<String, Object>();
        //result.put("attributes", ?);
        result.put("conversationId", message.conversationId());
        result.put("type", message.getType());
        result.put("userName", message.getUserName());
        result.put("acked", Boolean.valueOf(message.isAcked()));
        result.put("body", convertEMMessageBodyToStringMap(message.getBody()));
        result.put("chatType", message.getChatType());
        result.put("delivered", Boolean.valueOf(message.isDelivered()));
        result.put("direction", message.direct());
        result.put("from", message.getFrom());
        result.put("listened", Boolean.valueOf(message.isListened()));
        result.put("localTime", message.localTime());
        result.put("msgId", message.getMsgId());
        result.put("msgTime", message.getMsgTime());
        result.put("progress", message.progress());
        result.put("status", message.status());
        result.put("to", message.getTo());
        result.put("unread", Boolean.valueOf(message.isUnread()));
        return result;
    }

    static Map<String, Object> convertEMMessageBodyToStringMap(EMMessageBody mb) {
        Map<String, Object> result = new HashMap<String, Object>();
        Map<String, Object> body = new HashMap<String, Object>();
        // check EMMessageBody type
        if (mb instanceof EMTextMessageBody) {
            EMTextMessageBody txtMessageBody = (EMTextMessageBody) mb;
            body.put("type", EMMessage.Type.TXT);
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
}
