package com.easemob.im_flutter_sdk;

import com.hyphenate.EMError;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMPushConfigs;
import com.hyphenate.chat.EMPushManager;
import com.hyphenate.chat.EMPushManager.DisplayStyle;
import com.hyphenate.push.EMPushConfig;
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
    protected boolean dispatchMethodCall(
            String method,
            JSONObject params,
            Result result
    ) throws Exception {
        if (MethodKey.getImPushConfig.equals(method)) {
            getImPushConfig(params, method, result);
            return true;
        }
        else if (MethodKey.getImPushConfigFromServer.equals(method)) {
            getImPushConfigFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.updatePushNickname.equals(method)) {
            updatePushNickname(params, method, result);
            return true;
        }
        else if (MethodKey.updateImPushStyle.equals(method)) {
            updateImPushStyle(params, method, result);
            return true;
        }
        else if (MethodKey.updateHMSPushToken.equals(method)) {
            updateHMSPushToken(params, method, result);
            return true;
        }
        else if (MethodKey.updateFCMPushToken.equals(method)) {
            updateFCMPushToken(params, method, result);
            return true;
        }
        else if (MethodKey.reportPushAction.equals(method)) {
            reportPushAction(params, method, result);
            return true;
        }
        else if (MethodKey.setConversationSilentMode.equals(method)) {
            setConversationSilentMode(params, method, result);
            return true;
        }
        else if (MethodKey.removeConversationSilentMode.equals(method)) {
            removeConversationSilentMode(params, method, result);
            return true;
        }
        else if (MethodKey.fetchConversationSilentMode.equals(method)) {
            fetchConversationSilentMode(params, method, result);
            return true;
        }
        else if (MethodKey.setSilentModeForAll.equals(method)) {
            setSilentModeForAll(params, method, result);
            return true;
        }
        else if (MethodKey.fetchSilentModeForAll.equals(method)) {
            fetchSilentModeForAll(params, method, result);
            return true;
        }
        else if (MethodKey.fetchSilentModeForConversations.equals(method)) {
            fetchSilentModeForConversations(params, method, result);
            return true;
        }
        else if (MethodKey.setPreferredNotificationLanguage.equals(method)) {
            setPreferredNotificationLanguage(params, method, result);
            return true;
        }
        else if (MethodKey.fetchPreferredNotificationLanguage.equals(method)) {
            fetchPreferredNotificationLanguage(params, method, result);
            return true;
        }
        else if (MethodKey.getPushTemplate.equals(method)) {
            getPushTemplate(params, method, result);
            return true;
        }
        else if (MethodKey.getPushConfigsFromServer.equals(method)) {
            getPushConfigsFromServer(params, method, result);
            return true;
        }
        else if (MethodKey.setPushTemplate.equals(method)) {
            setPushTemplate(params, method, result);
            return true;
        }
        else if (MethodKey.syncSilentModels.equals(method)) {
            syncSilentModels(params, method, result);
            return true;
        }
        else if (MethodKey.bindDeviceToken.equals(method)) {
            bindDeviceToken(params, method, result);
            return true;
        }

        return super.dispatchMethodCall(method, params, result);
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
        // 【透传原生】不本地检查登录（原生处理）
        String username = EMClient.getInstance().getCurrentUser();

        String nickname = params.getString("nickname");
        EMClient.getInstance().pushManager().asyncUpdatePushNickname(nickname, new EMWrapperCallBack(result, channelName, true));
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
        // pushConfig 未配置时为 null：透传空 fcmKey 给原生，由原生校验（空 notifierName → 110）；避免 NPE
        String fcmKey = "";
        EMPushConfig config = EMClient.getInstance().getOptions().getPushConfig();
        if (config != null) {
            fcmKey = config.getFcmSenderId();
        }
        EMClient.getInstance().pushManager().bindDeviceToken(fcmKey, token, new EMWrapperCallBack(result, channelName, null));
    }

    private void reportPushAction(JSONObject params, String channelName, Result result) throws JSONException {
        JSONObject pushPayload = params.optJSONObject("pushPayload");
        String actionStr = params.optString("action", "ARRIVE");
        EMPushManager.EMPushAction action;
        if ("CLICK".equals(actionStr)) {
            action = EMPushManager.EMPushAction.CLICK;
        } else {
            action = EMPushManager.EMPushAction.ARRIVE;
        }
        EMClient.getInstance().pushManager().reportPushAction(pushPayload, action,
                new EMWrapperCallBack(result, channelName, null));
    }

    private void setConversationSilentMode(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("convId");
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
        String conversationId = params.getString("convId");
        EMConversation.EMConversationType type = EnumTools.conversationTypeFromInt(params.getInt("conversationType"));
        EMClient.getInstance().pushManager().clearRemindTypeForConversation(conversationId, type, new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchConversationSilentMode(JSONObject params, String channelName, Result result) throws JSONException {
        String conversationId = params.getString("convId");
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

    private void getPushConfigsFromServer(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().pushManager().asyncGetPushConfigsFromServer(new EMValueWrapperCallBack<EMPushConfigs>(result, channelName) {
            @Override
            public void onSuccess(EMPushConfigs configs) {
                updateObject(PushConfigsHelper.toJson(configs));
            }
        });
    }

}
