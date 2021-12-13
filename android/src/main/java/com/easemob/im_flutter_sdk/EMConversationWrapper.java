package com.easemob.im_flutter_sdk;
import android.text.TextUtils;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessageBody;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;


public class EMConversationWrapper extends EMWrapper implements MethodCallHandler{

    EMConversationWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        JSONObject param = (JSONObject)call.arguments;

        try { 
            if (EMSDKMethod.getUnreadMsgCount.equals(call.method)) {
                getUnreadMsgCount(param, EMSDKMethod.getUnreadMsgCount, result);
            }
            else if (EMSDKMethod.markAllMessagesAsRead.equals(call.method)) {
                markAllMessagesAsRead(param, EMSDKMethod.markAllMessagesAsRead, result);
            }
            else if (EMSDKMethod.markMessageAsRead.equals(call.method)) {
                markMessageAsRead(param, EMSDKMethod.markMessageAsRead, result);
            }
            else if (EMSDKMethod.syncConversationExt.equals(call.method)){
                syncConversationExt(param, EMSDKMethod.syncConversationExt, result);
            }
            else if (EMSDKMethod.syncConversationName.equals(call.method)){
                syncConversationName(param, EMSDKMethod.syncConversationName, result);
            }
            else if (EMSDKMethod.removeMessage.equals(call.method))
            {
                removeMessage(param, EMSDKMethod.removeMessage, result);
            }
            else if (EMSDKMethod.getLatestMessage.equals(call.method)) {
                getLatestMessage(param, EMSDKMethod.getLatestMessage, result);
            }
            else if (EMSDKMethod.getLatestMessageFromOthers.equals(call.method)) {
                getLatestMessageFromOthers(param, EMSDKMethod.getLatestMessageFromOthers, result);
            }
            else if (EMSDKMethod.clearAllMessages.equals(call.method)) {
                clearAllMessages(param, EMSDKMethod.clearAllMessages, result);
            }
            else if (EMSDKMethod.insertMessage.equals((call.method))) {
                insertMessage(param, EMSDKMethod.insertMessage, result);
            }
            else if (EMSDKMethod.appendMessage.equals(call.method)) {
                appendMessage(param, EMSDKMethod.appendMessage, result);
            }
            else if (EMSDKMethod.updateConversationMessage.equals(call.method)) {
                updateConversationMessage(param, EMSDKMethod.updateConversationMessage, result);
            }
            else if (EMSDKMethod.loadMsgWithId.equals(call.method)) {
                loadMsgWithId(param, EMSDKMethod.loadMsgWithId, result);
            }
            else if (EMSDKMethod.loadMsgWithStartId.equals(call.method)) {
                loadMsgWithStartId(param, EMSDKMethod.loadMsgWithStartId, result);
            }
            else if (EMSDKMethod.loadMsgWithKeywords.equals(call.method)) {
                loadMsgWithKeywords(param, EMSDKMethod.loadMsgWithKeywords, result);
            }
            else if (EMSDKMethod.loadMsgWithMsgType.equals(call.method)) {
                loadMsgWithMsgType(param, EMSDKMethod.loadMsgWithMsgType, result);
            }
            else if (EMSDKMethod.loadMsgWithTime.equals(call.method)) {
                loadMsgWithTime(param, EMSDKMethod.loadMsgWithTime, result);
            }

            else
            {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void getUnreadMsgCount(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);

        asyncRunnable(()->{
            onSuccess(result, channelName,  conversation.getUnreadMsgCount());   
        });
    }

    private void markAllMessagesAsRead(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);

        asyncRunnable(()->{
            conversation.markAllMessagesAsRead();
            onSuccess(result, channelName, true);
        });
    }

    private void markMessageAsRead(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String msg_id = params.getString("msg_id");

        asyncRunnable(()->{
            conversation.markMessageAsRead(msg_id);
            onSuccess(result, channelName, true);
        });
    }

    private void syncConversationName(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String conName = params.getString("con_name");
        String extField = conversation.getExtField();
        JSONObject jsonObject = new JSONObject();
        if(!extField.isEmpty()){
            jsonObject = new JSONObject(extField);
        }
        jsonObject.put("con_name", conName);
        String jsonStr = jsonObject.toString();
        conversation.setExtField(jsonStr);
        asyncRunnable(()->{
            onSuccess(result, channelName, true);
        });
    }

    private void syncConversationExt(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject ext = params.getJSONObject("ext");
        String jsonStr = "";
        if (ext.length() != 0) {
            jsonStr = ext.toString();
        }
        conversation.setExtField(jsonStr);

        asyncRunnable(()->{
            onSuccess(result, channelName, true);
        });
    }

