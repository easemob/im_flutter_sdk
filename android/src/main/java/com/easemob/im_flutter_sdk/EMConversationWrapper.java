package com.easemob.im_flutter_sdk;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;

import org.json.JSONException;
import org.json.JSONObject;


public class EMConversationWrapper extends EMWrapper implements MethodCallHandler{

    EMConversationWrapper(PluginRegistry.Registrar registrar, String channelName) {
        super(registrar, channelName);
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



    private EMConversation conversationWithParam(JSONObject params ) throws JSONException {
        String con_id = params.getString("con_id");
        EMConversation.EMConversationType type = EMConversationHelper.typeFromInt(params.getInt("type"));
        EMConversation conv = EMClient.getInstance().chatManager().getConversation(con_id, type);
        return conv;
    }
}
