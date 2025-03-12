package com.easemob.im_flutter_sdk;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


public class ConversationWrapper extends Wrapper implements MethodCallHandler{

    ConversationWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        JSONObject param = (JSONObject)call.arguments;

        try { 
            if (MethodKey.getUnreadMsgCount.equals(call.method)) {
                getUnreadMsgCount(param, call.method, result);
            }
            else if (MethodKey.markAllMessagesAsRead.equals(call.method)) {
                markAllMessagesAsRead(param, call.method, result);
            }
            else if (MethodKey.markMessageAsRead.equals(call.method)) {
                markMessageAsRead(param, call.method, result);
            }
            else if (MethodKey.syncConversationExt.equals(call.method)){
                syncConversationExt(param, call.method, result);
            }
            else if (MethodKey.removeMessage.equals(call.method))
            {
                removeMessage(param, call.method, result);
            }
            else if (MethodKey.deleteMessageByIds.equals(call.method))
            {
                deleteMessageByIds(param, call.method, result);
            }
            else if (MethodKey.getLatestMessage.equals(call.method)) {
                getLatestMessage(param, call.method, result);
            }
            else if (MethodKey.getLatestMessageFromOthers.equals(call.method)) {
                getLatestMessageFromOthers(param, call.method, result);
            }
            else if (MethodKey.clearAllMessages.equals(call.method)) {
                clearAllMessages(param, call.method, result);
            }
            else if (MethodKey.deleteMessagesWithTs.equals(call.method)) {
                deleteMessagesWithTs(param, call.method, result);
            }
            else if (MethodKey.insertMessage.equals((call.method))) {
                insertMessage(param, call.method, result);
            }
            else if (MethodKey.appendMessage.equals(call.method)) {
                appendMessage(param, call.method, result);
            }
            else if (MethodKey.updateConversationMessage.equals(call.method)) {
                updateConversationMessage(param, call.method, result);
            }
            else if (MethodKey.loadMsgWithId.equals(call.method)) {
                loadMsgWithId(param, call.method, result);
            }
            else if (MethodKey.loadMsgWithStartId.equals(call.method)) {
                loadMsgWithStartId(param, call.method, result);
            }
            else if (MethodKey.loadMsgWithKeywords.equals(call.method)) {
                loadMsgWithKeywords(param, call.method, result);
            }
            else if (MethodKey.loadMsgWithMsgType.equals(call.method)) {
                loadMsgWithMsgType(param, call.method, result);
            }
            else if (MethodKey.loadMsgWithTime.equals(call.method)) {
                loadMsgWithTime(param, call.method, result);
            }
            else if(MethodKey.messageCount.equals(call.method)) {
                messageCount(param, call.method, result);
            }
            else if (MethodKey.removeMsgFromServerWithMsgList.equals(call.method)) {
                removeMsgFromServerWithMsgList(param, call.method, result);
            }
            else if (MethodKey.removeMsgFromServerWithTimeStamp.equals(call.method)) {
                removeMsgFromServerWithTimeStamp(param, call.method, result);
            }
            else if (MethodKey.pinnedMessages.equals(call.method)){
                pinnedMessages(param, call.method, result);
            }
            // 481
            else if (MethodKey.conversationRemindType.equals(call.method)) {
                remindType(param, call.method, result);
            }
            else if (MethodKey.conversationSearchMsgsByOptions.equals(call.method)) {
                searchMsgByOptions(param, call.method, result);
            }
            else if (MethodKey.conversationGetLocalMessageCount.equals(call.method)) {
                getLocalMessageCount(param, call.method, result);
            }
            else if (MethodKey.conversationDeleteServerMessageWithIds.equals(call.method)) {
                deleteLocalAndServerMessages(param, call.method, result);
            }
            else if (MethodKey.conversationDeleteServerMessageWithTime.equals(call.method)) {
                deleteLocalAndServerMessagesByTime(param, call.method, result);
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

    private void deleteMessageByIds(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        List<String> messageIds = new ArrayList<>();
        if (params.has("messageIds")){
            JSONArray array = params.getJSONArray("messageIds");
            for (int i = 0; i < array.length(); i++) {
                messageIds.add(array.getString(i));
            }
        }
        asyncRunnable(()->{
            for (int i = 0; i < messageIds.size(); i++) {
                conversation.removeMessage(messageIds.get(i));
            }
            onSuccess(result, channelName, true);
        });
    }

    private void getLatestMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);

        asyncRunnable(()->{
            EMMessage msg = conversation.getLastMessage();
            onSuccess(result, channelName, msg != null ? MessageHelper.toJson(msg) : null);
        });
    }