    private void removeMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String msg_id = params.getString("msg_id");

        asyncRunnable(()->{
            conversation.removeMessage(msg_id);
            onSuccess(result, channelName, true);
        });
    }

    private void getLatestMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);

        asyncRunnable(()->{
            EMMessage msg = conversation.getLastMessage();
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void getLatestMessageFromOthers(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);

        asyncRunnable(()->{
            EMMessage msg = conversation.getLatestMessageFromOthers();
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void clearAllMessages(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);

        asyncRunnable(()->{
            conversation.clearAllMessages();
            onSuccess(result, channelName, true);
        });
    }

    private void insertMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject msg = params.getJSONObject("msg");
        EMMessage message = EMMessageHelper.fromJson(msg);

        asyncRunnable(()->{
            conversation.insertMessage(message);
            onSuccess(result, channelName, true);
        });
    }

    private void appendMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject msg = params.getJSONObject("msg");
        EMMessage message = EMMessageHelper.fromJson(msg);

        asyncRunnable(()->{
            conversation.appendMessage(message);
            onSuccess(result, channelName, true);
        });
    }

    private void updateConversationMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject msg = params.getJSONObject("msg");
        EMMessage message = EMMessageHelper.fromJson(msg);

        asyncRunnable(()->{
            conversation.updateMessage(message);
            onSuccess(result, channelName, true);
        });
    }

    private void loadMsgWithId(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msg_id");
        asyncRunnable(()->{
            EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void loadMsgWithStartId(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String startId = params.getString("startId");
        int pageSize = params.getInt("count");
        EMConversation.EMSearchDirection direction = searchDirectionFromString(params.getString("direction"));
        asyncRunnable(()->{
            List<EMMessage> msgList = conversation.loadMoreMsgFromDB(startId, pageSize, direction);
            List<Map> messages = new ArrayList<>();
            for(EMMessage msg: msgList) {
                messages.add(EMMessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }

    private void loadMsgWithKeywords(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String keywords = params.getString("keywords");
        String sender = null;
        if (params.has("sender")) {
            sender = params.getString("sender");
        }
        final String name = sender;
        int count = params.getInt("count");
        long timestamp = params.getLong("timestamp");
        EMConversation.EMSearchDirection direction = searchDirectionFromString(params.getString("direction"));
        asyncRunnable(()->{
            List<EMMessage> msgList = conversation.searchMsgFromDB(keywords, timestamp, count, name, direction);
            List<Map> messages = new ArrayList<>();
            for(EMMessage msg: msgList) {
                messages.add(EMMessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }

    private void loadMsgWithMsgType(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        long timestamp = params.getLong("timestamp");
        String sender = params.getString("sender");
        int count = params.getInt("count");
        EMConversation.EMSearchDirection direction = searchDirectionFromString(params.getString("direction"));
        String typeStr = params.getString("type");
        EMMessage.Type type = EMMessage.Type.TXT;
        switch (typeStr) {
            case "txt" : type = EMMessage.Type.TXT; break;
            case "loc" : type = EMMessage.Type.LOCATION; break;
            case "cmd" : type = EMMessage.Type.CMD; break;
            case "custom" : type = EMMessage.Type.CUSTOM; break;
            case "file" : type = EMMessage.Type.FILE; break;
            case "img" : type = EMMessage.Type.IMAGE; break;
            case "video" : type = EMMessage.Type.VIDEO; break;
            case "voice" : type = EMMessage.Type.VOICE; break;
        }

        EMMessage.Type finalType = type;
        asyncRunnable(()->{
            List<EMMessage> msgList = conversation.searchMsgFromDB(finalType, timestamp, count, sender, direction);
            List<Map> messages = new ArrayList<>();
            for(EMMessage msg: msgList) {
                messages.add(EMMessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }

    private void loadMsgWithTime(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        long startTime = params.getLong("startTime");
        long endTime = params.getLong("endTime");
        int count = params.getInt("count");

        asyncRunnable(()->{
            List<EMMessage> msgList = conversation.searchMsgFromDB(startTime, endTime, count);
            List<Map> messages = new ArrayList<>();
            for(EMMessage msg: msgList) {
                messages.add(EMMessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }


    private EMConversation conversationWithParam(JSONObject params ) throws JSONException {
        String con_id = params.getString("con_id");
        EMConversation.EMConversationType type = EMConversationHelper.typeFromInt(params.getInt("type"));
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(con_id, type, true);
        return conversation;
    }

    private EMConversation.EMSearchDirection searchDirectionFromString(String direction) {
        return TextUtils.equals(direction, "up") ? EMConversation.EMSearchDirection.UP : EMConversation.EMSearchDirection.DOWN;
    }
}
