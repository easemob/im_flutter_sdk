package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMClient;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class EMChatThreadManagerWrapper extends EMWrapper implements MethodChannel.MethodCallHandler {
    public EMChatThreadManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {

        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.fetchChatThread.equals(call.method)) {
                fetchChatThread(param, call.method, result);
            } else if (EMSDKMethod.fetchChatThreadDetail.equals(call.method)) {
                fetchChatThreadDetail(param, call.method, result);
            } else if (EMSDKMethod.fetchJoinedChatThreads.equals(call.method)) {
                fetchJoinedChatThreads(param, call.method, result);
            } else if (EMSDKMethod.fetchChatThreadsWithParentId.equals(call.method)) {
                fetchChatThreadsWithParentId(param, call.method, result);
            } else if (EMSDKMethod.fetchChatThreadMember.equals(call.method)) {
                fetchChatThreadMember(param, call.method, result);
            } else if (EMSDKMethod.fetchLastMessageWithChatThreads.equals(call.method)) {
                fetchLastMessageWithChatThreads(param, call.method, result);
            } else if (EMSDKMethod.removeMemberFromChatThread.equals(call.method)) {
                removeMemberFromChatThread(param, call.method, result);
            } else if (EMSDKMethod.updateChatThreadSubject.equals(call.method)) {
                updateChatThreadSubject(param, call.method, result);
            } else if (EMSDKMethod.createChatThread.equals(call.method)) {
                createChatThread(param, call.method, result);
            } else if (EMSDKMethod.joinChatThread.equals(call.method)) {
                joinChatThread(param, call.method, result);
            } else if (EMSDKMethod.leaveChatThread.equals(call.method)) {
                leaveChatThread(param, call.method, result);
            } else if (EMSDKMethod.destroyChatThread.equals(call.method)) {
                destroyChatThread(param, call.method, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void fetchChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void fetchChatThreadDetail(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void fetchJoinedChatThreads(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void fetchChatThreadsWithParentId(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void fetchChatThreadMember(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void fetchLastMessageWithChatThreads(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void removeMemberFromChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void updateChatThreadSubject(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void createChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void joinChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void leaveChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void destroyChatThread(JSONObject param, String channelName, MethodChannel.Result result) throws JSONException {

    }

    private void registerEaseListener() {

    }
}