    private void getLatestMessageFromOthers(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);

        asyncRunnable(()->{
            EMMessage msg = conversation.getLatestMessageFromOthers();
            onSuccess(result, channelName, msg != null ? MessageHelper.toJson(msg) : null);
        });
    }

    private void clearAllMessages(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);

        asyncRunnable(()->{
            conversation.clearAllMessages();
            onSuccess(result, channelName, true);
        });
    }

    private void deleteMessagesWithTs(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        long startTs = params.getLong("startTs");
        long endTs = params.getLong("endTs");
        asyncRunnable(()->{
            boolean success = conversation.removeMessages(startTs, endTs);
            if (success) {
                onSuccess(result, channelName, true);
            }else {
                HyphenateException e = new HyphenateException(3, "Database operation error");
                onError(result, e);
            }
        });
    }



    private void insertMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject msg = params.getJSONObject("msg");
        EMMessage message = MessageHelper.fromJson(msg);

        asyncRunnable(()->{
            conversation.insertMessage(message);
            onSuccess(result, channelName, true);
        });
    }

    private void appendMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONObject msg = params.getJSONObject("msg");
        EMMessage message = MessageHelper.fromJson(msg);

        asyncRunnable(()->{
            if (message != null) {
                conversation.appendMessage(message);
            }
            onSuccess(result, channelName, true);
        });
    }

    private void updateConversationMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        EMMessage msg = MessageHelper.fromJson(params.getJSONObject("msg"));
        EMMessage dbMsg = EMClient.getInstance().chatManager().getMessage(msg.getMsgId());
        if(dbMsg == null) {
            onError(result, new HyphenateException(500, "The message is invalid."));
            return;
        }
        HelpTool.mergeMessage(msg, dbMsg);
        asyncRunnable(()->{
            conversation.updateMessage(dbMsg);
            onSuccess(result, channelName, true);
        });
    }

    private void loadMsgWithId(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msg_id");
        asyncRunnable(()->{
            EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
            if(msg == null) {
                onSuccess(result, channelName, null);
            }else {
                onSuccess(result, channelName, MessageHelper.toJson(msg));
            }
        });
    }

    private void loadMsgWithStartId(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String startId = params.getString("startId");
        int pageSize = params.getInt("count");
        EMConversation.EMSearchDirection direction = EnumTools.searchDirectionFromInt(params.getInt("direction"));
        asyncRunnable(()->{
            List<EMMessage> msgList = conversation.loadMoreMsgFromDB(startId, pageSize, direction);
            List<Map> messages = new ArrayList<>();
            for(EMMessage msg: msgList) {
                messages.add(MessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }

    private void loadMsgWithKeywords(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        String keywords = params.getString("keywords");
        String sender = null;
        if (params.has("from")) {
            sender = params.getString("from");
        }
        final String name = sender;
        int count = params.getInt("count");
        long timestamp = params.getLong("timestamp");
        EMConversation.EMSearchDirection direction = EnumTools.searchDirectionFromInt(params.getInt("direction"));
        EMConversation.EMMessageSearchScope scope;
        if(params.has("searchScope")) {
            scope = EMConversation.EMMessageSearchScope.values()[params.getInt("searchScope")];
        }else {
            scope = EMConversation.EMMessageSearchScope.ALL;
        }
        asyncRunnable(()->{
            List<EMMessage> msgList = conversation.searchMsgFromDB(keywords, timestamp, count, name, direction, scope);
            List<Map> messages = new ArrayList<>();
            for(EMMessage msg: msgList) {
                messages.add(MessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }

    private void loadMsgWithMsgType(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        long timestamp = params.getLong("timestamp");
        String sender = null;
        if (params.has("sender")) {
            sender = params.getString("sender");
        }
        int count = params.getInt("count");
        EMConversation.EMSearchDirection direction = EnumTools.searchDirectionFromInt(params.getInt("direction"));

        EMMessage.Type type = EnumTools.messageBodyTypeFromInt(params.getInt("msgType"));
        EMMessage.Type finalType = type;
        String finalSender = sender;
        asyncRunnable(()->{
            List<EMMessage> msgList = conversation.searchMsgFromDB(finalType, timestamp, count, finalSender, direction);
            List<Map> messages = new ArrayList<>();
            for(EMMessage msg: msgList) {
                messages.add(MessageHelper.toJson(msg));
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
                messages.add(MessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }

    private void messageCount(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        asyncRunnable(()->{
            onSuccess(result, channelName,  conversation.getAllMsgCount());
        });
    }

    private void removeMsgFromServerWithMsgList(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray jsonAry = params.getJSONArray("msgIds");
        List<String> msgIds = new ArrayList<>();
        for (int i = 0; i < jsonAry.length(); i++) {
            msgIds.add((String) jsonAry.get(i));
        }
        EMConversation conversation = conversationWithParam(params);
        conversation.removeMessagesFromServer(msgIds, new EMWrapperCallBack(result, channelName, null));
    }

    private void removeMsgFromServerWithTimeStamp(JSONObject params, String channelName, Result result) throws JSONException {
        long timestamp = params.getLong("timestamp");
        EMConversation conversation = conversationWithParam(params);
        conversation.removeMessagesFromServer(timestamp, new EMWrapperCallBack(result, channelName, null));
    }

    private void pinnedMessages(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        List<EMMessage> msgList = conversation.pinnedMessages();
        List<Map> messages = new ArrayList<>();
        for(EMMessage msg: msgList) {
            messages.add(MessageHelper.toJson(msg));
        }
        onSuccess(result, channelName, messages);
    }


    private EMConversation conversationWithParam(JSONObject params ) throws JSONException {
        String convId = params.getString("convId");
        EMConversation.EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("type"));
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(convId, type, true);
        return conversation;
    }

    // 481
    private void remindType(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        onSuccess(result, channelName, EnumTools.remindTypeToInt(conversation.pushRemindType()));
    }

    private void searchMsgByOptions(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        JSONArray ja = params.getJSONArray("types");
        Set<EMMessage.Type> types = new HashSet<>();
        for (int i = 0; i < ja.length(); i++) {
            int iType = ja.getInt(i);
            types.add(MessageHelper.getTypeFromInt(iType));
        }
        long ts = params.getLong("ts");
        int count = params.getInt("count");
        String from = params.optString("from");
        EMConversation.EMSearchDirection direction = EnumTools.searchDirectionFromInt(params.getInt("direction"));
        List<EMMessage> msgList = conversation.searchMsgFromDB(types, ts, count, from, direction);
        List<Map> messages = new ArrayList<>();
        for(EMMessage msg: msgList) {
            messages.add(MessageHelper.toJson(msg));
        }
        onSuccess(result, channelName, messages);
    }

    private void getLocalMessageCount(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        long startMs = params.optLong("startMs");
        long endMs = params.optLong("endMs");
        int count = conversation.getAllMsgCount(startMs, endMs);
        asyncRunnable(()->{
            onSuccess(result, channelName, count);
        });
    }

    private void deleteLocalAndServerMessages(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        List<String> messageIds = new ArrayList<>();
        if (params.has("msgIds")){
            JSONArray array = params.getJSONArray("msgIds");
            for (int i = 0; i < array.length(); i++) {
                messageIds.add(array.getString(i));
            }
        }
        conversation.removeMessagesFromServer(messageIds, new EMWrapperCallBack(result, channelName,null));
    }

    private void deleteLocalAndServerMessagesByTime(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation conversation = conversationWithParam(params);
        long beforeMs = params.optLong("beforeMs");
        conversation.removeMessagesFromServer(beforeMs, new EMWrapperCallBack(result, channelName,null));
    }

}
