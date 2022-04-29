package com.easemob.im_flutter_sdk;

import android.content.Context;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMPushConfigs;
import com.hyphenate.chat.EMPushManager.DisplayStyle;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;


public class EMPushManagerWrapper extends EMWrapper implements MethodCallHandler {

    EMPushManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.getImPushConfig.equals(call.method)) {
                getImPushConfig(param, EMSDKMethod.getImPushConfig, result);
            } else if (EMSDKMethod.getImPushConfigFromServer.equals(call.method)) {
                getImPushConfigFromServer(param, EMSDKMethod.getImPushConfigFromServer, result);
            } else if (EMSDKMethod.updatePushNickname.equals(call.method)) {
                updatePushNickname(param, EMSDKMethod.updatePushNickname, result);
            } else if (EMSDKMethod.imPushNoDisturb.equals(call.method)) {
                imPushNoDisturb(param, EMSDKMethod.imPushNoDisturb, result);
            } else if (EMSDKMethod.updateImPushStyle.equals(call.method)) {
                updateImPushStyle(param, EMSDKMethod.updateImPushStyle, result);
            } else if (EMSDKMethod.updateGroupPushService.equals(call.method)) {
                updateGroupPushService(param, EMSDKMethod.updateGroupPushService, result);
            } else if (EMSDKMethod.getNoDisturbGroups.equals(call.method)) {
                getNoDisturbGroups(param, EMSDKMethod.getNoDisturbGroups, result);
            } else if (EMSDKMethod.updateHMSPushToken.equals(call.method)) {
                updateHMSPushToken(param, EMSDKMethod.updateHMSPushToken, result);
            } else if (EMSDKMethod.updateFCMPushToken.equals(call.method)) {
                updateFCMPushToken(param, EMSDKMethod.updateFCMPushToken, result);
            } else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {

        }
    }

    private void getImPushConfig(JSONObject params, String channelName, Result result) throws JSONException {
        EMPushConfigs configs = EMClient.getInstance().pushManager().getPushConfigs();
        onSuccess(result, channelName, EMPushConfigsHelper.toJson(configs ));
    }

    private void getImPushConfigFromServer(JSONObject params, String channelName, Result result) throws JSONException {
        asyncRunnable(() -> {
            try {
                EMPushConfigs configs = EMClient.getInstance().pushManager().getPushConfigsFromServer();
                onSuccess(result, channelName, EMPushConfigsHelper.toJson(configs));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void updatePushNickname(JSONObject params, String channelName, Result result) throws JSONException {
        String nickname = params.getString("nickname");

        asyncRunnable(() -> {
            try {
                EMClient.getInstance().pushManager().updatePushNickname(nickname);
                onSuccess(result, channelName, nickname);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void imPushNoDisturb(JSONObject params, String channelName, Result result) throws JSONException {
        boolean noDisturb = params.getBoolean("noDisturb");
        int startTime = params.getInt("startTime");
        int endTime = params.getInt("endTime");
        asyncRunnable(() -> {
            try {
                if (noDisturb) {
                    EMClient.getInstance().pushManager().disableOfflinePush(startTime, endTime);
                } else {
                    EMClient.getInstance().pushManager().enableOfflinePush();
                }
            } catch (HyphenateException e) {

            }
        });
    }

    private void updateImPushStyle(JSONObject params, String channelName, Result result) throws JSONException {
        DisplayStyle style = params.getInt("pushStyle") == 0 ? DisplayStyle.SimpleBanner : DisplayStyle.MessageSummary;
        EMClient.getInstance().pushManager().asyncUpdatePushDisplayStyle(style, new EMWrapperCallBack(result, channelName, true));
    }

    private void updateGroupPushService(JSONObject params, String channelName, Result result) throws JSONException {
        String groupId = params.getString("group_id");
        boolean enablePush = params.getBoolean("enablePush");
        List<String> groupList = new ArrayList<>();
        groupList.add(groupId);
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().pushManager().updatePushServiceForGroup(groupList, !enablePush);
                EMGroup group = EMClient.getInstance().groupManager().getGroup(groupId);
                onSuccess(result, channelName, EMGroupHelper.toJson(group));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getNoDisturbGroups(JSONObject params, String channelName, Result result) throws JSONException {
        List<String> groupIds = EMClient.getInstance().pushManager().getNoPushGroups();
        onSuccess(result, channelName, groupIds);
    }

    private void updateHMSPushToken(JSONObject params, String channelName, Result result) throws JSONException {
        String token = params.getString("token");
        asyncRunnable(() -> {
            EMClient.getInstance().sendHMSPushTokenToServer(token);
            onSuccess(result, channelName, token);
        });
    }

    private void updateFCMPushToken(JSONObject params, String channelName, Result result) throws JSONException {
        String token = params.getString("token");
        asyncRunnable(() -> {
            EMClient.getInstance().sendFCMTokenToServer(token);
            onSuccess(result, channelName, token);
        });
    }
}
