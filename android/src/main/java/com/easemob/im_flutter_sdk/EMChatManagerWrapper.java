package com.easemob.im_flutter_sdk;

import com.hyphenate.EMConversationListener;
import com.hyphenate.EMMessageListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMConversation.EMConversationType;
import com.hyphenate.chat.EMConversation.EMSearchDirection;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMGroupReadAck;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.exceptions.HyphenateException;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
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

public class EMChatManagerWrapper extends EMWrapper implements MethodCallHandler {

    private MethodChannel messageChannel;
    EMChatManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        messageChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.easemob.im/em_message", JSONMethodCodec.INSTANCE);
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.sendMessage.equals(call.method)) {
                sendMessage(param, EMSDKMethod.sendMessage, result);
            } else if (EMSDKMethod.resendMessage.equals(call.method)) {
                resendMessage(param, EMSDKMethod.resendMessage, result);
            } else if (EMSDKMethod.ackMessageRead.equals(call.method)) {
                ackMessageRead(param, EMSDKMethod.ackMessageRead, result);
            } else if (EMSDKMethod.ackGroupMessageRead.equals(call.method)) {
                ackGroupMessageRead(param, EMSDKMethod.ackGroupMessageRead, result);
            } else if (EMSDKMethod.ackConversationRead.equals(call.method)) {
                ackConversationRead(param, EMSDKMethod.ackConversationRead, result);
            } else if (EMSDKMethod.recallMessage.equals(call.method)) {
                recallMessage(param, EMSDKMethod.recallMessage, result);
            } else if (EMSDKMethod.getConversation.equals(call.method)) {
                getConversation(param, EMSDKMethod.getConversation, result);
            } else if (EMSDKMethod.markAllChatMsgAsRead.equals(call.method)) {
                markAllChatMsgAsRead(param, EMSDKMethod.markAllChatMsgAsRead, result);
            } else if (EMSDKMethod.getUnreadMessageCount.equals(call.method)) {
                getUnreadMessageCount(param, EMSDKMethod.getUnreadMessageCount, result);
            } else if (EMSDKMethod.updateChatMessage.equals(call.method)) {
                updateChatMessage(param, EMSDKMethod.updateChatMessage, result);
            } else if (EMSDKMethod.downloadAttachment.equals(call.method)) {
                downloadAttachment(param, EMSDKMethod.downloadAttachment, result);
            } else if (EMSDKMethod.downloadThumbnail.equals(call.method)) {
                downloadThumbnail(param, EMSDKMethod.downloadThumbnail, result);
            } else if (EMSDKMethod.importMessages.equals(call.method)) {
                importMessages(param, EMSDKMethod.importMessages, result);
            } else if (EMSDKMethod.loadAllConversations.equals(call.method)) {
                loadAllConversations(param, EMSDKMethod.loadAllConversations, result);
            } else if (EMSDKMethod.getConversationsFromServer.equals(call.method)) {
                getConversationsFromServer(param, EMSDKMethod.getConversationsFromServer, result);
            } else if (EMSDKMethod.deleteConversation.equals(call.method)) {
                deleteConversation(param, EMSDKMethod.deleteConversation, result);
            } else if (EMSDKMethod.fetchHistoryMessages.equals(call.method)) {
                fetchHistoryMessages(param, EMSDKMethod.fetchHistoryMessages, result);
            } else if (EMSDKMethod.searchChatMsgFromDB.equals(call.method)) {
                searchChatMsgFromDB(param, EMSDKMethod.searchChatMsgFromDB, result);
            } else if (EMSDKMethod.getMessage.equals(call.method)) {
                getMessage(param, EMSDKMethod.getMessage, result);
            } else if (EMSDKMethod.asyncFetchGroupAcks.equals(call.method)) {
                asyncFetchGroupMessageAckFromServer(param, EMSDKMethod.asyncFetchGroupAcks, result);
            } else {
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
        if (param.has("content")) {
            content = param.getString("content");
        }
        String finalContent = content;
        asyncRunnable(() -> {
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
                }
                onSuccess(result, channelName, true);
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
        EMConversationType type = EMConversationHelper.typeFromInt(param.getInt("type"));

        asyncRunnable(() -> {
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conId, type, true);
            onSuccess(result, channelName, EMConversationHelper.toJson(conversation));
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
        asyncRunnable(() -> {
            List<EMConversation> list = new ArrayList<>(
                    EMClient.getInstance().chatManager().getAllConversations().values());
            Collections.sort(list, new Comparator<EMConversation>() {
                @Override
                public int compare(EMConversation o1, EMConversation o2) {
                    if (o1.getLastMessage() == null) {
                        return 1;
                    }

                    if (o2.getLastMessage() == null) {
                        return -1;
                    }
                    return o2.getLastMessage().getMsgTime() - o1.getLastMessage().getMsgTime() > 0 ? 1 : -1;
                }
            });
            List<Map> conversations = new ArrayList<>();
            for (EMConversation conversation : list) {
                conversations.add(EMConversationHelper.toJson(conversation));
            }
            onSuccess(result, channelName, conversations);
        });
    }

    private void getConversationsFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(() -> {
            try {
                List<EMConversation> list = new ArrayList<>(
                        EMClient.getInstance().chatManager().fetchConversationsFromServer().values());
                Collections.sort(list,
                        (o1, o2) -> (o2.getLastMessage().getMsgTime() - o1.getLastMessage().getMsgTime() > 0 ? 1 : -1));
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
        String ackId = param.getString("ack_id");
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

    private void registerEaseListener() {
        EMClient.getInstance().chatManager().addMessageListener(new EMMessageListener() {
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
            public void onMessageChanged(EMMessage message, Object change) {
                Map<String, Object> data = new HashMap<>();
                data.put("message", EMMessageHelper.toJson(message));
                post(() -> channel.invokeMethod(EMSDKMethod.onMessageStatusChanged, data));
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

            }
        });
        // setup conversation listener
        EMClient.getInstance().chatManager().addConversationListener(new EMConversationListener() {
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
        });
    }

    private EMConversation.EMSearchDirection searchDirectionFromString(String direction) {
        return direction == "up" ? EMConversation.EMSearchDirection.UP : EMConversation.EMSearchDirection.DOWN;
    }
}
