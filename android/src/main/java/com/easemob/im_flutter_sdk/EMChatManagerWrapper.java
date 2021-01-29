package com.easemob.im_flutter_sdk;

import com.hyphenate.EMMessageListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.*;
import com.hyphenate.chat.EMConversation.EMSearchDirection;
import com.hyphenate.chat.EMConversation.EMConversationType;

import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.adapter.message.EMAMessage;
import com.hyphenate.exceptions.HyphenateException;


import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


public class EMChatManagerWrapper extends EMWrapper implements MethodCallHandler{

    private MethodChannel messageChannel;

    EMChatManagerWrapper(Registrar registrar, String channelName) {
        super(registrar, channelName);
        messageChannel = new MethodChannel(registrar.messenger(), "com.easemob.im/em_message", JSONMethodCodec.INSTANCE);
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        JSONObject param = (JSONObject)call.arguments;
        try {
            if(EMSDKMethod.sendMessage.equals(call.method)) {
                sendMessage(param, EMSDKMethod.sendMessage, result);
            }
            else if(EMSDKMethod.resendMessage.equals(call.method))
            {
                resendMessage(param, EMSDKMethod.resendMessage, result);
            }
            else if(EMSDKMethod.ackMessageRead.equals(call.method))
            {
                ackMessageRead(param, EMSDKMethod.ackMessageRead, result);
            }
            else if(EMSDKMethod.recallMessage.equals(call.method))
            {
                recallMessage(param, EMSDKMethod.recallMessage, result);
            }
            else if(EMSDKMethod.getConversation.equals(call.method))
            {
                getConversation(param, EMSDKMethod.getConversation, result);
            }
            else if(EMSDKMethod.markAllChatMsgAsRead.equals(call.method))
            {
                markAllChatMsgAsRead(param, EMSDKMethod.markAllChatMsgAsRead, result);
            }
            else if(EMSDKMethod.getUnreadMessageCount.equals(call.method))
            {
                getUnreadMessageCount(param, EMSDKMethod.getUnreadMessageCount, result);
            }
            else if(EMSDKMethod.updateChatMessage.equals(call.method))
            {
                updateChatMessage(param, EMSDKMethod.updateChatMessage, result);
            }
            else if(EMSDKMethod.downloadAttachment.equals(call.method))
            {
                downloadAttachment(param, EMSDKMethod.downloadAttachment, result);
            }
            else if(EMSDKMethod.downloadThumbnail.equals(call.method))
            {
                downloadThumbnail(param, EMSDKMethod.downloadThumbnail, result);
            }
            else if(EMSDKMethod.importMessages.equals(call.method))
            {
                importMessages(param, EMSDKMethod.importMessages, result);
            }
            else if(EMSDKMethod.loadAllConversations.equals(call.method))
            {
                loadAllConversations(param, EMSDKMethod.loadAllConversations, result);
            }
            else if(EMSDKMethod.deleteConversation.equals(call.method))
            {
                deleteConversation(param, EMSDKMethod.deleteConversation, result);
            }
            else if(EMSDKMethod.fetchHistoryMessages.equals(call.method))
            {
                fetchHistoryMessages(param, EMSDKMethod.fetchHistoryMessages, result);
            }
            else if(EMSDKMethod.searchChatMsgFromDB.equals(call.method))
            {
                searchChatMsgFromDB(param, EMSDKMethod.searchChatMsgFromDB, result);
            }
            else if(EMSDKMethod.getMessage.equals(call.method))
            {
                getMessage(param, EMSDKMethod.getMessage, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        }catch (JSONException ignored) {

        }
    }
    private void sendMessage(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage msg = EMMessageHelper.fromJson(param);

        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(()->{
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(()->{
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageProgressUpdate, map);
                });
            }

            @Override
            public void onError(int code, String desc) {
                post(()->{
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    map.put("code", code);
                    map.put("description", desc);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        asyncRunnable(()->{
            EMClient.getInstance().chatManager().sendMessage(msg);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void resendMessage(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(param);
        System.out.println(tempMsg.toString());
        EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        msg.setStatus(EMMessage.Status.CREATE);
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(()->{
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(()->{
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageProgressUpdate, map);
                });
            }

            @Override
            public void onError(int code, String desc) {
                post(()->{
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    map.put("code", code);
                    map.put("description", desc);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        asyncRunnable(()->{
            EMClient.getInstance().chatManager().sendMessage(msg);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void ackMessageRead(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msg_id");
        String to = param.getString("to");

        asyncRunnable(()->{
            try {
                EMClient.getInstance().chatManager().ackMessageRead(to, msgId);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void recallMessage(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msg_id");

        asyncRunnable(()->{
            try {
                EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
                EMClient.getInstance().chatManager().recallMessage(msg);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getMessage(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msg_id");

        asyncRunnable(()->{
            EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void getConversation(JSONObject param, String channelName, Result result) throws JSONException {
        String conId = param.getString("con_id");
        EMConversationType type = EMConversationHelper.typeFromInt(param.getInt("type"));

        asyncRunnable(()->{
            EMConversation conversation =  EMClient.getInstance().chatManager().getConversation(conId, type, true);
            onSuccess(result, channelName, EMConversationHelper.toJson(conversation));
        });
    }

    private void markAllChatMsgAsRead(JSONObject param, String channelName, Result result) throws JSONException {
        EMClient.getInstance().chatManager().markAllConversationsAsRead();

        asyncRunnable(()->{
            onSuccess(result, channelName, true);
        });
    }

    private void getUnreadMessageCount(JSONObject param, String channelName, Result result) throws JSONException {
        int count = EMClient.getInstance().chatManager().getUnreadMessageCount();

        asyncRunnable(()->{
            onSuccess(result, channelName, count);
        });
    }

    private void updateChatMessage(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage msg = EMMessageHelper.fromJson(param.getJSONObject("message"));

        asyncRunnable(()->{
            EMClient.getInstance().chatManager().updateMessage(msg);
            onSuccess(result, channelName, true);
        });
    }

    private void importMessages(JSONObject param, String channelName, Result result) throws JSONException {
        JSONArray ary = param.getJSONArray("messages");
        List<EMMessage> messages = new ArrayList<>();
        for(int i = 0; i < ary.length(); i++) {
            JSONObject obj = ary.getJSONObject(i);
            messages.add(EMMessageHelper.fromJson(obj));
        }

        asyncRunnable(()->{
            EMClient.getInstance().chatManager().importMessages(messages);
            onSuccess(result, channelName, true);
        });
    }

    private void downloadAttachment(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage msg = EMMessageHelper.fromJson(param.getJSONObject("message"));
        asyncRunnable(()->{
            EMClient.getInstance().chatManager().downloadAttachment(msg);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void downloadThumbnail(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage msg = EMMessageHelper.fromJson(param.getJSONObject("message"));
        asyncRunnable(()->{
            EMClient.getInstance().chatManager().downloadThumbnail(msg);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void loadAllConversations(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            Map map = EMClient.getInstance().chatManager().getAllConversations();
            List<Map> conversations = new ArrayList<>();
            for (Object key : map.keySet()) {
                EMConversation conversation = (EMConversation) map.get(key);
                conversations.add(EMConversationHelper.toJson(conversation));
            }
            onSuccess(result, channelName, conversations);
        });
    }

    private void deleteConversation(JSONObject param, String channelName, Result result) throws JSONException {
        String conId = param.getString("con_id");
        boolean isDelete = param.getBoolean("deleteMessages");
        asyncRunnable(()->{
            boolean ret = EMClient.getInstance().chatManager().deleteConversation(conId, isDelete);
            onSuccess(result, channelName, ret);
        });
    }

    private void fetchHistoryMessages(JSONObject param, String channelName, Result result) throws JSONException {
        String conId = param.getString("con_id");
        EMConversationType type = EMConversationHelper.typeFromInt(param.getInt("type"));
        int pageSize = param.getInt("pageSize");
        String startMsgId = param.getString("startMsgId");
        try {
            EMCursorResult<EMMessage> cursorResult = EMClient.getInstance().chatManager().fetchHistoryMessages(conId, type, pageSize, startMsgId);
            onSuccess(result, channelName, EMCursorResultHelper.toJson(cursorResult));
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void searchChatMsgFromDB(JSONObject param, String channelName, Result result) throws JSONException {
        String keywords = param.getString("keywords");
        long timeStamp = param.getLong("timeStamp");
        int count = param.getInt("maxCount");
        String from = param.getString("from");
        EMSearchDirection direction = searchDirectionFromString(param.getString("direction"));
        asyncRunnable(()->{
            List<EMMessage> msgList = EMClient.getInstance().chatManager().searchMsgFromDB(keywords, timeStamp, count, from, direction);
            List<Map> messages = new ArrayList<>();
            for(EMMessage msg: msgList) {
                messages.add(EMMessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }

    private void registerEaseListener(){
        EMClient.getInstance().chatManager().addMessageListener(new EMMessageListener() {
            @Override
            public void onMessageReceived(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for(EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onMessagesReceived, msgList));
            }

            @Override
            public void onCmdMessageReceived(List<EMMessage> messages) {

                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for(EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onCmdMessagesReceived, msgList));
            }

            @Override
            public void onMessageRead(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for(EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onMessagesRead, msgList));
            }

            @Override
            public void onMessageDelivered(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for(EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onMessagesDelivered, msgList));
            }

            @Override
            public void onMessageRecalled(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for(EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onMessagesRecalled, msgList));
            }

            @Override
            public void onMessageChanged(EMMessage message, Object change) {
                Map<String, Object> data = new HashMap<>();
                data.put("message", EMMessageHelper.toJson(message));
                post(() -> channel.invokeMethod(EMSDKMethod.onMessageChanged, data));

            }
        });
        //setup conversation listener
        EMClient.getInstance().chatManager().addConversationListener(() -> {
            Map<String, Object> data = new HashMap<>();
            post(() -> channel.invokeMethod(EMSDKMethod.onConversationUpdate,data));
        });
    }

    private EMConversation.EMSearchDirection searchDirectionFromString(String direction) {
        return direction == "up" ? EMConversation.EMSearchDirection.UP : EMConversation.EMSearchDirection.DOWN;
    }
}

