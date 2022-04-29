package com.easemob.im_flutter_sdk;

import java.util.ArrayList;

import java.util.Map;
import java.util.HashMap;
import java.util.List;


import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

import com.heytap.msp.push.HeytapPushManager;
import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.exceptions.HyphenateException;
import org.json.JSONException;
import org.json.JSONObject;


public class EMClientWrapper extends EMWrapper implements MethodCallHandler {

    static EMClientWrapper wrapper;

    EMClientWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        wrapper = this;
    }

    public static EMClientWrapper getInstance() {
        return wrapper;
    }

    public void sendDataToFlutter(final Map data) {
        if (data == null) {
            return;
        }
        post(()-> channel.invokeMethod(EMSDKMethod.onSendDataToFlutter, data));
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        JSONObject param = (JSONObject)call.arguments;
        try {
            if (EMSDKMethod.init.equals(call.method)) {
                init(param, EMSDKMethod.init, result);
            }
            else if (EMSDKMethod.createAccount.equals(call.method))
            {
                createAccount(param, EMSDKMethod.createAccount, result);
            }
            else if (EMSDKMethod.login.equals(call.method))
            {
                login(param, EMSDKMethod.login, result);
            }
            else if (EMSDKMethod.logout.equals(call.method))
            {
                logout(param, EMSDKMethod.logout, result);
            }
            else if (EMSDKMethod.changeAppKey.equals(call.method))
            {
                changeAppKey(param, EMSDKMethod.changeAppKey, result);
            }
            else if (EMSDKMethod.updateCurrentUserNick.equals(call.method))
            {
                updateCurrentUserNick(param, EMSDKMethod.updateCurrentUserNick, result);
            }
            else if (EMSDKMethod.uploadLog.equals(call.method))
            {
                uploadLog(param, EMSDKMethod.uploadLog, result);
            }
            else if (EMSDKMethod.compressLogs.equals(call.method))
            {
                compressLogs(param, EMSDKMethod.compressLogs, result);
            }
            else if (EMSDKMethod.getLoggedInDevicesFromServer.equals(call.method))
            {
                getLoggedInDevicesFromServer(param, EMSDKMethod.getLoggedInDevicesFromServer, result);
            }
            else if (EMSDKMethod.kickDevice.equals(call.method))
            {
                kickDevice(param, EMSDKMethod.kickDevice, result);
            }
            else if (EMSDKMethod.kickAllDevices.equals(call.method))
            {
                kickAllDevices(param, EMSDKMethod.kickAllDevices, result);
            }
            else if (EMSDKMethod.isLoggedInBefore.equals(call.method))
            {
                isLoggedInBefore(param, EMSDKMethod.isLoggedInBefore, result);
            }
            else if (EMSDKMethod.getCurrentUser.equals(call.method))
            {
                getCurrentUser(param, EMSDKMethod.getCurrentUser, result);
            }
            else  {
                super.onMethodCall(call, result);
            }

        }catch (JSONException ignored) {

        }
    }

    private void createAccount(JSONObject param, String channelName, Result result) throws JSONException {
        String username = param.getString("username");
        String password = param.getString("password");
        asyncRunnable(()->{
            try {
                EMClient.getInstance().createAccount(username, password);
                onSuccess(result, channelName, username);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void login(JSONObject param, String channelName, Result result) throws JSONException {
        boolean isPwd = param.getBoolean("isPassword");
        String username = param.getString("username");
        String pwdOrToken = param.getString("pwdOrToken");
        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    Map<String, String> param = new HashMap<>();
                    param.put("username", EMClient.getInstance().getCurrentUser());
                    param.put("token", EMClient.getInstance().getAccessToken());
                    object = param;
                    super.onSuccess();
                });
            }
        };

        if (isPwd){
            EMClient.getInstance().login(username, pwdOrToken, callBack);
        } else {
            EMClient.getInstance().loginWithToken(username, pwdOrToken, callBack);
        }
    }


    private void logout(JSONObject param, String channelName, Result result) throws JSONException {
        boolean unbindToken = param.getBoolean("unbindToken");
        EMClient.getInstance().logout(unbindToken, new EMWrapperCallBack(result, channelName, null){
            @Override
            public void onSuccess() {
                object = true;
                super.onSuccess();
            }
        });
    }

    private void changeAppKey(JSONObject param, String channelName, Result result) throws JSONException{
        String appKey = param.getString("appKey");
        asyncRunnable(()-> {
            try {
                EMClient.getInstance().changeAppkey(appKey);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getCurrentUser(JSONObject param, String channelName, Result result) throws JSONException {
        onSuccess(result, channelName, EMClient.getInstance().getCurrentUser());
    }

    private void updateCurrentUserNick(JSONObject param, String channelName, Result result) throws JSONException {
        String nickName = param.getString("nickname");
        asyncRunnable(()->{
            try {
                boolean status = EMClient.getInstance().pushManager().updatePushNickname(nickName);
                onSuccess(result, channelName, status);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }


    private void uploadLog(JSONObject param, String channelName, Result result) throws JSONException {
        EMClient.getInstance().uploadLog(new EMWrapperCallBack(result, channelName, true));
    }

    private void compressLogs(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            try {
                String path = EMClient.getInstance().compressLogs();
                onSuccess(result, channelName, path);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void kickDevice(JSONObject param, String channelName, Result result) throws JSONException {

        String username = param.getString("username");
        String password = param.getString("password");
        String resource = param.getString("resource");
        asyncRunnable(()->{
            try {
                EMClient.getInstance().kickDevice(username, password, resource);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void kickAllDevices(JSONObject param, String channelName, Result result) throws JSONException {
        String username = param.getString("username");
        String password = param.getString("password");

        asyncRunnable(()->{
            try {
                EMClient.getInstance().kickAllDevices(username, password);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });

    }

    private void isLoggedInBefore(JSONObject param, String channelName, Result result) throws JSONException {
            onSuccess(result, channelName, EMClient.getInstance().isLoggedInBefore());
    }

    private void onMultiDeviceEvent(JSONObject param, String channelName, Result result) throws JSONException {

    }

    private void getLoggedInDevicesFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        String username = param.getString("username");
        String password = param.getString("password");
        new Thread(() -> {
            try {
                List<EMDeviceInfo> devices = EMClient.getInstance().getLoggedInDevicesFromServer(username, password);
                List<Map> jsonList = new ArrayList <>();
                for (EMDeviceInfo info: devices) {
                    jsonList.add(EMDeviceInfoHelper.toJson(info));
                }
                onSuccess(result, channelName, jsonList);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

//    private void registerManagers() {
//        new EMChatManagerWrapper(registrar, "em_chat_manager");
//        new EMContactManagerWrapper(registrar, "em_contact_manager");
//        new EMChatRoomManagerWrapper(registrar, "em_chat_room_manager");
//        new EMGroupManagerWrapper(registrar, "em_group_manager");
//        new EMConversationWrapper(registrar, "em_conversation");
//        new EMPushManagerWrapper(registrar, "em_push_manager");
//        new EMUserInfoManagerWrapper(registrar, "em_userInfo_manager");
//    }

    private void bindingManagers() {
        new EMChatManagerWrapper(binging, "em_chat_manager");
        new EMContactManagerWrapper(binging, "em_contact_manager");
        new EMChatRoomManagerWrapper(binging, "em_chat_room_manager");
        new EMGroupManagerWrapper(binging, "em_group_manager");
        new EMConversationWrapper(binging, "em_conversation");
        new EMPushManagerWrapper(binging, "em_push_manager");
        new EMUserInfoManagerWrapper(binging, "em_userInfo_manager");
    }
    private void init(JSONObject param, String channelName, Result result) throws JSONException {
        EMOptions options = EMOptionsHelper.fromJson(param, this.context);
        EMClient.getInstance().init(this.context, options);
        //OPPO SDK升级到2.1.0后需要进行初始化
        HeytapPushManager.init(context, true);
        EMClient.getInstance().setDebugMode(param.getBoolean("debugModel"));
        bindingManagers();
        addEMListener();

        Map<String, Object> data = new HashMap<>();
        data.put("isLoginBefore", EMClient.getInstance().isLoggedInBefore());
        data.put("currentUsername", EMClient.getInstance().getCurrentUser());
        onSuccess(result, channelName, data);
    }

    private void addEMListener() {
        EMClient.getInstance().addMultiDeviceListener(new EMMultiDeviceListener() {
            @Override
            public void onContactEvent(int event, String target, String ext) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", Integer.valueOf(event));
                data.put("target", target);
                data.put("ext", ext);
                post(()-> channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data));
            }

            @Override
            public void onGroupEvent(int event, String target, List<String> userNames) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", Integer.valueOf(event));
                data.put("target", target);
                data.put("userNames", userNames);
                post(()-> channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data));
            }
        });

        //setup connection listener
        EMClient.getInstance().addConnectionListener(new EMConnectionListener() {
            @Override
            public void onConnected() {
                Map<String, Object> data = new HashMap<>();
                data.put("connected", Boolean.TRUE);
                post(()-> channel.invokeMethod(EMSDKMethod.onConnected, data));
            }

            @Override
            public void onDisconnected(int errorCode) {
                Map<String, Object> data = new HashMap<>();
                data.put("errorCode", errorCode);
                post(() -> channel.invokeMethod(EMSDKMethod.onDisconnected, data));
            }
        });
    }
}

