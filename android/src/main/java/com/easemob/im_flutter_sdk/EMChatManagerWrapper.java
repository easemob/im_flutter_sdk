package com.easemob.im_flutter_sdk;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMMessageListener;
import com.hyphenate.chat.EMChatManager;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;


@SuppressWarnings("unchecked")
public class EMChatManagerWrapper implements MethodCallHandler, EMWrapper{
    // delegates all methods call to this manager
    private EMChatManager manager = null;
    // method channel for event broadcast back to flutter
    private MethodChannel channel;
    // cursor result map for call back getCursor()
    private Map<String, EMCursorResult<EMMessage>> cursorResultList = new HashMap<String, EMCursorResult<EMMessage>>();

    EMChatManagerWrapper(MethodChannel channel) {
        this.channel = channel;
    }

    private void init() {
        //setup message listener
        manager.addMessageListener(new EMMessageListener() {
            @Override
            public void onMessageReceived(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                ArrayList<Map<String, Object>> msgs = new ArrayList<>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                EMLog.e("onMessageReceived->>",data.toString());
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onMessageReceived, data);
                    }});
            }

            @Override
            public void onCmdMessageReceived(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                ArrayList<Map<String, Object>> msgs = new ArrayList<Map<String, Object>>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onCmdMessageReceived, data);
                    }});
            }

            @Override
            public void onMessageRead(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                ArrayList<Map<String, Object>> msgs = new ArrayList<Map<String, Object>>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onMessageRead, data);
                    }});
            }

            @Override
            public void onMessageDelivered(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                ArrayList<Map<String, Object>> msgs = new ArrayList<Map<String, Object>>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onMessageDelivered, data);
                    }});
            }

            @Override
            public void onMessageRecalled(List<EMMessage> messages) {
                Map<String, Object> data = new HashMap<String, Object>();
                ArrayList<Map<String, Object>> msgs = new ArrayList<Map<String, Object>>();
                for(EMMessage message : messages) {
                    msgs.add(EMHelper.convertEMMessageToStringMap(message));
                }
                data.put("messages", msgs);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onMessageRecalled, data);
                    }});
            }

            @Override
            public void onMessageChanged(EMMessage message, Object change) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("message", EMHelper.convertEMMessageToStringMap(message));
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onMessageChanged, data);
                    }});

            }
        });
        //setup conversation listener
        manager.addConversationListener(() -> {
            Map<String, Object> data = new HashMap<String, Object>();
            post(new Runnable() {
                @Override
                public void run() {
                    channel.invokeMethod(EMSDKMethod.onConversationUpdate,data);
                }});
        });
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if(manager == null) {
            manager = EMClient.getInstance().chatManager();
            init();
        }
        if (EMSDKMethod.sendMessage.equals(call.method)) {
            sendMessage(call.arguments, result);
        } else if (EMSDKMethod.ackMessageRead.equals(call.method)) {
            ackMessageRead(call.arguments, result);
        } else if (EMSDKMethod.recallMessage.equals(call.method)) {
            recallMessage(call.arguments, result);
        } else if (EMSDKMethod.getMessage.equals(call.method)) {
            getMessage(call.arguments, result);
        }else if(EMSDKMethod.getConversation.equals(call.method)) {
            getConversation(call.arguments, result);
        }else if(EMSDKMethod.markAllChatMsgAsRead.equals(call.method)) {
            markAllConversationsAsRead(call.arguments, result);
        }else if(EMSDKMethod.getUnreadMessageCount.equals(call.method)) {
            getUnreadMessageCount(call.arguments,result);
        }else if(EMSDKMethod.saveMessage.equals(call.method)) {
            saveMessage(call.arguments, result);
        }else if(EMSDKMethod.updateChatMessage.equals(call.method)) {
            updateMessage(call.arguments, result);
        }else if(EMSDKMethod.downloadAttachment.equals(call.method)) {
            downloadAttachment(call.arguments, result);
        }else if(EMSDKMethod.downloadThumbnail.equals(call.method)) {
            downloadThumbnail(call.arguments, result);
        }else if(EMSDKMethod.importMessages.equals(call.method)) {
            importMessages(call.arguments, result);
        }else if(EMSDKMethod.getConversationsByType.equals(call.method)) {
            getConversationsByType(call.arguments, result);
        }else if(EMSDKMethod.downloadFile.equals(call.method)) {
            downloadFile(call.arguments, result);
        }else if(EMSDKMethod.getAllConversations.equals(call.method)) {
            getAllConversations(call.arguments, result);
        }else if(EMSDKMethod.loadAllConversations.equals(call.method)) {
            loadAllConversations(call.arguments, result);
        }else if(EMSDKMethod.deleteConversation.equals(call.method)) {
            deleteConversation(call.arguments, result);
        }else if(EMSDKMethod.setVoiceMessageListened.equals(call.method)) {
            setVoiceMessageListened(call.arguments, result);
        }else if(EMSDKMethod.updateParticipant.equals(call.method)) {
            updateParticipant(call.arguments, result);
        }else if(EMSDKMethod.fetchHistoryMessages.equals(call.method)) {
            fetchHistoryMessages(call.arguments, result);
        }else if(EMSDKMethod.searchChatMsgFromDB.equals(call.method)) {
            searchMsgFromDB(call.arguments, result);
        }else if(EMSDKMethod.getCursor.equals(call.method)) {
            getCursor(call.arguments, result);
        }

    }

    private void sendMessage(Object args, Result result) {
        JSONObject argMap = (JSONObject)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        String localMsgId = message.getMsgId();
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        message.setMessageStatusCallback(new EMCallBack() {
            @Override
            public void onSuccess() {
                        Map<String, Object> data = new HashMap<String, Object>();
                        data.put("success", Boolean.TRUE);
                        data.put("message", EMHelper.convertEMMessageToStringMap(message));
                        EMLog.e("callback", "onSuccess");
                post(new Runnable() {
                    @Override
                    public void run() {
                        result.success(data);
                    }});
            }

            @Override
            public void onError(int code, String error) {
                        Map<String, Object> data = new HashMap<String, Object>();
                        data.put("success", Boolean.FALSE);
                        data.put("code", code );
                        data.put("error", error);
                post(new Runnable() {
                    @Override
                    public void run() {
                        result.success(data);
                    }});
            }

            @Override
            public void onProgress(int progress, String status) {
                        data.put("progress", progress );
                        data.put("status", status);
                        data.put("localMsgId",localMsgId);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onMessageStatusOnProgress, data);
                    }});
            }
        });
        manager.sendMessage(message);
    }

    private void ackMessageRead(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String to = argMap.getString("to");
            String messageId = argMap.getString("id");
            try {
                manager.ackMessageRead(to, messageId);
                onSuccess(result);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void recallMessage(Object args, Result result) {
        JSONObject argMap = (JSONObject)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        try{
            manager.recallMessage(message);
            onSuccess(result);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void getMessage(Object args, Result result) {

        try {
            JSONObject argMap = (JSONObject)args;
            String messageId = argMap.getString("id");
            EMMessage message = manager.getMessage(messageId);
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

    private void getConversation(Object args, Result result) {

        try {
            JSONObject argMap = (JSONObject)args;
            String conversationId = argMap.getString("id");
            EMConversation.EMConversationType type = EMHelper.convertIntToEMConversationType(argMap.getInt("type"));
            Boolean createIfNotExists = argMap.getBoolean("createIfNotExists");
            EMConversation conversation = manager.getConversation(conversationId, type, createIfNotExists);
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("conversation", EMHelper.convertEMConversationToStringMap(conversation));
            post(new Runnable() {
                @Override
                public void run() {
            result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }

    }

    private void markAllConversationsAsRead(Object args, Result result) {
        manager.markAllConversationsAsRead();
    }

    private void getUnreadMessageCount(Object args, Result result) {

        int count = manager.getUnreadMessageCount();
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("count", count);
        post(new Runnable() {
            @Override
            public void run() {
        result.success(data);
            }});
    }

    private void saveMessage(Object args, Result result) {
        JSONObject argMap = (JSONObject)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.saveMessage(message);
    }

    private void updateMessage(Object args, Result result) {
        Map<String, Object> data = null;
        JSONObject argMap = (JSONObject)args;
        try {
            EMMessage message = EMHelper.updateDataMapToMessage(argMap.getJSONObject("message"));
            if (message != null){
                EMClient.getInstance().chatManager().updateMessage(message);
            }
            data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
           result.success(data);
        } catch (JSONException e) {
            data.put("success", Boolean.FALSE);
            data.put("error", e.getMessage());
            e.printStackTrace();
            result.success(data);
        }

    }

    private void downloadAttachment(Object args, Result result) {
        JSONObject argMap = (JSONObject)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.downloadAttachment(message);
    }

    private void downloadThumbnail(Object args, Result result) {
        JSONObject argMap = (JSONObject)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.downloadThumbnail(message);
    }

    private void importMessages(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            EMLog.e("importMessages", argMap.toString());
            JSONArray data = argMap.getJSONArray("messages");
            List<EMMessage> messages = new LinkedList<EMMessage>();
            for(int i = 0; i < data.length(); i++){
                messages.add(EMHelper.convertDataMapToMessage(data.getJSONObject(i)));
            }
            manager.importMessages(messages);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getConversationsByType(Object args, Result result) {

        try {
            JSONObject argMap = (JSONObject)args;
            int type = argMap.getInt("type");
            List<EMConversation> list = manager.getConversationsByType(EMHelper.convertIntToEMConversationType(type));
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            ArrayList<Map<String, Object>> conversations = new ArrayList<>();
            for(EMConversation conversation : list) {
                conversations.add(EMHelper.convertEMConversationToStringMap(conversation));
            }
            data.put("conversations",conversations);
            post(new Runnable() {
                @Override
                public void run() {
            result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }

    }

    private void downloadFile(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            String remoteUrl = argMap.getString("remoteUrl");
            String localFilePath = argMap.getString("localFilePath");
            JSONObject json_headers = argMap.getJSONObject("headers");
            Map<String, String> headers = new HashMap<>();
            headers.put("Authorization", json_headers.getString("json_headers"));
            manager.downloadFile(remoteUrl,localFilePath,headers,new EMWrapperCallBack(result));
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getAllConversations(Object args, Result result) {

        Map<String, EMConversation> list = manager.getAllConversations();
        List<Map<String, Object>> conversations = new LinkedList<Map<String, Object>>();
        for(Map.Entry<String, EMConversation> m : list.entrySet()){
            conversations.add(EMHelper.convertEMConversationToStringMap( m.getValue()));
        }
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("conversations", conversations);
        post(new Runnable() {
            @Override
            public void run() {
        result.success(data);
            }});
    }

    private void loadAllConversations(Object args, Result result) {
        manager.loadAllConversations();
    }

    private void deleteConversation(Object args, Result result) {

        try {
            JSONObject argMap = (JSONObject)args;
            String userName = argMap.getString("userName");
            Boolean deleteMessages = argMap.getBoolean("deleteMessages");
            boolean status = manager.deleteConversation(userName,deleteMessages.booleanValue());
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("status", status);
            post(new Runnable() {
                @Override
                public void run() {
            result.success(data);
                }});
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }

    }


    private void setVoiceMessageListened(Object args, Result result) {
        JSONObject argMap = (JSONObject)args;
        EMMessage message = EMHelper.convertDataMapToMessage(argMap);
        manager.setVoiceMessageListened(message);
    }

    private void updateParticipant(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            String from = argMap.getString("from");
            String changeTo = argMap.getString("changeTo");
            manager.updateParticipant(from, changeTo);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }


    private void fetchHistoryMessages(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            String conversationId = argMap.getString("id");
            int type = argMap.getInt("type");
            int pageSize = argMap.getInt("pageSize");
            String startMsgId = argMap.getString("startMsgId");
            try{
                EMCursorResult<EMMessage> cursorResult = manager.fetchHistoryMessages(conversationId, EMHelper.convertIntToEMConversationType(type), pageSize, startMsgId);
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("success", Boolean.TRUE);
                String cursorId = UUID.randomUUID().toString();
                cursorResultList.put(cursorId, cursorResult);
                data.put("cursorId", cursorId);
                post(new Runnable() {
                    @Override
                    public void run() {
                        result.success(data);
                    }});
            }catch (HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    //Incomplete implementation
    private void getCursor(Object args, Result result) {
        try {
            Map<String, Object> data = new HashMap<String, Object>();
            JSONObject argMap = (JSONObject)args;
            String id = argMap.getString("id");
            EMCursorResult<EMMessage> cursor = cursorResultList.get(id);
            if (cursor != null) {
                data.put("success", Boolean.TRUE);
                data.put("cursor", cursor.getCursor());
                data.put("message", cursor.getData());
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void searchMsgFromDB(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            String keywords = argMap.getString("keywords");
            long timeStamp = Long.parseLong(argMap.getString("timeStamp"));
            int maxCount = argMap.getInt("maxCount");
            String from = argMap.getString("from");
            int direction = argMap.getInt("direction");
            List<EMMessage> list = manager.searchMsgFromDB(keywords, timeStamp, maxCount, from, EMHelper.convertIntToEMSearchDirection(direction));
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
}

