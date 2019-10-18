package com.easemob.im_flutter_sdk;

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.LinkedList;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.hyphenate.chat.EMChatManager;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;

@SuppressWarnings("unchecked")
public class EMConversationWrapper implements MethodCallHandler, EMWrapper{
    private EMChatManager manager;

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        // init manager
        if(manager == null) {
            manager = EMClient.getInstance().chatManager();
        }
        Map<String, Object> argMap = (Map<String, Object>) call.arguments;
        if (EMSDKMethod.getUnreadMsgCount.equals(call.method)) {
            getUnreadMessageCount(argMap, result);
        } else if (EMSDKMethod.markAllMessagesAsRead.equals(call.method)) {
            markAllMessagesAsRead(argMap, result);
        } else if (EMSDKMethod.getAllMsgCount.equals(call.method)) {
            getAllMsgCount(argMap, result);
        } else if (EMSDKMethod.loadMoreMsgFromDB.equals(call.method)) {
            loadMoreMsgFromDB(argMap, result);
        } else if (EMSDKMethod.searchConversationMsgFromDB.equals(call.method)) {
            searchMsgFromDB(argMap, result);
        } else if (EMSDKMethod.searchConversationMsgFromDBByType.equals(call.method)) {
            searchMsgFromDBByType(argMap, result);
        } else if (EMSDKMethod.getMessage.equals(call.method)) {
            getMessage(argMap, result);
        } else if (EMSDKMethod.getAllMessages.equals(call.method)) {
            getAllMessages(argMap, result);
        } else if (EMSDKMethod.loadMessages.equals(call.method)) {
            loadMessages(argMap, result);
        } else if (EMSDKMethod.markMessageAsRead.equals((call.method))) {
            markMessageAsRead(argMap, result);
        } else if (EMSDKMethod.removeMessage.equals(call.method)) {
            removeMessage(argMap, result);
        } else if (EMSDKMethod.getLastMessage.equals(call.method)) {
            getLastMessage(argMap, result);
        } else if (EMSDKMethod.getLatestMessageFromOthers.equals(call.method)) {
            getLatestMessageFromOthers(argMap, result);
        } else if (EMSDKMethod.clear.equals(call.method)) {
            clear(argMap, result);
        } else if (EMSDKMethod.clearAllMessages.equals(call.method)) {
            clearAllMessages(argMap, result);
        } else if (EMSDKMethod.insertMessage.equals(call.method)) {
            insertMessage(argMap, result);
        } else if (EMSDKMethod.appendMessage.equals(call.method)) {
            appendMessage(argMap, result);
        } else if (EMSDKMethod.updateConversationMessage.equals(call.method)) {
            updateMessage(argMap, result);
        } else if (EMSDKMethod.getMessageAttachmentPath.equals(call.method)) {
            getMessageAttachmentPath(argMap, result);
        }
    }

    private Map<String, EMConversation> conversations = new HashMap<String, EMConversation>();

    // getConversation - returns cached conversation of id,
    // otherwise call EMManager to get from server
    private EMConversation getConversation(String id) {
        EMConversation cachedConversation =  conversations.get(id);
        if(cachedConversation == null) {
            cachedConversation = manager.getConversation(id);
            if(cachedConversation != null){
                conversations.put(id, cachedConversation);
            }
        }
        return cachedConversation;
    }

    private void getUnreadMessageCount(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        int count = getConversation(id).getUnreadMsgCount();
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("count", Integer.valueOf(count));
        result.success(data);
    }

    private void markAllMessagesAsRead(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        getConversation(id).markAllMessagesAsRead();
    }

    private void getAllMsgCount(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        int count = getConversation(id).getAllMsgCount();
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("count", Integer.valueOf(count));
        result.success(data);
    }

    private void loadMoreMsgFromDB(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        String startMsgId = (String)argMap.get("startMsgId");
        Integer pageSize = (Integer)argMap.get("pageSize");
        List<EMMessage> list = getConversation(id).loadMoreMsgFromDB(startMsgId, pageSize.intValue());
        List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
        list.forEach(message->{
            messages.add(EMHelper.convertEMMessageToStringMap(message));
        });
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("messages", messages);
        result.success(data);
    }

    private void searchMsgFromDB(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        String keywords = (String)argMap.get("keywords");
        String from = (String)argMap.get("from");
        Integer timeStamp = (Integer)argMap.get("timeStamp");
        Integer maxCount = (Integer)argMap.get("maxCount");
        EMConversation.EMSearchDirection direction = (EMConversation.EMSearchDirection)argMap.get("direction");
        List<EMMessage> list = getConversation(id).searchMsgFromDB(keywords,timeStamp,maxCount,from,direction);
        List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
        list.forEach(message->{
            messages.add(EMHelper.convertEMMessageToStringMap(message));
        });
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("messages", messages);
        result.success(data);
    }

    private void searchMsgFromDBByType(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        EMMessage.Type type = (EMMessage.Type) argMap.get("type");
        String from = (String)argMap.get("from");
        Integer timeStamp = (Integer)argMap.get("timeStamp");
        Integer maxCount = (Integer)argMap.get("maxCount");
        EMConversation.EMSearchDirection direction = (EMConversation.EMSearchDirection)argMap.get("direction");
        List<EMMessage> list = getConversation(id).searchMsgFromDB(type, timeStamp.longValue(), maxCount.intValue(), from, direction);
        List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
        list.forEach(message->{
            messages.add(EMHelper.convertEMMessageToStringMap(message));
        });
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("messages", messages);
        result.success(data);
    }

    private void getMessage(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        String messageId = (String)argMap.get("messageId");
        Boolean markAsRead = (Boolean)argMap.get("markAsRead");
        EMMessage message = getConversation(id).getMessage(messageId, markAsRead.booleanValue());
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("message", EMHelper.convertEMMessageToStringMap(message));
        result.success(data);
    }

    private void getAllMessages(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        List<EMMessage> list = getConversation(id).getAllMessages();
        List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
        list.forEach(message->{
            messages.add(EMHelper.convertEMMessageToStringMap(message));
        });
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("messages", messages);
        result.success(data);
    }

    private void loadMessages(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        List<String> msgIds = (List<String>)argMap.get("messages");
        List<EMMessage> list = getConversation(id).loadMessages(msgIds);
        List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
        list.forEach(message->{
            messages.add(EMHelper.convertEMMessageToStringMap(message));
        });
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("messages", messages);
        result.success(data);
    }

    private void markMessageAsRead(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        String messageId = (String)argMap.get("messageId");
        getConversation(id).markMessageAsRead(messageId);
    }

    private void removeMessage(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        String messageId = (String)argMap.get("messageId");
        getConversation(id).removeMessage(messageId);
    }

    private void getLastMessage(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        EMMessage message = getConversation(id).getLastMessage();
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("message", EMHelper.convertEMMessageToStringMap(message));
        result.success(data);
    }

    private void getLatestMessageFromOthers(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        EMMessage message = getConversation(id).getLatestMessageFromOthers();
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("message", EMHelper.convertEMMessageToStringMap(message));
        result.success(data);
    }

    private void clear(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        getConversation(id).clear();
    }

    private void clearAllMessages(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        getConversation(id).clearAllMessages();
    }

    private void insertMessage(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        EMMessage message = EMHelper.convertDataMapToMessage((Map<String, Object>)argMap.get("msg"));
        getConversation(id).insertMessage(message);
    }

    private void appendMessage(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        EMMessage message = EMHelper.convertDataMapToMessage((Map<String, Object>)argMap.get("msg"));
        getConversation(id).appendMessage(message);
    }

    private void updateMessage(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        EMMessage message = EMHelper.convertDataMapToMessage((Map<String, Object>)argMap.get("msg"));
        getConversation(id).updateMessage(message);
    }

    private void getMessageAttachmentPath(Map<String,Object> argMap, Result result) {
        String id = (String)argMap.get("id");
        String path = getConversation(id).getMessageAttachmentPath();
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("path", path);
        result.success(data);
    }
}
