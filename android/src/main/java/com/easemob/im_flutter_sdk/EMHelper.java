package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessageBody;

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
        result.put("body", convertEMMessageBodyToStringMap(message.getBody())); //TODO: EMMessageBody mapping impl.
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
        result.put("body", mb.toString()); //TODO: EMMessageBody data mapping
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
