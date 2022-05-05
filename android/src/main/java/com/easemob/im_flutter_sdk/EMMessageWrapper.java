package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMMessage;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EMMessageWrapper extends EMWrapper implements MethodChannel.MethodCallHandler {
    public EMMessageWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
    }


    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {

        JSONObject param = (JSONObject)call.arguments;

        try {
            if (EMSDKMethod.getUnreadMsgCount.equals(call.method)) {
                getReaction(param, call.method, result);
            }
            else
            {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void getReaction(JSONObject params, String channelName, MethodChannel.Result result) throws JSONException {
        String msgId = params.getString("msgId");
        EMMessage msg = getMessageWithId(msgId);
        // TODO: getReaction
    }

    private EMMessage getMessageWithId(String msgId) {
        return EMClient.getInstance().chatManager().getMessage(msgId);
    }
}
