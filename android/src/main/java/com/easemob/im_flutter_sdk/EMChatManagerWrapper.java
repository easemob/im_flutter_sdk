package com.easemob.im_flutter_sdk;

import com.hyphenate.EMConversationListener;
import com.hyphenate.EMMessageListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.*;
import com.hyphenate.chat.EMConversation.EMSearchDirection;
import com.hyphenate.chat.EMConversation.EMConversationType;

import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMMessage;
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
        JSONObject params = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.sendMessage.equals(call.method)) {
                sendMessage(params, call.method, result);
            } else if (EMSDKMethod.resendMessage.equals(call.method)) {
                resendMessage(params, call.method, result);
            } else if (EMSDKMethod.ackMessageRead.equals(call.method)) {
                ackMessageRead(params, call.method, result);
            } else if (EMSDKMethod.ackGroupMessageRead.equals(call.method)) {
                ackGroupMessageRead(params, call.method, result);
            } else if (EMSDKMethod.ackConversationRead.equals(call.method)) {
                ackConversationRead(params, call.method, result);
            } else if (EMSDKMethod.recallMessage.equals(call.method)) {
                recallMessage(params, call.method, result);
            } else if (EMSDKMethod.getConversation.equals(call.method)) {
                getConversation(params, call.method, result);
            } else if (EMSDKMethod.getThreadConversation.equals(call.method)) {
                getThreadConversation(params, call.method, result);
            } else if (EMSDKMethod.markAllChatMsgAsRead.equals(call.method)) {
                markAllChatMsgAsRead(params, call.method, result);
            } else if (EMSDKMethod.getUnreadMessageCount.equals(call.method)) {
                getUnreadMessageCount(params, call.method, result);
            } else if (EMSDKMethod.updateChatMessage.equals(call.method)) {
                updateChatMessage(params, call.method, result);
            } else if (EMSDKMethod.downloadAttachment.equals(call.method)) {
                downloadAttachment(params, call.method, result);
            } else if (EMSDKMethod.downloadThumbnail.equals(call.method)) {
                downloadThumbnail(params, call.method, result);
            } else if (EMSDKMethod.downloadMessageAttachmentInCombine.equals(call.method)) {
                downloadMessageAttachmentInCombine(params, call.method, result);
            } else if (EMSDKMethod.downloadMessageThumbnailInCombine.equals(call.method)) {
                downloadMessageThumbnailInCombine(params, call.method, result);
            } else if (EMSDKMethod.importMessages.equals(call.method)) {
                importMessages(params, call.method, result);
            } else if (EMSDKMethod.loadAllConversations.equals(call.method)) {
                loadAllConversations(params, call.method, result);
            } else if (EMSDKMethod.getConversationsFromServer.equals(call.method)) {
                getConversationsFromServer(params, call.method, result);
            } else if (EMSDKMethod.deleteConversation.equals(call.method)) {
                deleteConversation(params, call.method, result);
            } else if (EMSDKMethod.fetchHistoryMessages.equals(call.method)) {
                fetchHistoryMessages(params, call.method, result);
            } else if (EMSDKMethod.fetchHistoryMessagesByOptions.equals(call.method)) {
                fetchHistoryMessagesByOptions(params, call.method, result);
            } else if (EMSDKMethod.searchChatMsgFromDB.equals(call.method)) {
                searchChatMsgFromDB(params, call.method, result);
            } else if (EMSDKMethod.getMessage.equals(call.method)) {
                getMessage(params, call.method, result);
            } else if (EMSDKMethod.asyncFetchGroupAcks.equals(call.method)){
                asyncFetchGroupMessageAckFromServer(params, call.method, result);
            } else if (EMSDKMethod.deleteRemoteConversation.equals(call.method)){
                deleteRemoteConversation(params, call.method, result);
            } else if (EMSDKMethod.deleteMessagesBeforeTimestamp.equals(call.method)) {
                deleteMessagesBefore(params, call.method, result);
            } else if (EMSDKMethod.translateMessage.equals(call.method)) {
                translateMessage(params, call.method, result);
            } else if (EMSDKMethod.fetchSupportedLanguages.equals(call.method)) {
                fetchSupportedLanguages(params, call.method, result);
            } else if (EMSDKMethod.addReaction.equals(call.method)) {
                addReaction(params, call.method, result);
            } else if (EMSDKMethod.removeReaction.equals(call.method)) {
                removeReaction(params, call.method, result);
            } else if (EMSDKMethod.fetchReactionList.equals(call.method)) {
                fetchReactionList(params, call.method, result);
            } else if (EMSDKMethod.fetchReactionDetail.equals(call.method)) {
                fetchReactionDetail(params, call.method, result);
            } else if (EMSDKMethod.reportMessage.equals(call.method)) {
                reportMessage(params, call.method, result);
            } else if (EMSDKMethod.fetchConversationsFromServerWithPage.equals(call.method)) {
                getConversationsFromServerWithPage(params, call.method, result);
            } else if (EMSDKMethod.removeMessagesFromServerWithMsgIds.equals(call.method)) {
                removeMessagesFromServerWithMsgIds(params, call.method, result);
            } else if (EMSDKMethod.removeMessagesFromServerWithTs.equals(call.method)) {
                removeMessagesFromServerWithTs(params, call.method, result);
            } else if (EMSDKMethod.getConversationsFromServerWithCursor.equals(call.method)) {
                getConversationsFromServerWithCursor(params, call.method, result);
            } else if (EMSDKMethod.getPinnedConversationsFromServerWithCursor.equals(call.method)) {
                getPinnedConversationsFromServerWithCursor(params, call.method, result);
            } else if (EMSDKMethod.pinConversation.equals(call.method)) {
                pinConversation(params, call.method, result);
            } else if (EMSDKMethod.modifyMessage.equals(call.method)) {
                modifyMessage(params, call.method, result);
            } else if (EMSDKMethod.downloadAndParseCombineMessage.equals(call.method)) {
                downloadAndParseCombineMessage(params, call.method, result);
            }
            // 450
            else if (EMSDKMethod.addRemoteAndLocalConversationsMark.equals(call.method)) {
                addRemoteAndLocalConversationsMark(params, call.method, result);
            }
            else if (EMSDKMethod.deleteRemoteAndLocalConversationsMark.equals(call.method)) {
                deleteRemoteAndLocalConversationsMark(params, call.method, result);
            }
            else if (EMSDKMethod.fetchConversationsByOptions.equals(call.method)) {
                fetchConversationsByOptions(params, call.method, result);
            }
            else if (EMSDKMethod.deleteAllMessageAndConversation.equals(call.method)) {
                deleteAllMessageAndConversation(params, call.method, result);
            }
            else if (EMSDKMethod.pinMessage.equals(call.method)) {
                pinMessage(params, call.method, result);
            }
            else if (EMSDKMethod.unpinMessage.equals(call.method)) {
                unpinMessage(params, call.method, result);
            }
            else if (EMSDKMethod.fetchPinnedMessages.equals(call.method)) {
                fetchPinnedMessages(params, call.method, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException ignored) {

        }
    }

    private void sendMessage(JSONObject params, String channelName, Result result) throws JSONException {
        final EMMessage msg = EMMessageHelper.fromJson(params);
        final String localId = msg.getMsgId();
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(msg));
                    map.put("localId", localId);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", localId);
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
                    map.put("localId", localId);
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

    private void resendMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(params);
        EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        if (msg == null) {
            msg = tempMsg;
        }
        msg.setStatus(EMMessage.Status.CREATE);
        EMMessage finalMsg = msg;
        final String localId = finalMsg.getMsgId();
        finalMsg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", EMMessageHelper.toJson(finalMsg));
                    map.put("localId", localId);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", localId);
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
                    map.put("localId", localId);
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

    private void ackMessageRead(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msg_id");
        String to = params.getString("to");

        asyncRunnable(() -> {
            try {
                EMClient.getInstance().chatManager().ackMessageRead(to, msgId);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void ackGroupMessageRead(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msg_id");
        String to = params.getString("group_id");
        String content = null;
        if(params.has("content")) {
            content = params.getString("content");
        }
        String finalContent = content;
        asyncRunnable(()->{
            try {
                EMClient.getInstance().chatManager().ackGroupMessageRead(to, msgId, finalContent);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void ackConversationRead(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("convId");
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().chatManager().ackConversationRead(conversationId);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void recallMessage(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msg_id");

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

    private void getMessage(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msg_id");

        asyncRunnable(() -> {
            EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
            if(msg == null) {
                onSuccess(result, channelName, null);
            }else {
                onSuccess(result, channelName, EMMessageHelper.toJson(msg));
            }
        });
    }

    private void getConversation(JSONObject params, String channelName, Result result) throws JSONException {
        String conId = params.getString("convId");
        boolean createIfNeed = true;
        if (params.has("createIfNeed")) {
            createIfNeed = params.getBoolean("createIfNeed");
        }

        EMConversationType type = EMConversationHelper.typeFromInt(params.getInt("type"));

        boolean finalCreateIfNeed = createIfNeed;
        asyncRunnable(() -> {
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conId, type, finalCreateIfNeed);
            onSuccess(result, channelName, conversation != null ? EMConversationHelper.toJson(conversation) : null);
        });
    }

    private void getThreadConversation(JSONObject params, String channelName, Result result) throws JSONException {
        String conId = params.getString("convId");
        asyncRunnable(() -> {
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conId, EMConversationType.GroupChat, true, true);
            onSuccess(result, channelName, conversation != null ? EMConversationHelper.toJson(conversation) : null);
        });
    }

    private void markAllChatMsgAsRead(JSONObject params, String channelName, Result result) throws JSONException {
       boolean ret = EMClient.getInstance().chatManager().markAllConversationsAsRead();

        asyncRunnable(() -> {
            onSuccess(result, channelName, ret);
        });
    }

    private void getUnreadMessageCount(JSONObject params, String channelName, Result result) throws JSONException {
        int count = EMClient.getInstance().chatManager().getUnreadMessageCount();

        asyncRunnable(() -> {
            onSuccess(result, channelName, count);
        });
    }

    private void getConversationsFromServerWithPage(JSONObject params, String channelName, Result result) throws JSONException {
        int pageNum = params.getInt("pageNum");
        int pageSize = params.getInt("pageSize");
        EMValueWrapperCallBack<Map<String, EMConversation>> callBack = new EMValueWrapperCallBack<Map<String, EMConversation>>(result,
                channelName) {
            @Override
            public void onSuccess(Map<String, EMConversation> object) {
                ArrayList<EMConversation>list = new ArrayList<>(object.values());
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
                    updateObject(conversations);
                });
            }
        };
        EMClient.getInstance().chatManager().asyncFetchConversationsFromServer(pageNum, pageSize, callBack);
    }

    private void removeMessagesFromServerWithMsgIds(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("convId");
        EMConversation.EMConversationType type = EMConversationHelper.typeFromInt(params.getInt("type"));
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conversationId, type, true);

        JSONArray jsonArray = params.getJSONArray("msgIds");

        ArrayList<String> msgIds = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            msgIds.add((String) jsonArray.get(i));
        }

        conversation.removeMessagesFromServer(msgIds, new EMWrapperCallBack(result, channelName, null));
    }

    private void removeMessagesFromServerWithTs(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("convId");
        EMConversation.EMConversationType type = EMConversationHelper.typeFromInt(params.getInt("type"));
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conversationId, type, true);
        long timestamp = 0;
        if(params.has("timestamp")) {
            timestamp = params.getLong("timestamp");
        }
        conversation.removeMessagesFromServer(timestamp, new EMWrapperCallBack(result, channelName, null));
    }

    private void updateChatMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage msg = EMMessageHelper.fromJson(params.getJSONObject("message"));
        EMMessage dbMsg =
                EMClient.getInstance().chatManager().getMessage(params.getJSONObject("message").getString("msgId"));
        this.mergeMessage(msg, dbMsg);
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().updateMessage(dbMsg);
            onSuccess(result, channelName, EMMessageHelper.toJson(dbMsg));
        });
    }

    private void importMessages(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray ary = params.getJSONArray("messages");
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


    private void downloadMessageAttachmentInCombine(JSONObject params, String channelName, Result result) throws JSONException {
        final EMMessage msg = EMMessageHelper.fromJson(params.getJSONObject("message"));
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.SUCCESSED, msg, false));
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", msg.getMsgId());
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
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.FAILED, msg, false));
                    map.put("localId", msg.getMsgId());
                    map.put("error", data);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().downloadAttachment(msg);
            onSuccess(result, channelName, updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.DOWNLOADING, msg, false));
        });
    }

    private void downloadMessageThumbnailInCombine(JSONObject params, String channelName, Result result) throws JSONException {
        final EMMessage msg = EMMessageHelper.fromJson(params.getJSONObject("message"));
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.SUCCESSED, msg, true));
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", msg.getMsgId());
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
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.FAILED, msg, true));
                    map.put("localId", msg.getMsgId());
                    map.put("error", data);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().downloadThumbnail(msg);
            onSuccess(result, channelName, updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.DOWNLOADING, msg, true));
        });
    }
    private void downloadAttachment(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(params.getJSONObject("message"));
        final EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.SUCCESSED, msg, false));
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", msg.getMsgId());
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
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.FAILED, msg, false));
                    map.put("localId", msg.getMsgId());
                    map.put("error", data);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().downloadAttachment(msg);
            onSuccess(result, channelName, updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.DOWNLOADING, msg, false));
        });
    }

    private void downloadThumbnail(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage tempMsg = EMMessageHelper.fromJson(params.getJSONObject("message"));
        final EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.SUCCESSED, msg, true));
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(EMSDKMethod.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", msg.getMsgId());
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
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.FAILED, msg, true));
                    map.put("localId", msg.getMsgId());
                    map.put("error", data);
                    messageChannel.invokeMethod(EMSDKMethod.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().downloadThumbnail(msg);
            onSuccess(result, channelName, updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.DOWNLOADING, msg, true));
        });
    }

    private Map<String, Object> updateDownloadStatus(EMFileMessageBody.EMDownloadStatus downloadStatus, EMMessage msg, boolean isThumbnail) {
        boolean canUpdate = false;
        switch (msg.getType()) {
            case FILE:
            case VOICE: {
                if (isThumbnail) {
                    break;
                }
            }
            case IMAGE:
            case VIDEO:
            {
                canUpdate = true;
            }
            break;
            default:
                break;
        }
        if (canUpdate) {
            EMMessageBody body = msg.getBody();
            if (msg.getType() == EMMessage.Type.FILE) {
                EMFileMessageBody tmpBody = (EMFileMessageBody) body;
                tmpBody.setDownloadStatus(downloadStatus);
                body = tmpBody;
            }else if (msg.getType() == EMMessage.Type.VOICE) {
                EMVoiceMessageBody tmpBody = (EMVoiceMessageBody) body;
                tmpBody.setDownloadStatus(downloadStatus);
                body = tmpBody;
            }else if (msg.getType() == EMMessage.Type.IMAGE) {
                EMImageMessageBody tmpBody = (EMImageMessageBody) body;
                if (isThumbnail) {
                    // android not support now.
                    // tmpBody.setThumbnailDownloadStatus(downloadStatus);
                }else {
                    tmpBody.setDownloadStatus(downloadStatus);
                }

                body = tmpBody;
            }else if (msg.getType() == EMMessage.Type.VIDEO) {
                EMVideoMessageBody tmpBody = (EMVideoMessageBody) body;
                if (isThumbnail) {
                    tmpBody.setThumbnailDownloadStatus(downloadStatus);
                }else {
                    tmpBody.setDownloadStatus(downloadStatus);
                }

                body = tmpBody;
            }

            msg.setBody(body);
        }
        return EMMessageHelper.toJson(msg);
    }

    private void loadAllConversations(JSONObject params, String channelName, Result result) throws JSONException {
        if (EMClient.getInstance().getCurrentUser() == null || EMClient.getInstance().getCurrentUser().length() == 0) {
            onSuccess(result, channelName, new ArrayList<>());
            return;
        }
        List<EMConversation> list = EMClient.getInstance().chatManager().getAllConversationsBySort();
        List<Map> conversations = new ArrayList<>();
        for (EMConversation conversation : list) {
            conversations.add(EMConversationHelper.toJson(conversation));
        }
        onSuccess(result, channelName, conversations);
    }

    private void getConversationsFromServer(JSONObject params, String channelName, Result result) throws JSONException {
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

    private void deleteConversation(JSONObject params, String channelName, Result result) throws JSONException {
        String conId = params.getString("convId");
        boolean isDelete = params.getBoolean("deleteMessages");
        asyncRunnable(() -> {
            boolean ret = EMClient.getInstance().chatManager().deleteConversation(conId, isDelete);
            onSuccess(result, channelName, ret);
        });
    }

    private void fetchHistoryMessages(JSONObject params, String channelName, Result result) throws JSONException {
        String conId = params.getString("convId");
        EMConversationType type = EMConversationHelper.typeFromInt(params.getInt("type"));
        int pageSize = params.getInt("pageSize");
        String startMsgId = params.getString("startMsgId");
        EMSearchDirection direction = params.optInt("direction") == 0 ? EMSearchDirection.UP : EMSearchDirection.DOWN;
        asyncRunnable(() -> {
            try {
                EMCursorResult<EMMessage> cursorResult = EMClient.getInstance().chatManager().fetchHistoryMessages(conId,
                        type, pageSize, startMsgId, direction);
                onSuccess(result, channelName, EMCursorResultHelper.toJson(cursorResult));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void fetchHistoryMessagesByOptions(JSONObject params, String channelName, Result result) throws JSONException {
        String conId = params.getString("convId");
        EMConversationType type = EMConversationHelper.typeFromInt(params.getInt("type"));
        int pageSize = params.getInt("pageSize");
        String cursor = null;
        if (params.has("cursor")) {
             cursor = params.getString("cursor");
        }
        EMFetchMessageOption option = null;
        if (params.has("options")) {
            option = FetchHistoryOptionsHelper.fromJson(params.getJSONObject("options"));
        }

        EMValueWrapperCallBack<EMCursorResult<EMMessage>> callBack = new EMValueWrapperCallBack<EMCursorResult<EMMessage>>(result,
                channelName) {
            @Override
            public void onSuccess(EMCursorResult<EMMessage> result) {
                updateObject(EMCursorResultHelper.toJson(result));
            }
        };

        EMClient.getInstance().chatManager().asyncFetchHistoryMessages(conId, type, pageSize, cursor, option, callBack);
    }


    private void searchChatMsgFromDB(JSONObject params, String channelName, Result result) throws JSONException {
        String keywords = params.getString("keywords");
        long timestamp = params.getLong("timestamp");
        int count = params.getInt("maxCount");
        String from = params.getString("from");
        EMSearchDirection direction = searchDirectionFromString(params.getString("direction"));
        EMConversation.EMMessageSearchScope scope;
        if(params.has("searchScope")) {
            scope = EMConversation.EMMessageSearchScope.values()[params.getInt("searchScope")];
        }else {
            scope = EMConversation.EMMessageSearchScope.ALL;
        }
        asyncRunnable(() -> {
            List<EMMessage> msgList = EMClient.getInstance().chatManager().searchMsgFromDB(keywords, timestamp, count,
                    from, direction, scope);
            List<Map> messages = new ArrayList<>();
            for (EMMessage msg : msgList) {
                messages.add(EMMessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }


    private void asyncFetchGroupMessageAckFromServer(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msg_id");
        String ackId = null;
        if (params.has("ack_id")){
            ackId = params.getString("ack_id");
        }
        int pageSize = params.getInt("pageSize");

        EMValueWrapperCallBack<EMCursorResult<EMGroupReadAck>> callBack = new EMValueWrapperCallBack<EMCursorResult<EMGroupReadAck>>(result,
                channelName) {
            @Override
            public void onSuccess(EMCursorResult<EMGroupReadAck> result) {
                updateObject(EMCursorResultHelper.toJson(result));
            }
        };

        EMClient.getInstance().chatManager().asyncFetchGroupReadAcks(msgId, pageSize, ackId, callBack);
    }


    private void deleteRemoteConversation(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("conversationId");
        EMConversationType type = typeFromInt(params.getInt("conversationType"));
        boolean isDeleteRemoteMessage = params.getBoolean("isDeleteRemoteMessage");
        EMClient.getInstance().chatManager().deleteConversationFromServer(conversationId, type, isDeleteRemoteMessage, new EMWrapperCallBack(result, channelName, null));
    }

    private void deleteMessagesBefore(JSONObject params, String channelName, Result result) throws JSONException {
        long timestamp = params.getLong("timestamp");
        EMClient.getInstance().chatManager().deleteMessagesBeforeTimestamp(timestamp, new EMWrapperCallBack(result, channelName, null));
    }

    private void translateMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage msg = EMMessageHelper.fromJson(params.getJSONObject("message"));
        List<String> list = new ArrayList<String>();
        if (params.has("languages")){
            JSONArray array = params.getJSONArray("languages");
            for (int i = 0; i < array.length(); i++) {
                list.add(array.getString(i));
            }
        }

        EMMessage dbMsg = EMClient.getInstance().chatManager().getMessage(msg.getMsgId());
        EMClient.getInstance().chatManager().translateMessage(dbMsg, list, new EMValueWrapperCallBack<EMMessage>(result, channelName){
            @Override
            public void onSuccess(EMMessage object) {
                updateObject(EMMessageHelper.toJson(object));
            }
        });
    }

    private void fetchSupportedLanguages(JSONObject params, String channelName, Result result) throws JSONException {
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

    private void addReaction(JSONObject params, String channelName, Result result) throws JSONException {
        String reaction = params.getString("reaction");
        String msgId = params.getString("msgId");
        EMClient.getInstance().chatManager().asyncAddReaction(msgId, reaction, new EMWrapperCallBack(result, channelName, null));
    }

    private void removeReaction(JSONObject params, String channelName, Result result) throws JSONException {
        String reaction = params.getString("reaction");
        String msgId = params.getString("msgId");
        EMClient.getInstance().chatManager().asyncRemoveReaction(msgId, reaction, new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchReactionList(JSONObject params, String channelName, Result result) throws JSONException {
        List<String> msgIds = new ArrayList<>();
        JSONArray ja = params.getJSONArray("msgIds");
        for (int i = 0; i < ja.length(); i++) {
            msgIds.add(ja.getString(i));
        }
        String groupId = null;
        if (params.has("groupId")) {
            groupId = params.getString("groupId");
        }
        EMMessage.ChatType type = EMMessage.ChatType.Chat;
        int iType = params.getInt("chatType");
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

    private void fetchReactionDetail(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msgId");
        String reaction = params.getString("reaction");
        String cursor = null;
        if (params.has("cursor")) {
            cursor = params.getString("cursor");
        }
        int pageSize = params.getInt("pageSize");
        EMClient.getInstance().chatManager().asyncGetReactionDetail(msgId, reaction, cursor, pageSize, new EMValueWrapperCallBack<EMCursorResult<EMMessageReaction>>(result, channelName) {
            @Override
            public void onSuccess(EMCursorResult<EMMessageReaction> object) {
                updateObject(EMCursorResultHelper.toJson(object));
            }
        });
    }

    private void reportMessage(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msgId");
        String tag = params.getString("tag");
        String reason = params.getString("reason");
        EMClient.getInstance().chatManager().asyncReportMessage(msgId, tag, reason, new EMWrapperCallBack(result, channelName, true));
    }

    private void getConversationsFromServerWithCursor(JSONObject params, String channelName, Result result) throws JSONException {
        String cursor = params.optString("cursor");
        int pageSize = params.optInt("pageSize");
        EMClient.getInstance().chatManager().asyncFetchConversationsFromServer(pageSize, cursor, new EMValueWrapperCallBack<EMCursorResult<EMConversation>>(result, channelName){
            @Override
            public void onSuccess(EMCursorResult<EMConversation> object) {
                super.updateObject(EMCursorResultHelper.toJson(object));
            }
        });
    }
    private void getPinnedConversationsFromServerWithCursor(JSONObject params, String channelName, Result result) throws JSONException {
        String cursor = params.optString("cursor");
        int pageSize = params.optInt("pageSize");
        EMClient.getInstance().chatManager().asyncFetchPinnedConversationsFromServer(pageSize, cursor, new EMValueWrapperCallBack<EMCursorResult<EMConversation>>(result, channelName){
            @Override
            public void onSuccess(EMCursorResult<EMConversation> object) {
                super.updateObject(EMCursorResultHelper.toJson(object));
            }
        });
    }
    private void pinConversation(JSONObject params, String channelName, Result result) throws JSONException {
        String convId = params.optString("convId");
        Boolean isPinned = params.optBoolean("isPinned", false);
        EMClient.getInstance().chatManager().asyncPinConversation(convId, isPinned, new EMWrapperCallBack(result, channelName, null));
    }

    private void modifyMessage(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.optString("msgId");
        EMTextMessageBody body = EMMessageBodyHelper.textBodyFromJson(params.optJSONObject("body"));
        EMClient.getInstance().chatManager().asyncModifyMessage(msgId, body, new EMValueWrapperCallBack<EMMessage>(result, channelName) {
            @Override
            public void onSuccess(EMMessage object) {
                updateObject(EMMessageHelper.toJson(object));
            }
        });
    }
    private void downloadAndParseCombineMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage msg =  EMMessageHelper.fromJson(params.optJSONObject("message"));
        EMClient.getInstance().chatManager().downloadAndParseCombineMessage(msg, new EMValueWrapperCallBack<List<EMMessage>>(result, channelName){
            @Override
            public void onSuccess(List<EMMessage> msgList) {
                List<Map> messages = new ArrayList<>();
                for(EMMessage msg: msgList) {
                    messages.add(EMMessageHelper.toJson(msg));
                }
                updateObject(messages);
            }
        });
    }

    // 450
    private void addRemoteAndLocalConversationsMark(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray jsonArray = params.getJSONArray("convIds");
        ArrayList<String> convIds = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            convIds.add((String) jsonArray.get(i));
        }
        EMConversation.EMMarkType mark = EMConversation.EMMarkType.values()[params.getInt("mark")];
        EMClient.getInstance().chatManager().asyncAddConversationMark(convIds,mark,  new EMWrapperCallBack(result, channelName, null));
    }

    private void deleteRemoteAndLocalConversationsMark(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray jsonArray = params.getJSONArray("convIds");
        ArrayList<String> convIds = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            convIds.add((String) jsonArray.get(i));
        }
        EMConversation.EMMarkType mark = EMConversation.EMMarkType.values()[params.getInt("mark")];
        EMClient.getInstance().chatManager().asyncRemoveConversationMark(convIds,mark,  new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchConversationsByOptions(JSONObject params, String channelName, Result result) throws JSONException {
        String cursor = EMConversationFilterHelper.cursor(params);
        Boolean isPinned = EMConversationFilterHelper.pinned(params);
        Boolean isMark = EMConversationFilterHelper.hasMark(params);
        int pageSize = EMConversationFilterHelper.pageSize(params);
        if(isPinned) {
            EMClient.getInstance().chatManager().asyncFetchPinnedConversationsFromServer(pageSize, cursor, new EMValueWrapperCallBack<EMCursorResult<EMConversation>>(result, channelName){
                @Override
                public void onSuccess(EMCursorResult<EMConversation> object) {
                    super.updateObject(EMCursorResultHelper.toJson(object));
                }
            });
            return;
        }

        if(isMark){
            EMConversationFilter filter = EMConversationFilterHelper.fromJson(params);
            EMClient.getInstance().chatManager().asyncGetConversationsFromServerWithCursor(cursor, filter, new EMValueWrapperCallBack<EMCursorResult<EMConversation>>(result, channelName){
                @Override
                public void onSuccess(EMCursorResult<EMConversation> object) {
                    super.updateObject(EMCursorResultHelper.toJson(object));
                }
            });
            return;
        }

        EMClient.getInstance().chatManager().asyncFetchConversationsFromServer(pageSize, cursor, new EMValueWrapperCallBack<EMCursorResult<EMConversation>>(result, channelName){
            @Override
            public void onSuccess(EMCursorResult<EMConversation> object) {
                super.updateObject(EMCursorResultHelper.toJson(object));
            }
        });
    }

    private void deleteAllMessageAndConversation(JSONObject params, String channelName, Result result) throws JSONException {
        Boolean clearServerData = params.getBoolean("clearServerData");
        EMClient.getInstance().chatManager().asyncDeleteAllMsgsAndConversations(clearServerData, new EMWrapperCallBack(result, channelName,null));
    }

    private void pinMessage(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msgId");
        EMClient.getInstance().chatManager().asyncPinMessage(msgId, new EMWrapperCallBack(result, channelName, null));
    }

    private void unpinMessage(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msgId");
        EMClient.getInstance().chatManager().asyncUnPinMessage(msgId, new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchPinnedMessages(JSONObject params, String channelName, Result result) throws JSONException {
        String convId = params.getString("convId");
        EMClient.getInstance().chatManager().asyncGetPinnedMessagesFromServer(convId, new EMValueWrapperCallBack<List<EMMessage>>(result, channelName){
            @Override
            public void onSuccess(List<EMMessage> msgList) {
                List<Map> messages = new ArrayList<>();
                for(EMMessage msg: msgList) {
                    messages.add(EMMessageHelper.toJson(msg));
                }
                updateObject(messages);
            }
        });
    }
    @Override
    public void unRegisterEaseListener() {
        EMClient.getInstance().chatManager().removeMessageListener(messageListener);
        EMClient.getInstance().chatManager().removeConversationListener(conversationListener);
    }

    private void registerEaseListener() {

        if (messageListener != null) {
            EMClient.getInstance().chatManager().removeMessageListener(messageListener);
        }

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

            @Override
            public void onMessageContentChanged(EMMessage messageModified, String operatorId, long operationTime) {
                 Map msgMap = EMMessageHelper.toJson(messageModified);
                 Map map = new HashMap<>();
                 map.put("message", msgMap);
                 map.put("operator", operatorId);
                 map.put("operationTime", operationTime);
                post(() -> channel.invokeMethod(EMSDKMethod.onMessageContentChanged, map));
            }

            @Override
            public void onMessagePinChanged(String messageId, String conversationId, EMMessagePinInfo.PinOperation pinOperation, EMMessagePinInfo pinInfo) {
                Map map = new HashMap<>();
                map.put("messageId", messageId);
                map.put("conversationId", conversationId);
                map.put("pinOperation", pinOperation.ordinal());
                map.put("pinInfo", EMMessagePinInfoHelper.toJson(pinInfo));
                post(() -> channel.invokeMethod(EMSDKMethod.onMessagePinChanged, map));
            }
        };

        if (conversationListener != null) {
            EMClient.getInstance().chatManager().removeConversationListener(conversationListener);
        }
        conversationListener = new EMConversationListener() {

            @Override
            public void onConversationUpdate() {
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

    protected void mergeMessageBody(EMMessageBody msgBody, EMMessage dbMsg) throws JSONException {
        if (dbMsg.getType() == EMMessage.Type.TXT) {
            EMTextMessageBody text = (EMTextMessageBody)msgBody;
            EMTextMessageBody dbtext = (EMTextMessageBody)dbMsg.getBody();
            dbtext.setMessage(text.getMessage());
            dbtext.setTargetLanguages(text.getTargetLanguages());
            dbMsg.setBody(dbtext);
        } else if (dbMsg.getType() == EMMessage.Type.CMD) {
            EMCmdMessageBody cmd = (EMCmdMessageBody)msgBody;
            EMCmdMessageBody dbcmd = (EMCmdMessageBody)dbMsg.getBody();
            dbcmd.deliverOnlineOnly(cmd.isDeliverOnlineOnly());
            dbMsg.setBody(dbcmd);
        } else if (dbMsg.getType() == EMMessage.Type.IMAGE) {
            EMImageMessageBody image = (EMImageMessageBody)msgBody;
            EMImageMessageBody dbimage = (EMImageMessageBody)dbMsg.getBody();
            dbimage.setFileName(image.getFileName());
            dbimage.setLocalUrl(image.getLocalUrl());
            dbimage.setRemoteUrl(image.getRemoteUrl());
            dbimage.setSecret(image.getSecret());
            dbimage.setFileLength(image.getFileSize());
            dbimage.setDownloadStatus(image.downloadStatus());
            dbimage.setSendOriginalImage(image.isSendOriginalImage());
            dbimage.setThumbnailLocalPath(image.thumbnailLocalPath());
            dbimage.setThumbnailDownloadStatus(image.thumbnailDownloadStatus());
            dbimage.setThumbnailUrl(image.getThumbnailUrl());
            dbMsg.setBody(dbimage);
        } else if (dbMsg.getType() == EMMessage.Type.VOICE) {
            EMVoiceMessageBody voice = (EMVoiceMessageBody)msgBody;
            EMImageMessageBody dbVoice = (EMImageMessageBody)dbMsg.getBody();
            dbVoice.setFileName(voice.getFileName());
            dbVoice.setLocalUrl(voice.getLocalUrl());
            dbVoice.setRemoteUrl(voice.getRemoteUrl());
            dbVoice.setSecret(voice.getSecret());
            dbVoice.setFileLength(voice.getFileSize());
            dbVoice.setDownloadStatus(voice.downloadStatus());
            dbMsg.setBody(dbVoice);
        } else if (dbMsg.getType() == EMMessage.Type.VIDEO) {
            EMVideoMessageBody video = (EMVideoMessageBody)msgBody;
            EMVideoMessageBody dbVideo = (EMVideoMessageBody)dbMsg.getBody();
            dbVideo.setFileName(video.getFileName());
            dbVideo.setLocalUrl(video.getLocalUrl());
            dbVideo.setRemoteUrl(video.getRemoteUrl());
            dbVideo.setSecret(video.getSecret());
            dbVideo.setDownloadStatus(video.downloadStatus());
            dbVideo.setVideoFileLength(video.getVideoFileLength());
            dbVideo.setThumbnailUrl(video.getThumbnailUrl());
            dbVideo.setThumbnailSize(video.getThumbnailWidth(), video.getThumbnailHeight());
            dbVideo.setLocalThumb(video.getLocalThumb());
            dbVideo.setThumbnailSecret(video.getThumbnailSecret());
            dbVideo.setThumbnailDownloadStatus(video.thumbnailDownloadStatus());
            dbMsg.setBody(video);
        } else if (dbMsg.getType() == EMMessage.Type.LOCATION) {
            EMLocationMessageBody location = (EMLocationMessageBody)msgBody;
            dbMsg.setBody(location);
        } else if (dbMsg.getType() == EMMessage.Type.FILE) {
            EMNormalFileMessageBody file = (EMNormalFileMessageBody)msgBody;
            EMFileMessageBody dbFile = (EMFileMessageBody)dbMsg.getBody();
            dbFile.setFileName(file.getFileName());
            dbFile.setLocalUrl(file.getLocalUrl());
            dbFile.setRemoteUrl(file.getRemoteUrl());
            dbFile.setSecret(file.getSecret());
            dbFile.setDownloadStatus(file.downloadStatus());
            dbFile.setFileLength(file.getFileSize());
            dbMsg.setBody(dbFile);
        } else if (dbMsg.getType() == EMMessage.Type.CUSTOM) {
            EMCustomMessageBody custom = (EMCustomMessageBody)msgBody;
            dbMsg.setBody(custom);
        } else if (dbMsg.getType() == EMMessage.Type.COMBINE) {
            EMCombineMessageBody combine = (EMCombineMessageBody)msgBody;
            dbMsg.setBody(combine);
        }
    }

    protected void mergeMessage(EMMessage msg, EMMessage dbMsg) throws JSONException {
        dbMsg.setStatus(msg.status());
        dbMsg.setLocalTime(msg.localTime());
        dbMsg.setIsNeedGroupAck(msg.isNeedGroupAck());
        dbMsg.setIsChatThreadMessage(msg.isChatThreadMessage());
        dbMsg.setUnread(msg.isUnread());
        dbMsg.setListened(msg.isListened());
        dbMsg.setReceiverList(msg.receiverList());
        Map<String, Object> list = msg.getAttributes();
        if (list.size() > 0) {
            JSONObject jsonParams = new JSONObject(list);
            for (Map.Entry<String, Object> entry : list.entrySet()) {
                String key = entry.getKey();
                Object result = entry.getValue();
                if (result.getClass().getSimpleName().equals("Integer")) {
                    dbMsg.setAttribute(key, (Integer)result);
                } else if (result.getClass().getSimpleName().equals("Boolean")) {
                    dbMsg.setAttribute(key, (Boolean)result);
                } else if (result.getClass().getSimpleName().equals("Long")) {
                    dbMsg.setAttribute(key, (Long)result);
                } else if (result.getClass().getSimpleName().equals("Double") ||
                        result.getClass().getSimpleName().equals("Float")) {
                    dbMsg.setAttribute(key, (Double)result);
                } else if (result.getClass().getSimpleName().equals("JSONObject")) {
                    dbMsg.setAttribute(key, (JSONObject)result);
                } else if (result.getClass().getSimpleName().equals("JSONArray")) {
                    dbMsg.setAttribute(key, (JSONArray)result);
                } else {
                    dbMsg.setAttribute(key, jsonParams.getString(key));
                }
            }
        }

        this.mergeMessageBody(msg.getBody(), dbMsg);
    }
}
