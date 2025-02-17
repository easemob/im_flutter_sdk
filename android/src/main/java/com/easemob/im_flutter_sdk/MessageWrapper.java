package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessageReaction;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MessageWrapper extends Wrapper implements MethodChannel.MethodCallHandler {
    public MessageWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
    }


    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {

        JSONObject param = (JSONObject)call.arguments;

        try {
            if (MethodKey.getReactionList.equals(call.method)) {
                reactionList(param, call.method, result);
            }else if (MethodKey.groupAckCount.equals(call.method)){
                getAckCount(param, call.method, result);
            }else if (MethodKey.getChatThread.equals(call.method)) {
                getChatThread(param, call.method, result);
            }
            // 450
            else if (MethodKey.getPinInfo.equals(call.method)) {
                getPinInfo(param, call.method, result);
            }
            else
            {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    private void reactionList(JSONObject params, String channelName, MethodChannel.Result result) throws JSONException {
        String msgId = params.getString("msgId");
        EMMessage msg = getMessageWithId(msgId);
        ArrayList<Map<String, Object>> list = new ArrayList<>();
        if (msg != null) {
            List<EMMessageReaction> reactions = msg.getMessageReaction();
            if (reactions != null) {
                for (int i = 0; i < reactions.size(); i++) {
                    list.add(MessageReactionHelper.toJson(reactions.get(i)));
                }
            }
        }
        onSuccess(result, channelName, list);
    }


    private void getAckCount(JSONObject params, String channelName, MethodChannel.Result result) throws JSONException {
        String msgId = params.getString("msgId");
        EMMessage msg = getMessageWithId(msgId);
        asyncRunnable(()->{
            onSuccess(result, channelName,  msg != null ? msg.groupAckCount() : 0);
        });
    }

    private void getChatThread(JSONObject params, String channelName, MethodChannel.Result result) throws JSONException {
        String msgId = params.getString("msgId");
        EMMessage msg = getMessageWithId(msgId);
        asyncRunnable(()->{
            if (msg != null) {
                onSuccess(result, channelName,  msg.getChatThread() != null ? ChatThreadHelper.toJson(msg.getChatThread()) : null);
            }else {
                onSuccess(result, channelName,  null);
            }
        });
    }
    private void getPinInfo(JSONObject params, String channelName, MethodChannel.Result result) throws JSONException {
        String msgId = params.getString("msgId");
        EMMessage msg = getMessageWithId(msgId);
        asyncRunnable(()->{
            if (msg != null) {
                onSuccess(result, channelName,  msg.pinnedInfo() != null ? MessagePinInfoHelper.toJson(msg.pinnedInfo()) : null);
            }else {
                onSuccess(result, channelName,  null);
            }
        });
    }

    private EMMessage getMessageWithId(String msgId) {
        return EMClient.getInstance().chatManager().getMessage(msgId);
    }

}
