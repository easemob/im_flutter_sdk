package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMPushConfigs;
import com.hyphenate.chat.EMPushManager.DisplayStyle;
import com.hyphenate.chat.EMSilentModeParam;
import com.hyphenate.chat.EMSilentModeResult;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


public class PushManagerWrapper extends Wrapper implements MethodCallHandler {

    PushManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        JSONObject param = (JSONObject)call.arguments;
        try {
            if (MethodKey.getImPushConfig.equals(call.method)) {
                getImPushConfig(param, call.method, result);
            }
            else if(MethodKey.getImPushConfigFromServer.equals(call.method)){
                getImPushConfigFromServer(param, call.method, result);
            }
            else if(MethodKey.updatePushNickname.equals(call.method)){
                updatePushNickname(param, call.method, result);
            }
            else if(MethodKey.updateImPushStyle.equals(call.method)){
                updateImPushStyle(param, call.method, result);
            }
            else if(MethodKey.updateHMSPushToken.equals(call.method)){
                updateHMSPushToken(param, call.method, result);
            }
            else if(MethodKey.updateFCMPushToken.equals(call.method)){
                updateFCMPushToken(param, call.method, result);
            }
            else if (MethodKey.reportPushAction.equals(call.method)) {
                reportPushAction(param, call.method, result);
            }
            else if (MethodKey.setConversationSilentMode.equals(call.method)) {
                setConversationSilentMode(param, call.method, result);
            }
            else if (MethodKey.removeConversationSilentMode.equals(call.method)) {
                removeConversationSilentMode(param, call.method, result);
            }
            else if (MethodKey.fetchConversationSilentMode.equals(call.method)) {
                fetchConversationSilentMode(param, call.method, result);
            }
            else if (MethodKey.setSilentModeForAll.equals(call.method)) {
                setSilentModeForAll(param, call.method, result);
            }
            else if (MethodKey.fetchSilentModeForAll.equals(call.method)) {
                fetchSilentModeForAll(param, call.method, result);
            }
            else if (MethodKey.fetchSilentModeForConversations.equals(call.method)) {
                fetchSilentModeForConversations(param, call.method, result);
            }
            else if (MethodKey.setPreferredNotificationLanguage.equals(call.method)) {
                setPreferredNotificationLanguage(param, call.method, result);
            }
            else if (MethodKey.fetchPreferredNotificationLanguage.equals(call.method)) {
                fetchPreferredNotificationLanguage(param, call.method, result);
            }
            else if (MethodKey.getPushTemplate.equals(call.method)) {
                getPushTemplate(param, call.method, result);
            }
            else if (MethodKey.setPushTemplate.equals(call.method)) {
                setPushTemplate(param, call.method, result);
            }
            // 481
            else if (MethodKey.syncSilentModels.equals(call.method)) {
                syncSilentModels(param, call.method, result);
            }
            else if (MethodKey.bindDeviceToken.equals(call.method)) {
                bindDeviceToken(param, call.method, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        }catch (JSONException e) {

        }
    }

    private void getImPushConfig(JSONObject params, String channelName,  Result result) throws JSONException {
        asyncRunnable(()->{
            EMPushConfigs configs = EMClient.getInstance().pushManager().getPushConfigs();
            onSuccess(result, channelName, PushConfigsHelper.toJson(configs));
        });

    }

    private void getImPushConfigFromServer(JSONObject params, String channelName,  Result result) throws JSONException {
        asyncRunnable(()->{
            try {
                EMPushConfigs configs = EMClient.getInstance().pushManager().getPushConfigsFromServer();
                onSuccess(result, channelName, PushConfigsHelper.toJson(configs));
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


    private void updateImPushStyle(JSONObject params, String channelName,  Result result) throws JSONException {
        DisplayStyle style = params.getInt("pushStyle") == 0 ? DisplayStyle.SimpleBanner : DisplayStyle.MessageSummary;
        EMClient.getInstance().pushManager().asyncUpdatePushDisplayStyle(style, new EMWrapperCallBack(result, channelName, true));
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
        String fcmKey = EMClient.getInstance().getOptions().getPushConfig().getFcmSenderId();
        EMClient.getInstance().pushManager().bindDeviceToken(fcmKey, token, new EMWrapperCallBack(result, channelName, null));
    }

    private void reportPushAction(JSONObject params, String channelName, Result result) throws JSONException {

    }

    private void setConversationSilentMode(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("conversationId");
        EMConversation.EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("conversationType"));
        EMSilentModeParam param = SilentModeParamHelper.fromJson(params.getJSONObject("param"));
        EMClient.getInstance().pushManager().setSilentModeForConversation(conversationId, type, param, new EMValueWrapperCallBack<EMSilentModeResult>(result, channelName){
            @Override
            public void onSuccess(EMSilentModeResult object) {
                super.updateObject(null);
            }
        });
    }
    private void removeConversationSilentMode(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("conversationId");
        EMConversation.EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("conversationType"));
        EMClient.getInstance().pushManager().clearRemindTypeForConversation(conversationId, type, new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchConversationSilentMode(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("conversationId");
        EMConversation.EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("conversationType"));
        EMClient.getInstance().pushManager().getSilentModeForConversation(conversationId, type, new EMValueWrapperCallBack<EMSilentModeResult>(result, channelName){
            @Override
            public void onSuccess(EMSilentModeResult object) {
                super.updateObject(SilentModeResultHelper.toJson(object));
            }
        });
    }

    private void setSilentModeForAll(JSONObject params, String channelName, Result result) throws JSONException {
        EMSilentModeParam param =  SilentModeParamHelper.fromJson(params.getJSONObject("param"));
        EMClient.getInstance().pushManager().setSilentModeForAll(param ,new EMValueWrapperCallBack<EMSilentModeResult>(result, channelName){
            @Override
            public void onSuccess(EMSilentModeResult object) {
                super.updateObject(null);
            }
        });
    }

    private void fetchSilentModeForAll(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().pushManager().getSilentModeForAll(new EMValueWrapperCallBack<EMSilentModeResult>(result, channelName){
            @Override
            public void onSuccess(EMSilentModeResult object) {
                super.updateObject(SilentModeResultHelper.toJson(object));
            }
        });
    }
    private void fetchSilentModeForConversations(JSONObject params, String channelName, Result result) throws JSONException {
        Iterator iterator = params.keys();
        ArrayList<EMConversation> list = new ArrayList<>();
        while (iterator.hasNext()) {
            String conversationId = (String)iterator.next();
            EMConversation.EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt(conversationId));
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(conversationId, type, true);
            list.add(conversation);
        }

        EMClient.getInstance().pushManager().getSilentModeForConversations(list, new EMValueWrapperCallBack<Map<String, EMSilentModeResult>>(result, channelName) {
            @Override
            public void onSuccess(Map<String, EMSilentModeResult> object) {
                Map<String ,Map> result = new HashMap<>();
                for (Map.Entry<String, EMSilentModeResult>entry: object.entrySet()) {
                    result.put(entry.getKey(), SilentModeResultHelper.toJson(entry.getValue()));
                }
                super.updateObject(result);
            }
        });

    }

    private void setPreferredNotificationLanguage(JSONObject params, String channelName, Result result) throws JSONException {
        String code = params.getString("code");
        EMClient.getInstance().pushManager().setPreferredNotificationLanguage(code, new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchPreferredNotificationLanguage(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().pushManager().getPreferredNotificationLanguage(new EMValueWrapperCallBack<String>(result, channelName){
            @Override
            public void onSuccess(String object) {
                super.onSuccess(object);
            }
        });
    }

    private void setPushTemplate(JSONObject params, String channelName, Result result) throws JSONException {
        String pushTemplateName = params.getString("pushTemplateName");
        EMClient.getInstance().pushManager().setPushTemplate(pushTemplateName, new EMWrapperCallBack(result, channelName, null));
    }

    private void getPushTemplate(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().pushManager().getPushTemplate(new EMValueWrapperCallBack<String>(result, channelName) {
            @Override
            public void onSuccess(String object) {
                super.onSuccess(object);
            }
        });
    }

    // 481
    private void syncSilentModels(JSONObject params, String channelName, Result result) {
        EMClient.getInstance().pushManager().syncSilentModeConversationsFromServer(new EMWrapperCallBack(result, channelName, null));
    }

    private void bindDeviceToken(JSONObject params, String channelName, Result result)  throws JSONException {
        String notifierName = params.getString("notifierName");
        String deviceToken = params.getString("deviceToken");
        EMClient.getInstance().pushManager().bindDeviceToken(notifierName, deviceToken, new EMWrapperCallBack(result, channelName, null));
    }

}
