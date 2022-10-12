package com.easemob.im_flutter_sdk;

import com.hyphenate.EMConversationListener;
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

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class EMChatManagerWrapper extends EMWrapper implements MethodCallHandler {

    private MethodChannel messageChannel;
    private EMMessageListener messageListener;
    private EMConversationListener conversationListener;


    EMChatManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        messageChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.chat.im/chat_message", JSONMethodCodec.INSTANCE);
        registerEaseListener();
    }




    @Override
    public void onMethodCall(MethodCall call, Result result) {
        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.sendMessage.equals(call.method)) {
                sendMessage(param, call.method, result);
            } else if (EMSDKMethod.resendMessage.equals(call.method)) {
                resendMessage(param, call.method, result);
            } else if (EMSDKMethod.ackMessageRead.equals(call.method)) {
                ackMessageRead(param, call.method, result);
            } else if (EMSDKMethod.ackGroupMessageRead.equals(call.method)) {
                ackGroupMessageRead(param, call.method, result);
            } else if (EMSDKMethod.ackConversationRead.equals(call.method)) {
                ackConversationRead(param, call.method, result);
            } else if (EMSDKMethod.recallMessage.equals(call.method)) {
                recallMessage(param, call.method, result);
            } else if (EMSDKMethod.getConversation.equals(call.method)) {
                getConversation(param, call.method, result);
            } else if (EMSDKMethod.getThreadConversation.equals(call.method)) {
                getThreadConversation(param, call.method, result);
            } else if (EMSDKMethod.markAllChatMsgAsRead.equals(call.method)) {
                markAllChatMsgAsRead(param, call.method, result);
            } else if (EMSDKMethod.getUnreadMessageCount.equals(call.method)) {
                getUnreadMessageCount(param, call.method, result);
            } else if (EMSDKMethod.updateChatMessage.equals(call.method)) {
                updateChatMessage(param, call.method, result);
            } else if (EMSDKMethod.downloadAttachment.equals(call.method)) {
                downloadAttachment(param, call.method, result);
            } else if (EMSDKMethod.downloadThumbnail.equals(call.method)) {
                downloadThumbnail(param, call.method, result);
            } else if (EMSDKMethod.importMessages.equals(call.method)) {
                importMessages(param, call.method, result);
            } else if (EMSDKMethod.loadAllConversations.equals(call.method)) {
                loadAllConversations(param, call.method, result);
            } else if (EMSDKMethod.getConversationsFromServer.equals(call.method)) {
                getConversationsFromServer(param, call.method, result);
            } else if (EMSDKMethod.deleteConversation.equals(call.method)) {
                deleteConversation(param, call.method, result);
            } else if (EMSDKMethod.fetchHistoryMessages.equals(call.method)) {
                fetchHistoryMessages(param, call.method, result);
            } else if (EMSDKMethod.searchChatMsgFromDB.equals(call.method)) {
                searchChatMsgFromDB(param, call.method, result);
            } else if (EMSDKMethod.getMessage.equals(call.method)) {
                getMessage(param, call.method, result);
            } else if (EMSDKMethod.asyncFetchGroupAcks.equals(call.method)){
                asyncFetchGroupMessageAckFromServer(param, call.method, result);
            } else if (EMSDKMethod.deleteRemoteConversation.equals(call.method)){
                deleteRemoteConversation(param, call.method, result);
            } else if (EMSDKMethod.deleteMessagesBeforeTimestamp.equals(call.method)) {
                deleteMessagesBefore(param, call.method, result);
            } else if (EMSDKMethod.translateMessage.equals(call.method)) {
                translateMessage(param, call.method, result);
            } else if (EMSDKMethod.fetchSupportedLanguages.equals(call.method)) {
                fetchSupportedLanguages(param, call.method, result);
            } else if (EMSDKMethod.addReaction.equals(call.method)) {
                addReaction(param, call.method, result);
            } else if (EMSDKMethod.removeReaction.equals(call.method)) {
                removeReaction(param, call.method, result);
            } else if (EMSDKMethod.fetchReactionList.equals(call.method)) {
                fetchReactionList(param, call.method, result);
            } else if (EMSDKMethod.fetchReactionDetail.equals(call.method)) {
                fetchReactionDetail(param, call.method, result);
            } else if (EMSDKMethod.reportMessage.equals(call.method)) {
                reportMessage(param, call.method, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException ignored) {

        }
    }

    private void sendMessage(JSONObject param, String channelName, Result result) throws JSONException {
        final EMMessage msg = EMMessageHelper.fromJson(param);
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageProgressUpdate, map);
                });
            }

            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    map.put("error", data);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().sendMessage(msg);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void resendMessage(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(param);
        EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        if (msg == null) {
            msg = tempMsg;
        }
        msg.setStatus(EMMessage.Status.CREATE);
        EMMessage finalMsg = msg;
        finalMsg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(finalMsg));
                    map.put("localTime", finalMsg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localTime", finalMsg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageProgressUpdate, map);
                });
            }


            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(finalMsg));
                    map.put("localTime", finalMsg.localTime());
                    map.put("error", data);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        EMClient.getInstance().chatManager().sendMessage(msg);
        asyncRunnable(() -> {
            onSuccess(result, channelName, EMMessageHelper.toJson(finalMsg));
        });
    }

    private void ackMessageRead(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msg_id");
        String to = param.getString("to");

        asyncRunnable(() -> {
            try {
                EMClient.getInstance().chatManager().ackMessageRead(to, msgId);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void ackGroupMessageRead(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msg_id");
        String to = param.getString("group_id");
        String content = null;
        if(param.has("content")) {
            content = param.getString("content");
        }
        String finalContent = content;
        asyncRunnable(()->{
            try {
                EMClient.getInstance().chatManager().ackGroupMessageRead(to, msgId, finalContent);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void ackConversationRead(JSONObject param, String channelName, Result result) throws JSONException {
        String conversationId = param.getString("con_id");
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().chatManager().ackConversationRead(conversationId);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void recallMessage(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msg_id");

        asyncRunnable(() -> {
            try {
                EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
                if (msg != null) {
                    EMClient.getInstance().chatManager().recallMessage(msg);
                    onSuccess(result, channelName, true);
                }else {
                    onError(result, new HyphenateException(500, "The message was not found"));
                }
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getMessage(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msg_id");

        asyncRunnable(() -> {
            EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void getConversation(JSONObject param, String channelName, Result result) throws JSONException {
        String conId = param.getString("con_id");
        boolean createIfNeed = true;
        if (param.has("createIfNeed")) {
            createIfNeed = param.getBoolean("createIfNeed");
        }

        EMConversationType type = EMConversationHelper.typeFromInt(param.getInt("type"));

        boolean finalCreateIfNeed = createIfNeed;
        asyncRunnable(() -> {
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conId, type, finalCreateIfNeed);
            onSuccess(result, channelName, conversation != null ? EMConversationHelper.toJson(conversation) : null);
        });
    }

    private void getThreadConversation(JSONObject param, String channelName, Result result) throws JSONException {
        String conId = param.getString("con_id");
        asyncRunnable(() -> {
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conId, EMConversationType.GroupChat, true, true);
            onSuccess(result, channelName, conversation != null ? EMConversationHelper.toJson(conversation) : null);
        });
    }

    private void markAllChatMsgAsRead(JSONObject param, String channelName, Result result) throws JSONException {
        EMClient.getInstance().chatManager().markAllConversationsAsRead();

        asyncRunnable(() -> {
            onSuccess(result, channelName, true);
        });
    }

    private void getUnreadMessageCount(JSONObject param, String channelName, Result result) throws JSONException {
        int count = EMClient.getInstance().chatManager().getUnreadMessageCount();

        asyncRunnable(() -> {
            onSuccess(result, channelName, count);
        });
    }

    private void updateChatMessage(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage msg = EMMessageHelper.fromJson(param.getJSONObject("message"));

        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().updateMessage(msg);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void importMessages(JSONObject param, String channelName, Result result) throws JSONException {
        JSONArray ary = param.getJSONArray("messages");
        List<EMMessage> messages = new ArrayList<>();
        for (int i = 0; i < ary.length(); i++) {
            JSONObject obj = ary.getJSONObject(i);
            messages.add(EMMessageHelper.fromJson(obj));
        }

        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().importMessages(messages);
            onSuccess(result, channelName, true);
        });
    }

    private void downloadAttachment(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(param.getJSONObject("message"));
        final EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageProgressUpdate, map);
                });
            }

            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    map.put("error", data);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().downloadAttachment(msg);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void downloadThumbnail(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(param.getJSONObject("message"));
        final EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localTime", msg.localTime());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageProgressUpdate, map);
                });
            }

            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localTime", msg.localTime());
                    map.put("error", data);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().downloadThumbnail(msg);
            onSuccess(result, channelName, EMMessageHelper.toJson(msg));
        });
    }

    private void loadAllConversations(JSONObject param, String channelName, Result result) throws JSONException {
        List<EMConversation> list = new ArrayList<>(EMClient.getInstance().chatManager().getAllConversations().values());
        asyncRunnable(() -> {
            boolean retry = false;
            List<Map> conversations = new ArrayList<>();
            do{
                try{
                    retry = false;
                    Collections.sort(list, new Comparator<EMConversation>() {
                        @Override
                        public int compare(EMConversation o1, EMConversation o2) {
                            if (o1 == null && o2 == null) {
                                return 0;
                            }
                            if (o1.getLastMessage() == null) {
                                return 1;
                            }

                            if (o2.getLastMessage() == null) {
                                return -1;
                            }

                            if (o1.getLastMessage().getMsgTime() == o2.getLastMessage().getMsgTime()) {
                                return 0;
                            }

                            return o2.getLastMessage().getMsgTime() - o1.getLastMessage().getMsgTime() > 0 ? 1 : -1;
                        }
                    });
                    for (EMConversation conversation : list) {
                        conversations.add(EMConversationHelper.toJson(conversation));
                    }
                }catch(IllegalArgumentException e) {
                    retry = true;
                }
            }while (retry);
            onSuccess(result, channelName, conversations);
        });
    }

    private void getConversationsFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(() -> {
            try {
                List<EMConversation> list = new ArrayList<>(
                        EMClient.getInstance().chatManager().fetchConversationsFromServer().values());
                Collections.sort(list, new Comparator<EMConversation>() {
                    @Override
                    public int compare(EMConversation o1, EMConversation o2) {
                        if (o1.getLastMessage() == null) {
                            return 1;
                        }

                        if (o2.getLastMessage() == null) {
                            return -1;
                        }

                        if (o1.getLastMessage().getMsgTime() == o2.getLastMessage().getMsgTime()) {
                            return 0;
                        }

                        return o2.getLastMessage().getMsgTime() - o1.getLastMessage().getMsgTime() > 0 ? 1 : -1;
                    }
                });
                List<Map> conversations = new ArrayList<>();
                for (EMConversation conversation : list) {
                    conversations.add(EMConversationHelper.toJson(conversation));
                }
                onSuccess(result, channelName, conversations);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void deleteConversation(JSONObject param, String channelName, Result result) throws JSONException {
        String conId = param.getString("con_id");
        boolean isDelete = param.getBoolean("deleteMessages");
        asyncRunnable(() -> {
            boolean ret = EMClient.getInstance().chatManager().deleteConversation(conId, isDelete);
            onSuccess(result, channelName, ret);
        });
    }

    private void fetchHistoryMessages(JSONObject param, String channelName, Result result) throws JSONException {
        String conId = param.getString("con_id");
        EMConversationType type = EMConversationHelper.typeFromInt(param.getInt("type"));
        int pageSize = param.getInt("pageSize");
        String startMsgId = param.getString("startMsgId");
        asyncRunnable(() -> {
            try {
                EMCursorResult<EMMessage> cursorResult = EMClient.getInstance().chatManager().fetchHistoryMessages(conId,
                        type, pageSize, startMsgId);
                onSuccess(result, channelName, EMCursorResultHelper.toJson(cursorResult));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void searchChatMsgFromDB(JSONObject param, String channelName, Result result) throws JSONException {
        String keywords = param.getString("keywords");
        long timeStamp = param.getLong("timeStamp");
        int count = param.getInt("maxCount");
        String from = param.getString("from");
        EMSearchDirection direction = searchDirectionFromString(param.getString("direction"));
        asyncRunnable(() -> {
            List<EMMessage> msgList = EMClient.getInstance().chatManager().searchMsgFromDB(keywords, timeStamp, count,
                    from, direction);
            List<Map> messages = new ArrayList<>();
            for (EMMessage msg : msgList) {
                messages.add(EMMessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }


    private void asyncFetchGroupMessageAckFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msg_id");
        String ackId = null;
        if (param.has("ack_id")){
            ackId = param.getString("ack_id");
        }
        int pageSize = param.getInt("pageSize");

        EMValueWrapperCallBack<EMCursorResult<EMGroupReadAck>> callBack = new EMValueWrapperCallBack<EMCursorResult<EMGroupReadAck>>(result,
                channelName) {
            @Override
            public void onSuccess(EMCursorResult<EMGroupReadAck> result) {
                updateObject(EMCursorResultHelper.toJson(result));
            }
        };

        EMClient.getInstance().chatManager().asyncFetchGroupReadAcks(msgId, pageSize, ackId, callBack);
    }


    private void deleteRemoteConversation(JSONObject param, String channelName, Result result) throws JSONException {
        String conversationId = param.getString("conversationId");
        EMConversationType type = typeFromInt(param.getInt("conversationType"));
        boolean isDeleteRemoteMessage = param.getBoolean("isDeleteRemoteMessage");
        EMClient.getInstance().chatManager().deleteConversationFromServer(conversationId, type, isDeleteRemoteMessage, new EMWrapperCallBack(result, channelName, null));
    }

    private void deleteMessagesBefore(JSONObject param, String channelName, Result result) throws JSONException {
        long timestamp = param.getLong("timestamp");
        EMClient.getInstance().chatManager().deleteMessagesBeforeTimestamp(timestamp, new EMWrapperCallBack(result, channelName, null));
    }

    private void translateMessage(JSONObject param, String channelName, Result result) throws JSONException {
        EMMessage msg = EMMessageHelper.fromJson(param.getJSONObject("message"));
        List<String> list = new ArrayList<String>();
        if (param.has("languages")){
            JSONArray array = param.getJSONArray("languages");
            for (int i = 0; i < array.length(); i++) {
                list.add(array.getString(i));
            }
        }
        EMClient.getInstance().chatManager().translateMessage(msg, list, new EMValueWrapperCallBack<EMMessage>(result, channelName){
            @Override
            public void onSuccess(EMMessage object) {
                updateObject(EMMessageHelper.toJson(object));
            }
        });
    }

    private void fetchSupportedLanguages(JSONObject param, String channelName, Result result) throws JSONException {
        EMClient.getInstance().chatManager().fetchSupportLanguages(new EMValueWrapperCallBack<List<EMLanguage>>(result, channelName){
            @Override
            public void onSuccess(List<EMLanguage> object) {
                List<Map> list = new ArrayList<>();
                for (EMLanguage language : object) {
                    list.add(EMLanguageHelper.toJson(language));
                }
                updateObject(list);
            }
        });
    }

    private void addReaction(JSONObject param, String channelName, Result result) throws JSONException {
        String reaction = param.getString("reaction");
        String msgId = param.getString("msgId");
        EMClient.getInstance().chatManager().asyncAddReaction(msgId, reaction, new EMWrapperCallBack(result, channelName, null));
    }

    private void removeReaction(JSONObject param, String channelName, Result result) throws JSONException {
        String reaction = param.getString("reaction");
        String msgId = param.getString("msgId");
        EMClient.getInstance().chatManager().asyncRemoveReaction(msgId, reaction, new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchReactionList(JSONObject param, String channelName, Result result) throws JSONException {
        List<String> msgIds = new ArrayList<>();
        JSONArray ja = param.getJSONArray("msgIds");
        for (int i = 0; i < ja.length(); i++) {
            msgIds.add(ja.getString(i));
        }
        String groupId = null;
        if (param.has("groupId")) {
            groupId = param.getString("groupId");
        }
        EMMessage.ChatType type = EMMessage.ChatType.Chat;
        int iType = param.getInt("chatType");
        if (iType == 0) {
            type = EMMessage.ChatType.Chat;
        } else if(iType == 1) {
            type = EMMessage.ChatType.GroupChat;
        } else {
            type = EMMessage.ChatType.ChatRoom;
        }
        EMClient.getInstance().chatManager().asyncGetReactionList(msgIds, type, groupId, new EMValueWrapperCallBack<Map<String, List<EMMessageReaction>>>(result, channelName){
            @Override
            public void onSuccess(Map<String, List<EMMessageReaction>> object) {
                HashMap<String, List<Map<String, Object>>> map =  new HashMap<>();
                if (object != null) {
                    for (Map.Entry<String, List<EMMessageReaction>> entry: object.entrySet()) {
                        List<EMMessageReaction> list = entry.getValue();
                        ArrayList<Map<String, Object>> ary = new ArrayList<>();
                        for (int i = 0; i < list.size(); i++) {
                            ary.add(EMMessageReactionHelper.toJson(list.get(i)));
                        }
                        map.put(entry.getKey(), ary);
                    }
                }
                updateObject(map);
            }
        });
    }

    private void fetchReactionDetail(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msgId");
        String reaction = param.getString("reaction");
        String cursor = null;
        if (param.has("cursor")) {
            cursor = param.getString("cursor");
        }
        int pageSize = param.getInt("pageSize");
        EMClient.getInstance().chatManager().asyncGetReactionDetail(msgId, reaction, cursor, pageSize, new EMValueWrapperCallBack<EMCursorResult<EMMessageReaction>>(result, channelName) {
            @Override
            public void onSuccess(EMCursorResult<EMMessageReaction> object) {
                updateObject(EMCursorResultHelper.toJson(object));
            }
        });
    }

    private void reportMessage(JSONObject param, String channelName, Result result) throws JSONException {
        String msgId = param.getString("msgId");
        String tag = param.getString("tag");
        String reason = param.getString("reason");
        EMClient.getInstance().chatManager().asyncReportMessage(msgId, tag, reason, new EMWrapperCallBack(result, channelName, true));
    }

    @Override
    public void unRegisterEaseListener() {
        EMClient.getInstance().chatManager().removeMessageListener(messageListener);
        EMClient.getInstance().chatManager().removeConversationListener(conversationListener);
    }

    private void registerEaseListener() {

        messageListener = new EMMessageListener() {
            @Override
            public void onMessageReceived(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onMessagesReceived, msgList));
            }

            @Override
            public void onCmdMessageReceived(List<EMMessage> messages) {

                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onCmdMessagesReceived, msgList));
            }

            @Override
            public void onMessageRead(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                    post(() -> messageChannel.invokeMethod(EMSDKMethod.onMessageReadAck,
                            EMMessageHelper.toJson(message)));
                }

                post(() -> channel.invokeMethod(EMSDKMethod.onMessagesRead, msgList));
            }

            @Override
            public void onMessageDelivered(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                    post(() -> messageChannel.invokeMethod(EMSDKMethod.onMessageDeliveryAck,
                            EMMessageHelper.toJson(message)));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onMessagesDelivered, msgList));
            }

            @Override
            public void onMessageRecalled(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(EMMessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onMessagesRecalled, msgList));
            }

            @Override
            public void onGroupMessageRead(List<EMGroupReadAck> var1) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMGroupReadAck ack : var1) {
                    msgList.add(EMGroupAckHelper.toJson(ack));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onGroupMessageRead, msgList));
            }

            @Override
            public void onReadAckForGroupMessageUpdated() {
                post(() -> channel.invokeMethod(EMSDKMethod.onReadAckForGroupMessageUpdated, null));
            }

            @Override
            public void onReactionChanged(List<EMMessageReactionChange> messageReactionChangeList) {
                ArrayList<Map<String, Object>> list = new ArrayList<>();
                for (EMMessageReactionChange change : messageReactionChangeList) {
                    list.add(EMMessageReactionChangeHelper.toJson(change));
                }
                post(() -> channel.invokeMethod(EMSDKMethod.onMessageReactionDidChange, list));
            }
        };

        conversationListener = new EMConversationListener() {
            @Override
            public void onCoversationUpdate() {
                Map<String, Object> data = new HashMap<>();
                post(() -> channel.invokeMethod(EMSDKMethod.onConversationUpdate, data));
            }

            @Override
            public void onConversationRead(String from, String to) {
                Map<String, Object> data = new HashMap<>();
                data.put("from", from);
                data.put("to", to);
                post(() -> channel.invokeMethod(EMSDKMethod.onConversationHasRead, data));
            }
        };

        EMClient.getInstance().chatManager().addMessageListener(messageListener);
        EMClient.getInstance().chatManager().addConversationListener(conversationListener);
    }

    private EMConversation.EMSearchDirection searchDirectionFromString(String direction) {
        return direction.equals("up") ? EMConversation.EMSearchDirection.UP : EMConversation.EMSearchDirection.DOWN;
    }

    private EMConversation.EMConversationType typeFromInt(int intType) {
        if (intType == 0){
            return EMConversationType.Chat;
        }else if(intType == 1){
            return EMConversationType.GroupChat;
        }else {
            return EMConversationType.ChatRoom;
        }
    }
}
