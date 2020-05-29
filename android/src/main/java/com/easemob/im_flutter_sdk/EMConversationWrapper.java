package com.easemob.im_flutter_sdk;

import java.util.ArrayList;
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
import com.hyphenate.util.EMLog;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import static com.easemob.im_flutter_sdk.EMHelper.convertIntToEMMessageType;
import static com.easemob.im_flutter_sdk.EMHelper.convertIntToEMSearchDirection;

@SuppressWarnings("unchecked")
public class EMConversationWrapper implements MethodCallHandler, EMWrapper{
    private EMChatManager manager;

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        // init manager
        if(manager == null) {
            manager = EMClient.getInstance().chatManager();
        }
        if (EMSDKMethod.getUnreadMsgCount.equals(call.method)) {
            getUnreadMessageCount(call.arguments, result);
        } else if (EMSDKMethod.markAllMessagesAsRead.equals(call.method)) {
            markAllMessagesAsRead(call.arguments, result);
        } else if (EMSDKMethod.loadMoreMsgFromDB.equals(call.method)) {
            loadMoreMsgFromDB(call.arguments, result);
        } else if (EMSDKMethod.searchConversationMsgFromDB.equals(call.method)) {
            searchMsgFromDB(call.arguments, result);
        } else if (EMSDKMethod.searchConversationMsgFromDBByType.equals(call.method)) {
            searchMsgFromDBByType(call.arguments, result);
        } else if (EMSDKMethod.getMessage.equals(call.method)) {
            getMessage(call.arguments, result);
        } else if (EMSDKMethod.loadMessages.equals(call.method)) {
            loadMessages(call.arguments, result);
        } else if (EMSDKMethod.markMessageAsRead.equals((call.method))) {
            markMessageAsRead(call.arguments, result);
        } else if (EMSDKMethod.removeMessage.equals(call.method)) {
            removeMessage(call.arguments, result);
        } else if (EMSDKMethod.getLastMessage.equals(call.method)) {
            getLastMessage(call.arguments, result);
        } else if (EMSDKMethod.getLatestMessageFromOthers.equals(call.method)) {
            getLatestMessageFromOthers(call.arguments, result);
        } else if (EMSDKMethod.clear.equals(call.method)) {
            clear(call.arguments, result);
        } else if (EMSDKMethod.clearAllMessages.equals(call.method)) {
            clearAllMessages(call.arguments, result);
        } else if (EMSDKMethod.insertMessage.equals(call.method)) {
            insertMessage(call.arguments, result);
        } else if (EMSDKMethod.appendMessage.equals(call.method)) {
            appendMessage(call.arguments, result);
        } else if (EMSDKMethod.updateConversationMessage.equals(call.method)) {
            updateMessage(call.arguments, result);
        } else if (EMSDKMethod.getMessageAttachmentPath.equals(call.method)) {
            getMessageAttachmentPath(call.arguments, result);
        }
    }

    private EMConversation getConversation(String id) {
        return manager.getConversation(id);
    }

    private void getUnreadMessageCount(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            int count = getConversation(id).getUnreadMsgCount();
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("count", Integer.valueOf(count));
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void markAllMessagesAsRead(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            getConversation(id).markAllMessagesAsRead();
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void loadMoreMsgFromDB(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            String startMsgId = argMap.getString("startMsgId");
            int pageSize = argMap.getInt("pageSize");
            List<EMMessage> list = getConversation(id).loadMoreMsgFromDB(startMsgId, pageSize);
            List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
            for (EMMessage message : list) {
                messages.add(EMHelper.convertEMMessageToStringMap(message));
            }
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("messages", messages);
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void searchMsgFromDB(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            String keywords = argMap.getString("keywords");
            String from = argMap.getString("from");
            Integer timeStamp = argMap.getInt("timeStamp");
            Integer maxCount = (Integer)argMap.get("maxCount");
            int direction = argMap.getInt("direction");
            List<EMMessage> list = getConversation(id).searchMsgFromDB(keywords,timeStamp,maxCount,from,convertIntToEMSearchDirection(direction));
            List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
            for (EMMessage message : list) {
                messages.add(EMHelper.convertEMMessageToStringMap(message));
            }
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("messages", messages);
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void searchMsgFromDBByType(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            int type = argMap.getInt("type");
            String from = argMap.getString("from");
            String timeStamp = argMap.getString("timeStamp");
            int maxCount = argMap.getInt("maxCount");
            int direction = argMap.getInt("direction");
            List<EMMessage> list = getConversation(id).searchMsgFromDB(convertIntToEMMessageType(type), Long.parseLong(timeStamp), maxCount, from, convertIntToEMSearchDirection(direction));
            List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
            for (EMMessage message : list) {
                messages.add(EMHelper.convertEMMessageToStringMap(message));
            }
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("messages", messages);
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getMessage(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            String messageId = argMap.getString("messageId");
            Boolean markAsRead = argMap.getBoolean("markAsRead");
            EMMessage message = getConversation(id).getMessage(messageId, markAsRead.booleanValue());
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("message", EMHelper.convertEMMessageToStringMap(message));
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void loadMessages(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            JSONArray json_msgIds = argMap.getJSONArray("messages");
            List<String> msgIds = new ArrayList<>();
            for(int i = 0; i < json_msgIds.length(); i++){
                msgIds.add(json_msgIds.getString(i));
            }
            List<EMMessage> list = getConversation(id).loadMessages(msgIds);
            List<Map<String, Object>> messages = new LinkedList<Map<String, Object>>();
            for (EMMessage message : list) {
                messages.add(EMHelper.convertEMMessageToStringMap(message));
            }
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("messages", messages);
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void markMessageAsRead(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            String messageId = argMap.getString("messageId");
            getConversation(id).markMessageAsRead(messageId);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void removeMessage(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            String messageId = argMap.getString("messageId");
            getConversation(id).removeMessage(messageId);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getLastMessage(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            Map<String, Object> data = new HashMap<String, Object>();
            if(getConversation(id).getAllMsgCount() > 0) {
                EMMessage message = getConversation(id).getLastMessage();
                data.put("success", Boolean.TRUE);
                data.put("message", EMHelper.convertEMMessageToStringMap(message));
            } else {
                data.put("success", Boolean.FALSE);
            }
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});

        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getLatestMessageFromOthers(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            Map<String, Object> data = new HashMap<String, Object>();
            if(getConversation(id).getAllMsgCount() > 0) {
                EMMessage message = getConversation(id).getLatestMessageFromOthers();
                data.put("success", Boolean.TRUE);
                data.put("message", EMHelper.convertEMMessageToStringMap(message));
            } else {
                data.put("success", Boolean.FALSE);
            }
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void clear(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            getConversation(id).clear();
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void clearAllMessages(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            getConversation(id).clearAllMessages();
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void insertMessage(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            EMMessage message = EMHelper.convertDataMapToMessage((JSONObject) argMap.get("msg"));
            getConversation(id).insertMessage(message);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void appendMessage(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            EMMessage message = EMHelper.convertDataMapToMessage((JSONObject)argMap.get("msg"));
            getConversation(id).appendMessage(message);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void updateMessage(Object args, Result result) {
        Map<String, Object> data = null;
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            data = new HashMap<String, Object>();
            EMMessage message = EMHelper.convertDataMapToMessage((JSONObject)argMap.get("msg"));
            if (message != null){
                getConversation(id).updateMessage(message);
                data.put("success", Boolean.TRUE);
            }
            result.success(data);
        }catch (JSONException e){
            data.put("success", Boolean.FALSE);
            data.put("error", e.getMessage());
            result.success(data);
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getMessageAttachmentPath(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String id = argMap.getString("id");
            String path = getConversation(id).getMessageAttachmentPath();
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("path", path);
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }
}
