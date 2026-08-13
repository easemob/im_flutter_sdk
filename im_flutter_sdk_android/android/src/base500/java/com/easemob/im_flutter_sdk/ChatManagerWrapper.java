package com.easemob.im_flutter_sdk;

import com.hyphenate.EMConversationListener;
import com.hyphenate.EMCallBack;
import com.hyphenate.EMMessageListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.util.EMLog;
import com.hyphenate.chat.*;
import com.hyphenate.chat.EMConversation.EMSearchDirection;
import com.hyphenate.chat.EMConversation.EMConversationType;

import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.exceptions.HyphenateException;

import java.util.ArrayList;
import java.lang.reflect.Method;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


public class ChatManagerWrapper extends Wrapper implements MethodCallHandler {

    private final MethodChannel messageChannel;
    private EMMessageListener messageListener;
    private EMConversationListener conversationListener;


    ChatManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerAll();
        applyVersionOverrides();
        messageChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.chat.im/chat_message", JSONMethodCodec.INSTANCE);
        registerEaseListener();
    }


    @Override
    protected void registerAll() {
        register(MethodKey.sendMessage, this::sendMessage);
        register(MethodKey.resendMessage, this::resendMessage);
        register(MethodKey.ackMessageRead, this::ackMessageRead);
        register(MethodKey.ackGroupMessageRead, this::ackGroupMessageRead);
        register(MethodKey.ackConversationRead, this::ackConversationRead);
        register(MethodKey.recallMessage, this::recallMessage);
        register(MethodKey.getConversation, this::getConversation);
        register(MethodKey.getThreadConversation, this::getThreadConversation);
        register(MethodKey.markAllChatMsgAsRead, this::markAllChatMsgAsRead);
        register(MethodKey.getUnreadMessageCount, this::getUnreadMessageCount);
        register(MethodKey.updateChatMessage, this::updateChatMessage);
        register(MethodKey.downloadAttachment, this::downloadAttachment);
        register(MethodKey.downloadBigImage, this::downloadBigImage);
        register(MethodKey.downloadThumbnail, this::downloadThumbnail);
        register(MethodKey.downloadMessageAttachmentInCombine, this::downloadMessageAttachmentInCombine);
        register(MethodKey.downloadMessageThumbnailInCombine, this::downloadMessageThumbnailInCombine);
        register(MethodKey.importMessages, this::importMessages);
        register(MethodKey.loadAllConversations, this::loadAllConversations);
        register(MethodKey.getConversationsFromServer, this::getConversationsFromServer);
        register(MethodKey.deleteConversation, this::deleteConversation);
        register(MethodKey.fetchHistoryMessages, this::fetchHistoryMessages);
        register(MethodKey.fetchHistoryMessagesByOptions, this::fetchHistoryMessagesByOptions);
        register(MethodKey.searchChatMsgFromDB, this::searchChatMsgFromDB);
        register(MethodKey.getMessage, this::getMessage);
        register(MethodKey.asyncFetchGroupAcks, this::asyncFetchGroupMessageAckFromServer);
        register(MethodKey.deleteRemoteConversation, this::deleteRemoteConversation);
        register(MethodKey.deleteMessagesBeforeTimestamp, this::deleteMessagesBefore);
        register(MethodKey.translateMessage, this::translateMessage);
        register(MethodKey.fetchSupportedLanguages, this::fetchSupportedLanguages);
        register(MethodKey.addReaction, this::addReaction);
        register(MethodKey.removeReaction, this::removeReaction);
        register(MethodKey.fetchReactionList, this::fetchReactionList);
        register(MethodKey.fetchReactionDetail, this::fetchReactionDetail);
        register(MethodKey.fetchConversationsFromServerWithPage, this::getConversationsFromServerWithPage);
        register(MethodKey.removeMessagesFromServerWithMsgIds, this::removeMessagesFromServerWithMsgIds);
        register(MethodKey.removeMessagesFromServerWithTs, this::removeMessagesFromServerWithTs);
        register(MethodKey.getConversationsFromServerWithCursor, this::getConversationsFromServerWithCursor);
        register(MethodKey.getPinnedConversationsFromServerWithCursor, this::getPinnedConversationsFromServerWithCursor);
        register(MethodKey.pinConversation, this::pinConversation);
        register(MethodKey.modifyMessage, this::modifyMessage);
        register(MethodKey.downloadAndParseCombineMessage, this::downloadAndParseCombineMessage);
        register(MethodKey.addRemoteAndLocalConversationsMark, this::addRemoteAndLocalConversationsMark);
        register(MethodKey.deleteRemoteAndLocalConversationsMark, this::deleteRemoteAndLocalConversationsMark);
        register(MethodKey.fetchConversationsByOptions, this::fetchConversationsByOptions);
        register(MethodKey.deleteAllMessageAndConversation, this::deleteAllMessageAndConversation);
        register(MethodKey.pinMessage, this::pinMessage);
        register(MethodKey.unpinMessage, this::unpinMessage);
        register(MethodKey.fetchPinnedMessages, this::fetchPinnedMessages);
        register(MethodKey.searchMsgsByOptions, this::searchMsgByOptions);
        register(MethodKey.getMessageCount, this::getMessageCount);
        register(MethodKey.getGroupMessageReadReceipts, this::getGroupMessageReadReceipts);
        register(MethodKey.searchMessagesFromServer, this::searchMessagesFromServer);
        register(MethodKey.deleteConversations, this::deleteConversations);
        register(MethodKey.loadConversationMessagesWithKeyword, this::loadConversationMessagesWithKeyword);
        register(MethodKey.loadMessagesWithIds, this::loadMessagesWithIds);
        register(MethodKey.saveMessage, this::saveMessage);
        register(MethodKey.cleanConversationsMemoryCache, this::cleanConversationsMemoryCache);
        register(MethodKey.getConversationsByType, this::getConversationsByType);
        register(MethodKey.filterConversationsFromDB, this::filterConversationsFromDB);
        register(MethodKey.setVoiceMessageListened, this::setVoiceMessageListened);
        register(MethodKey.voiceMessageToText, this::voiceMessageToText);
        register(MethodKey.voiceFileToText, this::voiceFileToText);
    }



    private void sendMessage(JSONObject params, String channelName, Result result) throws JSONException {
        final EMMessage msg = MessageHelper.fromJson(params);
        final String localId = msg.getMsgId();
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", MessageHelper.toJson(msg));
                    map.put("localId", localId);
                    messageChannel.invokeMethod(MethodKey.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", localId);
                    messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, map);
                });
            }

            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", MessageHelper.toJson(msg));
                    map.put("localId", localId);
                    map.put("error", data);
                    messageChannel.invokeMethod(MethodKey.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().sendMessage(msg);
            onSuccess(result, channelName, MessageHelper.toJson(msg));
        });
    }



    private void resendMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage tempMsg = MessageHelper.fromJson(params);
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
                    map.put("message", MessageHelper.toJson(finalMsg));
                    map.put("localId", localId);
                    messageChannel.invokeMethod(MethodKey.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", localId);
                    messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, map);
                });
            }


            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", MessageHelper.toJson(finalMsg));
                    map.put("localId", localId);
                    map.put("error", data);
                    messageChannel.invokeMethod(MethodKey.onMessageError, map);
                });
            }
        });
        EMClient.getInstance().chatManager().sendMessage(msg);
        asyncRunnable(() -> onSuccess(result, channelName, MessageHelper.toJson(finalMsg)));
    }

    private void ackMessageRead(JSONObject params, String channelName, Result result) throws JSONException {
        // 5.0 改为 asyncSendMessageReadReceipts(List<EMMessage>)
        // 【临时探测】透传原生（不拦截 null）：看 Android 原生对无效消息的真实返回
        String msgId = params.getString("msgId");
        asyncRunnable(() -> {
                EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
                List<EMMessage> msgs = new ArrayList<>();
                if (msg != null) {
                    // 5.0 asyncSendMessageReadReceipts 要求 isNeedReadReceipt=true，否则跳过
                    msg.setIsNeedReadReceipt(true);
                    msgs.add(msg);
                }
                // 临时：空列表也透传原生（原逻辑 null 时 wrapper 自己造 500）
                EMClient.getInstance().chatManager().asyncSendMessageReadReceipts(msgs, new EMWrapperCallBack(result, channelName, msg != null));

        });
    }

    private void ackGroupMessageRead(JSONObject params, String channelName, Result result) throws JSONException {
        // 5.0 改为 asyncSendMessageReadReceipts(List<EMMessage>)；【透传原生】不本地拦截
        String msgId = params.getString("msgId");
        asyncRunnable(()->{
                EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
                List<EMMessage> msgs = new ArrayList<>();
                if (msg != null) {
                    // 5.0 asyncSendMessageReadReceipts 要求 isNeedReadReceipt=true，否则跳过
                    msg.setIsNeedReadReceipt(true);
                    msgs.add(msg);
                }
                EMClient.getInstance().chatManager().asyncSendMessageReadReceipts(msgs, new EMWrapperCallBack(result, channelName, msg != null));
        });
    }

    private void ackConversationRead(JSONObject params, String channelName, Result result) throws JSONException {
        // 5.0 改为 asyncClearConversationUnreadMessageCount
        String conversationId = params.getString("convId");
        asyncRunnable(() -> {
                EMClient.getInstance().chatManager().asyncClearConversationUnreadMessageCount(conversationId, new EMWrapperCallBack(result, channelName, null));

        });
    }

    private void recallMessage(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msgId");
        String ext;
        if (params.has("ext")) {
            ext = params.getString("ext");
        } else {
            ext = null;
        }
        asyncRunnable(() -> {
            try {
                // 【透传原生】不本地拦截：原生对无效消息的真实返回
                EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
                EMClient.getInstance().chatManager().recallMessage(msg, ext);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getMessage(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msgId");

        asyncRunnable(() -> {
            EMMessage msg = EMClient.getInstance().chatManager().getMessage(msgId);
            if(msg == null) {
                onSuccess(result, channelName, null);
            }else {
                onSuccess(result, channelName, MessageHelper.toJson(msg));
            }
        });
    }

    private void getConversation(JSONObject params, String channelName, Result result) throws JSONException {
        String conId = params.getString("convId");
        boolean createIfNeed = true;
        if (params.has("createIfNeed")) {
            createIfNeed = params.getBoolean("createIfNeed");
        }

        EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("type"));

        boolean finalCreateIfNeed = createIfNeed;
        asyncRunnable(() -> {
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conId, type, finalCreateIfNeed, false);
            onSuccess(result, channelName, conversation != null ? ConversationHelper.toJson(conversation) : null);
        });
    }

    private void getThreadConversation(JSONObject params, String channelName, Result result) throws JSONException {
        String conId = params.getString("convId");
        asyncRunnable(() -> {
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conId, EMConversationType.GroupChat, true, true);
            onSuccess(result, channelName, conversation != null ? ConversationHelper.toJson(conversation) : null);
        });
    }

    private void markAllChatMsgAsRead(JSONObject params, String channelName, Result result) throws JSONException {
        // 5.0 改为 asyncClearAllConversationUnreadMessageCount
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().asyncClearAllConversationUnreadMessageCount(new EMWrapperCallBack(result, channelName, null));
        });
    }

    private void getUnreadMessageCount(JSONObject params, String channelName, Result result) throws JSONException {
        asyncRunnable(() -> {
            int count = EMClient.getInstance().chatManager().getUnreadMessageCount();
            onSuccess(result, channelName, count);
        });
    }

    private void getConversationsFromServerWithPage(JSONObject params, String channelName, Result result) throws JSONException {
        // 5.0 移除拉取接口，改用本地会话列表
        asyncRunnable(() -> {
            List<EMConversation> list = EMClient.getInstance().chatManager().getAllConversationsBySort();
            List<Map> conversations = new ArrayList<>();
            for (EMConversation conversation : list) {
                conversations.add(ConversationHelper.toJson(conversation));
            }
            onSuccess(result, channelName, conversations);
        });
    }


    private void removeMessagesFromServerWithMsgIds(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("convId");
        EMConversation.EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("type"));
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
        EMConversation.EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("type"));
        EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conversationId, type, true);
        long timestamp = 0;
        if(params.has("timestamp")) {
            timestamp = params.getLong("timestamp");
        }
        conversation.removeMessagesFromServer(timestamp, new EMWrapperCallBack(result, channelName, null));
    }

    private void updateChatMessage(JSONObject params, String channelName, Result result) throws JSONException {
        // 【透传原生】不本地拦截（dbMsg 为 null 也继续，原生处理）
        EMMessage msg = MessageHelper.fromJson(params.getJSONObject("message"));
        EMMessage dbMsg = EMClient.getInstance().chatManager().getMessage(msg.getMsgId());
        HelpTool.mergeMessage(msg, dbMsg);
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().updateMessage(dbMsg);
            onSuccess(result, channelName, MessageHelper.toJson(dbMsg));
        });
    }
    
    private void importMessages(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray ary = params.getJSONArray("messages");
        List<EMMessage> messages = new ArrayList<>();
        for (int i = 0; i < ary.length(); i++) {
            JSONObject obj = ary.getJSONObject(i);
            messages.add(MessageHelper.fromJson(obj));
        }

        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().importMessages(messages);
            onSuccess(result, channelName, true);
        });
    }


    private void downloadMessageAttachmentInCombine(JSONObject params, String channelName, Result result) throws JSONException {
        final EMMessage msg = MessageHelper.fromJson(params.getJSONObject("message"));
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.SUCCESSED, msg, false));
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(MethodKey.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, map);
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
                    messageChannel.invokeMethod(MethodKey.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().downloadAttachment(msg);
            onSuccess(result, channelName, updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.DOWNLOADING, msg, false));
        });
    }

    private void downloadMessageThumbnailInCombine(JSONObject params, String channelName, Result result) throws JSONException {
        final EMMessage msg = MessageHelper.fromJson(params.getJSONObject("message"));
        msg.setMessageStatusCallback(new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.SUCCESSED, msg, true));
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(MethodKey.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, map);
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
                    messageChannel.invokeMethod(MethodKey.onMessageError, map);
                });
            }
        });
        asyncRunnable(() -> {
            EMClient.getInstance().chatManager().downloadThumbnail(msg);
            onSuccess(result, channelName, updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.DOWNLOADING, msg, true));
        });
    }
    private void downloadAttachment(JSONObject params, String channelName, Result result) throws JSONException {
        downloadMessage(params, channelName, result, false, "downloadAttachment");
    }

    private void downloadBigImage(JSONObject params, String channelName, Result result) throws JSONException {
        downloadMessage(params, channelName, result, false, "downloadBigImage");
    }

    private void downloadThumbnail(JSONObject params, String channelName, Result result) throws JSONException {
        downloadMessage(params, channelName, result, true, "downloadThumbnail");
    }

    private void downloadMessage(JSONObject params, String channelName, Result result, boolean isThumbnail, String nativeMethodName) throws JSONException {
        // 【透传原生】不本地拦截（msg null 也继续，原生处理）
        EMMessage tempMsg = MessageHelper.fromJson(params.getJSONObject("message"));
        final EMMessage msg = EMClient.getInstance().chatManager().getMessage(tempMsg.getMsgId());
        EMCallBack downloadCallback = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.SUCCESSED, msg, isThumbnail));
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(MethodKey.onMessageSuccess, map);
                });
            }

            @Override
            public void onProgress(int progress, String status) {
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("progress", progress);
                    map.put("localId", msg.getMsgId());
                    messageChannel.invokeMethod(MethodKey.onMessageProgressUpdate, map);
                });
            }

            @Override
            public void onError(int code, String desc) {
                Map<String, Object> data = new HashMap<>();
                data.put("code", code);
                data.put("description", desc);
                post(() -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("message", updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.FAILED, msg, isThumbnail));
                    map.put("localId", msg.getMsgId());
                    map.put("error", data);
                    messageChannel.invokeMethod(MethodKey.onMessageError, map);
                });
            }
        };
        msg.setMessageStatusCallback(downloadCallback);
        asyncRunnable(() -> {
            try {
                invokeDownloadMethod(nativeMethodName, msg, downloadCallback);
                onSuccess(result, channelName, updateDownloadStatus(EMFileMessageBody.EMDownloadStatus.DOWNLOADING, msg, isThumbnail));
            } catch (NoSuchMethodException e) {
                onError(result, new HyphenateException(1, nativeMethodName + " is not supported by current native SDK"));
            } catch (Exception e) {
                onError(result, new HyphenateException(1, e.getMessage()));
            }
        });
    }

    private void invokeDownloadMethod(String nativeMethodName, EMMessage msg, EMCallBack callback) throws Exception {
        try {
            Method callbackMethod = EMClient.getInstance().chatManager().getClass()
                    .getMethod(nativeMethodName, EMMessage.class, EMCallBack.class);
            callbackMethod.invoke(EMClient.getInstance().chatManager(), msg, callback);
        } catch (NoSuchMethodException e) {
            Method legacyMethod = EMClient.getInstance().chatManager().getClass()
                    .getMethod(nativeMethodName, EMMessage.class);
            legacyMethod.invoke(EMClient.getInstance().chatManager(), msg);
        }
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
                     tmpBody.setThumbnailDownloadStatus(downloadStatus);
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
        return MessageHelper.toJson(msg);
    }

    private void loadAllConversations(JSONObject params, String channelName, Result result) throws JSONException {
        asyncHeavyWorkRunnable(()->{
            if (EMClient.getInstance().getCurrentUser() == null || EMClient.getInstance().getCurrentUser().isEmpty()) {
                onSuccess(result, channelName, new ArrayList<>());
                return;
            }
            List<EMConversation> list = EMClient.getInstance().chatManager().getAllConversationsBySort();
            List<Map> conversations = new ArrayList<>();
            for (EMConversation conversation : list) {
                conversations.add(ConversationHelper.toJson(conversation));
            }
            onSuccess(result, channelName, conversations);
        });
    }

    private void getConversationsFromServer(JSONObject params, String channelName, Result result) throws JSONException {
        // 5.0 移除了 fetchConversationsFromServer，改用本地会话列表
        asyncRunnable(() -> {
            List<EMConversation> list = EMClient.getInstance().chatManager().getAllConversationsBySort();
            List<Map> conversations = new ArrayList<>();
            for (EMConversation conversation : list) {
                conversations.add(ConversationHelper.toJson(conversation));
            }
            onSuccess(result, channelName, conversations);
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
        EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("type"));
        int pageSize = params.getInt("pageSize");
        String startMsgId = params.getString("startMsgId");
        // 5.0 改为 asyncFetchHistoryMessages + EMFetchMessageOption
        EMConversation.EMSearchDirection direction = EnumTools.searchDirectionFromInt(params.optInt("direction"));
        EMFetchMessageOption option = new EMFetchMessageOption();
        option.setDirection(direction);
        EMClient.getInstance().chatManager().asyncFetchHistoryMessages(conId, type, pageSize, startMsgId, option,
                new EMValueWrapperCallBack<EMCursorResult<EMMessage>>(result, channelName) {
                    @Override
                    public void onSuccess(EMCursorResult<EMMessage> cursorResult) {
                        updateObject(CursorResultHelper.toJson(cursorResult));
                    }
                });
    }

    private void fetchHistoryMessagesByOptions(JSONObject params, String channelName, Result result) throws JSONException {
        String conId = params.getString("convId");
        EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("type"));
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
                updateObject(CursorResultHelper.toJson(result));
            }
        };

        EMClient.getInstance().chatManager().asyncFetchHistoryMessages(conId, type, pageSize, cursor, option, callBack);
    }


    private void searchChatMsgFromDB(JSONObject params, String channelName, Result result) throws JSONException {
        String keywords = params.getString("keywords");
        long timestamp = params.getLong("timestamp");
        int count = params.getInt("count");
        String from;
        if(params.has("from")) {
            from = params.getString("from");
        }else {
            from = null;
        }
        EMSearchDirection direction = EnumTools.searchDirectionFromInt(params.getInt("direction"));
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
                messages.add(MessageHelper.toJson(msg));
            }
            onSuccess(result, channelName, messages);
        });
    }


    private void asyncFetchGroupMessageAckFromServer(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.getString("msgId");
        String ackId = null;
        if (params.has("ack_id")){
            ackId = params.getString("ack_id");
        }
        int pageSize = params.getInt("pageSize");

        // 5.0: asyncFetchGroupReadAcks → asyncFetchGroupMessageReadReceipts，EMGroupReadAck → EMGroupReadReceipt
        EMValueWrapperCallBack<EMCursorResult<EMGroupReadReceipt>> callBack = new EMValueWrapperCallBack<EMCursorResult<EMGroupReadReceipt>>(result,
                channelName) {
            @Override
            public void onSuccess(EMCursorResult<EMGroupReadReceipt> result) {
                updateObject(CursorResultHelper.toJson(result));
            }
        };

        EMClient.getInstance().chatManager().asyncFetchGroupMessageReadReceipts(msgId, pageSize, ackId, callBack);
    }


    private void deleteRemoteConversation(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("convId");
        EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("conversationType"));
        boolean isDeleteRemoteMessage = params.getBoolean("isDeleteRemoteMessage");
        EMClient.getInstance().chatManager().deleteConversationFromServer(conversationId, type, isDeleteRemoteMessage, new EMWrapperCallBack(result, channelName, null));
    }

    private void deleteMessagesBefore(JSONObject params, String channelName, Result result) throws JSONException {
        long timestamp = params.getLong("timestamp");
        EMClient.getInstance().chatManager().deleteMessagesBeforeTimestamp(timestamp, new EMWrapperCallBack(result, channelName, null));
    }

    private void translateMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage msg = MessageHelper.fromJson(params.getJSONObject("message"));
        List<String> list = new ArrayList<>();
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
                updateObject(MessageHelper.toJson(object));
            }
        });
    }

    private void fetchSupportedLanguages(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().chatManager().fetchSupportLanguages(new EMValueWrapperCallBack<List<EMLanguage>>(result, channelName){
            @Override
            public void onSuccess(List<EMLanguage> object) {
                List<Map> list = new ArrayList<>();
                for (EMLanguage language : object) {
                    list.add(LanguageHelper.toJson(language));
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
        EMMessage.ChatType type;
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
                            ary.add(MessageReactionHelper.toJson(list.get(i)));
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
                updateObject(CursorResultHelper.toJson(object));
            }
        });
    }


    private void getConversationsFromServerWithCursor(JSONObject params, String channelName, Result result) throws JSONException {
        // 5.0 移除拉取接口，改用本地会话列表
        asyncRunnable(() -> {
            List<EMConversation> list = EMClient.getInstance().chatManager().getAllConversationsBySort();
            List<Map> conversations = new ArrayList<>();
            for (EMConversation conversation : list) {
                conversations.add(ConversationHelper.toJson(conversation));
            }
            onSuccess(result, channelName, conversations);
        });
    }

    private void getPinnedConversationsFromServerWithCursor(JSONObject params, String channelName, Result result) throws JSONException {
        // 5.0 移除拉取接口，改用本地会话列表
        asyncRunnable(() -> {
            List<EMConversation> list = EMClient.getInstance().chatManager().getAllConversationsBySort();
            List<Map> conversations = new ArrayList<>();
            for (EMConversation conversation : list) {
                conversations.add(ConversationHelper.toJson(conversation));
            }
            onSuccess(result, channelName, conversations);
        });
    }

    private void pinConversation(JSONObject params, String channelName, Result result) throws JSONException {
        String convId = params.optString("convId");
        boolean isPinned = params.optBoolean("isPinned", false);
        EMClient.getInstance().chatManager().asyncPinConversation(convId, isPinned, new EMWrapperCallBack(result, channelName, null));
    }

    private void modifyMessage(JSONObject params, String channelName, Result result) throws JSONException {
        String msgId = params.optString("msgId");
        EMMessageBody body = (params.has("msgBody") && !params.isNull("msgBody"))
                ? MessageBodyHelper.fromJson(params.optJSONObject("msgBody"))
                : null;
        Map<String, Object> ext = new HashMap<>();
        if(params.has("attributes")) {
            JSONObject data = params.getJSONObject("attributes");
            Iterator iterator = data.keys();
            while (iterator.hasNext()) {
                String key = iterator.next().toString();
                ext.put(key, data.get(key));
            }
        }

        EMClient.getInstance().chatManager().asyncModifyMessage(msgId, body, ext, new EMValueWrapperCallBack<EMMessage>(result, channelName) {
            @Override
            public void onSuccess(EMMessage object) {
                updateObject(MessageHelper.toJson(object));
            }
        });
    }
    private void downloadAndParseCombineMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage msg =  MessageHelper.fromJson(params.optJSONObject("message"));
        EMClient.getInstance().chatManager().downloadAndParseCombineMessage(msg, new EMValueWrapperCallBack<List<EMMessage>>(result, channelName){
            @Override
            public void onSuccess(List<EMMessage> msgList) {
                List<Map> messages = new ArrayList<>();
                for(EMMessage innerMsg: msgList) {
                    if (innerMsg.getType() == EMMessage.Type.IMAGE) {
                        EMImageMessageBody b = (EMImageMessageBody) innerMsg.getBody();
                        EMLog.d("CombineParse", "image msgId=" + innerMsg.getMsgId()
                            + ", thumbnailUrl=" + b.getThumbnailUrl()
                            + ", thumbnailLocalPath=" + b.thumbnailLocalPath()
                            + ", thumbnailSecret=" + b.getThumbnailSecret()
                            + ", remotePath=" + b.getRemoteUrl()
                            + ", localPath=" + b.getLocalUrl());
                    } else if (innerMsg.getType() == EMMessage.Type.VIDEO) {
                        EMVideoMessageBody b = (EMVideoMessageBody) innerMsg.getBody();
                        EMLog.d("CombineParse", "video msgId=" + innerMsg.getMsgId()
                            + ", thumbnailUrl=" + b.getThumbnailUrl()
                            + ", thumbnailLocalPath=" + b.getLocalThumb()
                            + ", thumbnailSecret=" + b.getThumbnailSecret()
                            + ", remotePath=" + b.getRemoteUrl()
                            + ", localPath=" + b.getLocalUrl());
                    }
                    messages.add(MessageHelper.toJson(innerMsg));
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
        // 5.0 移除按选项拉取，改用本地会话列表
        asyncRunnable(() -> {
            List<EMConversation> list = EMClient.getInstance().chatManager().getAllConversationsBySort();
            List<Map> conversations = new ArrayList<>();
            for (EMConversation conversation : list) {
                conversations.add(ConversationHelper.toJson(conversation));
            }
            onSuccess(result, channelName, conversations);
        });
    }


    private void deleteAllMessageAndConversation(JSONObject params, String channelName, Result result) throws JSONException {
        boolean clearServerData = params.getBoolean("clearServerData");
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
                    messages.add(MessageHelper.toJson(msg));
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
                    msgList.add(MessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(MethodKey.onMessagesReceived, msgList));
            }

            @Override
            public void onStreamMessageReceived(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(MessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(MethodKey.onStreamMessagesReceived, msgList));
            }

            @Override
            public void onCmdMessageReceived(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(MessageHelper.toJson(message));
                }
                post(() -> channel.invokeMethod(MethodKey.onCmdMessagesReceived, msgList));
            }

            @Override
            public void onMessageRecalledWithExt(List<EMRecallMessageInfo> recallMessageInfo) {
                ArrayList<Map<String, Object>> infoList = new ArrayList<>();
                for (EMRecallMessageInfo info : recallMessageInfo) {
                    infoList.add(RecallMessageInfoHelper.toJson(info));
                }
                post(() -> channel.invokeMethod(MethodKey.onMessagesRecalledInfo, infoList));
            }

            @Override
            public void onMessageReadReceipts(List<EMMessageReadReceipt> receipts) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessageReadReceipt receipt : receipts) {
                    EMMessage message = EMClient.getInstance().chatManager().getMessage(receipt.getMessageId());
                    if (message != null) {
                        msgList.add(MessageHelper.toJson(message));
                        post(() -> messageChannel.invokeMethod(MethodKey.onMessageReadAck, MessageHelper.toJson(message)));
                    }
                }
                post(() -> channel.invokeMethod(MethodKey.onMessagesRead, msgList));
            }

            public void onMessageDelivered(List<EMMessage> messages) {
                ArrayList<Map<String, Object>> msgList = new ArrayList<>();
                for (EMMessage message : messages) {
                    msgList.add(MessageHelper.toJson(message));
                    post(() -> messageChannel.invokeMethod(MethodKey.onMessageDeliveryAck,
                            MessageHelper.toJson(message)));
                }
                post(() -> channel.invokeMethod(MethodKey.onMessagesDelivered, msgList));
            }

            @Override
            public void onReactionChanged(List<EMMessageReactionChange> messageReactionChangeList) {
                ArrayList<Map<String, Object>> list = new ArrayList<>();
                for (EMMessageReactionChange change : messageReactionChangeList) {
                    list.add(MessageReactionChangeHelper.toJson(change));
                }
                post(() -> channel.invokeMethod(MethodKey.onMessageReactionDidChange, list));
            }

            @Override
            public void onMessageContentChanged(EMMessage messageModified, String operatorId, long operationTime) {
                 Map msgMap = MessageHelper.toJson(messageModified);
                Map<String, Object> map = new HashMap<>();
                 map.put("message", msgMap);
                 map.put("operator", operatorId);
                 map.put("operationTime", operationTime);
                post(() -> channel.invokeMethod(MethodKey.onMessageContentChanged, map));
            }

            @Override
            public void onMessagePinChanged(String messageId, String conversationId, EMMessagePinInfo.PinOperation pinOperation, EMMessagePinInfo pinInfo) {
                Map<String, Object> map = new HashMap<>();
                map.put("msgId", messageId);
                map.put("convId", conversationId);
                map.put("pinOperation", pinOperation.ordinal());
                map.put("pinInfo", MessagePinInfoHelper.toJson(pinInfo));
                post(() -> channel.invokeMethod(MethodKey.onMessagePinChanged, map));
            }
        };

        if (conversationListener != null) {
            EMClient.getInstance().chatManager().removeConversationListener(conversationListener);
        }
        conversationListener = new EMConversationListener() {

            @Override
            public void onConversationUpdate() {
                Map<String, Object> data = new HashMap<>();
                post(() -> channel.invokeMethod(MethodKey.onConversationUpdate, data));
            }

                };

        EMClient.getInstance().chatManager().addMessageListener(messageListener);
        EMClient.getInstance().chatManager().addConversationListener(conversationListener);
    }

    // 481
    private void searchMsgByOptions(JSONObject params, String channelName, Result result) throws JSONException {

        JSONArray ja = params.getJSONArray("types");
        Set<EMMessage.Type> types = new HashSet<>();
        for (int i = 0; i < ja.length(); i++) {
            int iType = ja.getInt(i);
            types.add(EnumTools.messageBodyTypeFromInt(iType));
        }
        long ts = params.getLong("ts");
        int count = params.getInt("count");
        String from = params.optString("from");
        EMConversation.EMSearchDirection direction = null;
        if(params.has("direction")) {
            direction = EnumTools.searchDirectionFromInt(params.getInt("direction"));
        }
        List<EMMessage> msgList = EMClient.getInstance().chatManager().searchMsgFromDB(types, ts, count, from, direction);
        List<Map> messages = new ArrayList<>();
        for(EMMessage msg: msgList) {
            messages.add(MessageHelper.toJson(msg));
        }
        onSuccess(result, channelName, messages);
    }

    // 4.10
    private void getMessageCount(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().chatManager().asyncGetMessageCount(new EMValueWrapperCallBack<Integer>(result, channelName){
            @Override
            public void onSuccess(Integer object) {
                updateObject(object);
            }
        } );
    }

    // 4.15.2
    private void loadConversationMessagesWithKeyword(JSONObject params, String channelName, Result result) throws JSONException {
        String keyword = null;
        if (params.has("keyword") && !params.isNull("keyword")) {
            keyword = params.getString("keyword");
        }
        long timestamp = params.getLong("timestamp");
        String sender = null;
        if (params.has("sender") && !params.isNull("sender")) {
            sender = params.getString("sender");
        }
        EMConversation.EMSearchDirection direction = EnumTools.searchDirectionFromInt(params.getInt("direction"));
        EMConversation.EMMessageSearchScope scope = EMConversation.EMMessageSearchScope.values()[params.getInt("scope")];

        EMClient.getInstance().chatManager().asyncLoadConversationMessagesWithKeyword(
            keyword, 
            timestamp, 
            sender, 
            direction, 
            scope,
            new EMValueWrapperCallBack<Map<String, List<String>>>(result, channelName) {
                @Override
                public void onSuccess(Map<String, List<String>> object) {
                    Map<String, Object> resultMap = new HashMap<>();
                    for (Map.Entry<String, List<String>> entry : object.entrySet()) {
                        resultMap.put(entry.getKey(), entry.getValue());
                    }
                    updateObject(resultMap);
                }
            }
        );
    }

    private void loadMessagesWithIds(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray jsonArray = params.getJSONArray("messageIds");
        ArrayList<String> messageIds = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            messageIds.add(jsonArray.getString(i));
        }
        String conversationId = params.getString("conversationId");

        EMClient.getInstance().chatManager().asyncLoadMessages(messageIds, conversationId, new EMValueWrapperCallBack<List<EMMessage>>(result, channelName) {
            @Override
            public void onSuccess(List<EMMessage> object) {
                List<Map> messages = new ArrayList<>();
                for (EMMessage msg : object) {
                    messages.add(MessageHelper.toJson(msg));
                }
                updateObject(messages);
            }
        });
    }

    private void getGroupMessageReadReceipts(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray ja = params.getJSONArray("messages");
        List<EMMessage> msgs = new ArrayList<>();
        for (int i = 0; i < ja.length(); i++) {
            msgs.add(MessageHelper.fromJson(ja.getJSONObject(i)));
        }
        EMClient.getInstance().chatManager().asyncGetGroupMessageReadReceipts(msgs,
                new EMValueWrapperCallBack<List<EMMessageReadReceipt>>(result, channelName) {
                    @Override
                    public void onSuccess(List<EMMessageReadReceipt> receipts) {
                        List<Map> list = new ArrayList<>();
                        for (EMMessageReadReceipt r : receipts) {
                            Map<String, Object> m = new HashMap<>();
                            m.put("msgId", r.getMessageId());
                            m.put("convId", r.getConversationId());
                            m.put("readCount", r.getReadCount());
                            list.add(m);
                        }
                        updateObject(list);
                    }
                });
    }

    private void searchMessagesFromServer(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessageSearchOption option = new EMMessageSearchOption();
        if (params.has("keyword")) {
            List<String> keywords = new ArrayList<>();
            keywords.add(params.getString("keyword"));
            option.setKeywordList(keywords);
        }
        if (params.has("conversationId")) {
            option.setConversationId(params.getString("conversationId"));
        }
        int pageSize = params.optInt("pageSize", 20);
        int pageNum = params.optInt("pageNum", 0);
        EMClient.getInstance().chatManager().asyncSearchMessagesFromServer(option, pageSize, pageNum,
                new EMValueWrapperCallBack<EMPageResult<EMSearchServerMessageResult>>(result, channelName) {
                    @Override
                    public void onSuccess(EMPageResult<EMSearchServerMessageResult> object) {
                        updateObject(PageResultHelper.toJson(object));
                    }
                });
    }

    private void deleteConversations(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray ja = params.getJSONArray("convIds");
        List<String> ids = new ArrayList<>();
        for (int i = 0; i < ja.length(); i++) {
            ids.add(ja.getString(i));
        }
        boolean deleteMessages = params.optBoolean("deleteMessages", true);
        EMClient.getInstance().chatManager().asyncDeleteConversations(ids, deleteMessages, new EMWrapperCallBack(result, channelName, null));
    }

    private void saveMessage(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage msg = MessageHelper.fromJson(params.getJSONObject("message"));
        EMClient.getInstance().chatManager().saveMessage(msg);
        onSuccess(result, channelName, true);
    }

    private void cleanConversationsMemoryCache(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().chatManager().cleanConversationsMemoryCache();
        onSuccess(result, channelName, true);
    }

    private void getConversationsByType(JSONObject params, String channelName, Result result) throws JSONException {
        EMConversation.EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("type"));
        List<EMConversation> list = EMClient.getInstance().chatManager().getConversationsByType(type);
        List<Map<String, Object>> convList = new ArrayList<>();
        for (EMConversation conv : list) {
            convList.add(ConversationHelper.toJson(conv));
        }
        onSuccess(result, channelName, convList);
    }

    private void filterConversationsFromDB(JSONObject params, String channelName, Result result) throws JSONException {
        // 5.0 自定义过滤器：默认不过滤（返回全部），后续可扩展
        EMCustomConversationFilter filter = conversation -> true;
        boolean isOnlyUnread = params.optBoolean("onlyUnread", false);
        EMClient.getInstance().chatManager().asyncFilterConversationsFromDB(filter, isOnlyUnread,
                new EMValueWrapperCallBack<List<EMConversation>>(result, channelName) {
                    @Override
                    public void onSuccess(List<EMConversation> list) {
                        List<Map<String, Object>> convList = new ArrayList<>();
                        for (EMConversation conv : list) {
                            convList.add(ConversationHelper.toJson(conv));
                        }
                        updateObject(convList);
                    }
                });
    }

    private void setVoiceMessageListened(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage msg = MessageHelper.fromJson(params.getJSONObject("message"));
        EMClient.getInstance().chatManager().setVoiceMessageListened(msg);
        onSuccess(result, channelName, true);
    }

    private void voiceMessageToText(JSONObject params, String channelName, Result result) throws JSONException {
        EMMessage msg = MessageHelper.fromJson(params.getJSONObject("message"));
        EMClient.getInstance().chatManager().voiceMessageToText(msg,
                new EMValueWrapperCallBack<String>(result, channelName) {
                    @Override
                    public void onSuccess(String text) {
                        updateObject(text);
                    }
                });
    }

    private void voiceFileToText(JSONObject params, String channelName, Result result) throws JSONException {
        String filePath = params.getString("filePath");
        EMAudioParams audioParams = new EMAudioParams();
        audioParams.setSampleRate(params.optInt("sampleRate", 16000));
        audioParams.setBitsPerSample(params.optInt("bitsPerSample", 16));
        audioParams.setChannels(params.optInt("channels", 1));
        EMClient.getInstance().chatManager().voiceFileToText(filePath, audioParams,
                new EMValueWrapperCallBack<String>(result, channelName) {
                    @Override
                    public void onSuccess(String text) {
                        updateObject(text);
                    }
                });
    }

}
