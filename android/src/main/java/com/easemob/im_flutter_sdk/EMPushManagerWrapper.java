package com.easemob.im_flutter_sdk;

import android.content.Context;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMPushConfigs;
import com.hyphenate.chat.EMPushManager.DisplayStyle;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONArray;
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
        JSONObject param = (JSONObject)call.arguments;
        try {
            if (EMSDKMethod.getImPushConfig.equals(call.method)) {
                getImPushConfig(param, call.method, result);
            }
            else if(EMSDKMethod.getImPushConfigFromServer.equals(call.method)){
                getImPushConfigFromServer(param, call.method, result);
            }
            else if(EMSDKMethod.updatePushNickname.equals(call.method)){
                updatePushNickname(param, call.method, result);
            }
            else if(EMSDKMethod.updateImPushStyle.equals(call.method)){
                updateImPushStyle(param, call.method, result);
            }
            else if(EMSDKMethod.updateGroupPushService.equals(call.method)){
                updateGroupPushService(param, call.method, result);
            }
            else if(EMSDKMethod.updateHMSPushToken.equals(call.method)){
                updateHMSPushToken(param, call.method, result);
            }
            else if(EMSDKMethod.updateFCMPushToken.equals(call.method)){
                updateFCMPushToken(param, call.method, result);
            }
            else if (EMSDKMethod.enableOfflinePush.equals(call.method)) {
                enableOfflinePush(param, call.method, result);
            }
            else if (EMSDKMethod.disableOfflinePush.equals(call.method)){
                disableOfflinePush(param, call.method, result);
            }
            else if (EMSDKMethod.getNoPushGroups.equals(call.method)) {
                getNoPushGroups(param, call.method, result);
            }
            else if (EMSDKMethod.updateUserPushService.equals(call.method)) {
                updateUserPushService(param, call.method, result);
            }
            else if (EMSDKMethod.getNoPushUsers.equals(call.method)) {
                getNoPushUsers(param, call.method, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        }catch (JSONException e) {

        }
    }

    private void getImPushConfig(JSONObject params, String channelName,  Result result) throws JSONException {
        EMPushConfigs configs = EMClient.getInstance().pushManager().getPushConfigs();
        onSuccess(result, channelName, EMPushConfigsHelper.toJson(configs));
    }

    private void getImPushConfigFromServer(JSONObject params, String channelName,  Result result) throws JSONException {
        asyncRunnable(()->{
            try {
                EMPushConfigs configs = EMClient.getInstance().pushManager().getPushConfigsFromServer();
                onSuccess(result, channelName, EMPushConfigsHelper.toJson(configs));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void updatePushNickname(JSONObject params, String channelName,  Result result) throws JSONException {
        String nickname = params.getString("nickname");

        asyncRunnable(()->{
            try {
                EMClient.getInstance().pushManager().updatePushNickname(nickname);
                onSuccess(result, channelName, nickname);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }


    private void enableOfflinePush(JSONObject params, String channelName, Result result) throws JSONException
    {
        asyncRunnable(()-> {
            try {
                EMClient.getInstance().pushManager().enableOfflinePush();
                onSuccess(result, channelName, null);
            } catch(HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void disableOfflinePush(JSONObject params, String channelName, Result result) throws JSONException
    {
        int startTime = params.getInt("start");
        int endTime = params.getInt("end");
        asyncRunnable(()-> {
            try {
                EMClient.getInstance().pushManager().disableOfflinePush(startTime, endTime);
                onSuccess(result, channelName, null);
            } catch(HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getNoPushGroups(JSONObject params, String channelName, Result result)  throws JSONException {
        asyncRunnable(()-> {
            List<String> groups = EMClient.getInstance().pushManager().getNoPushGroups();
            onSuccess(result, channelName, groups);
        });
    }

    private void getNoPushUsers(JSONObject params, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            List<String> list = EMClient.getInstance().pushManager().getNoPushUsers();
            onSuccess(result, channelName, list);
        });
    }

    private void updateImPushStyle(JSONObject params, String channelName,  Result result) throws JSONException {
        DisplayStyle style = params.getInt("pushStyle") == 0 ? DisplayStyle.SimpleBanner : DisplayStyle.MessageSummary;
        EMClient.getInstance().pushManager().asyncUpdatePushDisplayStyle(style, new EMWrapperCallBack(result, channelName, true));
    }

    private void updateGroupPushService(JSONObject params, String channelName,  Result result) throws JSONException {
        JSONArray groupIds = params.getJSONArray("group_ids");
        boolean noPush = params.getBoolean("noPush");

        List<String> groupList = new ArrayList<>();
        for (int i = 0; i < groupIds.length(); i++) {
            String groupId = groupIds.getString(i);
            groupList.add(groupId);
        }
        asyncRunnable(()-> {
            try {
                EMClient.getInstance().pushManager().updatePushServiceForGroup(groupList, noPush);
                onSuccess(result, channelName, null);
            } catch(HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void updateUserPushService(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray groupIds = params.getJSONArray("user_ids");
        boolean noPush = params.getBoolean("noPush");

        List<String> userList = new ArrayList<>();
        for (int i = 0; i < groupIds.length(); i++) {
            String userId = groupIds.getString(i);
            userList.add(userId);
        }
        asyncRunnable(()-> {
            try {
                EMClient.getInstance().pushManager().updatePushServiceForUsers(userList, noPush);
                onSuccess(result, channelName, null);
            } catch(HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void updateHMSPushToken(JSONObject params, String channelName,  Result result) throws JSONException {
        String token = params.getString("token");
        asyncRunnable(()->{
            EMClient.getInstance().sendHMSPushTokenToServer(token);
            onSuccess(result, channelName, token);
        });
    }

    private void updateFCMPushToken(JSONObject params, String channelName,  Result result) throws JSONException {
        String token = params.getString("token");
        asyncRunnable(()->{
            EMClient.getInstance().sendFCMTokenToServer(token);
            onSuccess(result, channelName, token);
        });
    }
}
