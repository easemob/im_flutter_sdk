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

import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.exceptions.HyphenateException;


import org.json.JSONException;
import org.json.JSONObject;


public class EMClientWrapper extends EMWrapper implements MethodCallHandler {

    static EMClientWrapper wrapper;
    public EMProgressManager progressManager;

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
                init(param, call.method, result);
            }
            else if (EMSDKMethod.createAccount.equals(call.method))
            {
                createAccount(param, call.method, result);
            }
            else if (EMSDKMethod.login.equals(call.method))
            {
                login(param, call.method, result);
            }
            else if (EMSDKMethod.logout.equals(call.method))
            {
                logout(param, call.method, result);
            }
            else if (EMSDKMethod.changeAppKey.equals(call.method))
            {
                changeAppKey(param, call.method, result);
            }
            else if (EMSDKMethod.uploadLog.equals(call.method))
            {
                uploadLog(param, call.method, result);
            }
            else if (EMSDKMethod.compressLogs.equals(call.method))
            {
                compressLogs(param, call.method, result);
            }
            else if (EMSDKMethod.getLoggedInDevicesFromServer.equals(call.method))
            {
                getLoggedInDevicesFromServer(param, call.method, result);
            }
            else if (EMSDKMethod.kickDevice.equals(call.method))
            {
                kickDevice(param, call.method, result);
            }
            else if (EMSDKMethod.kickAllDevices.equals(call.method))
            {
                kickAllDevices(param, call.method, result);
            }
            else if (EMSDKMethod.isLoggedInBefore.equals(call.method))
            {
                isLoggedInBefore(param, call.method, result);
            }
            else if (EMSDKMethod.getCurrentUser.equals(call.method))
            {
                getCurrentUser(param, call.method, result);
            }
            else if (EMSDKMethod.loginWithAgoraToken.equals(call.method))
            {
                loginWithAgoraToken(param, EMSDKMethod.loginWithAgoraToken, result);
            }
            else if (EMSDKMethod.getToken.equals(call.method))
            {
                getToken(param, call.method, result);
            }
            else if (EMSDKMethod.isConnected.equals(call.method)) {
                isConnected(param, call.method, result);
            }
            else if (EMSDKMethod.renewToken.equals(call.method)){
                renewToken(param, call.method, result);
            } else if (EMSDKMethod.startCallback.equals(call.method)) {
                startCallback();
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
                    object = EMClient.getInstance().getCurrentUser();
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
                EMListenerHandle.getInstance().clearHandle();
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

    private void loginWithAgoraToken(JSONObject param, String channelName, Result result) throws JSONException {

        String username = param.getString("username");
        String agoratoken = param.getString("agoratoken");
        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    object = EMClient.getInstance().getCurrentUser();
                    super.onSuccess();
                });
            }
        };

        EMClient.getInstance().loginWithAgoraToken(username, agoratoken, callBack);
    }
    private void getToken(JSONObject param, String channelName, Result result) throws JSONException
    {
        onSuccess(result, channelName, EMClient.getInstance().getAccessToken());
    }

    private void isLoggedInBefore(JSONObject param, String channelName, Result result) throws JSONException {
        onSuccess(result, channelName, EMClient.getInstance().isLoggedInBefore());
    }

    private void isConnected(JSONObject param, String channelName, Result result) throws JSONException{
        onSuccess(result, channelName, EMClient.getInstance().isConnected());
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

    private void init(JSONObject param, String channelName, Result result) throws JSONException {
        EMOptions options = EMOptionsHelper.fromJson(param, this.context);
        EMClient.getInstance().init(this.context, options);
        EMClient.getInstance().setDebugMode(param.getBoolean("debugModel"));
        bindingManagers();
        addEMListener();
        onSuccess(result, channelName, null);
    }

    private void renewToken(JSONObject param, String channelName, Result result) throws JSONException {
        String agoraToken = param.getString("agora_token");
        EMClient.getInstance().renewToken(agoraToken);
        onSuccess(result, channelName, null);
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

    private void startCallback() {
        EMListenerHandle.getInstance().startCallback();
    }

    private void bindingManagers() {
        new EMChatManagerWrapper(binging, "chat_manager");
        new EMContactManagerWrapper(binging, "chat_contact_manager");
        new EMChatRoomManagerWrapper(binging, "chat_room_manager");
        new EMGroupManagerWrapper(binging, "chat_group_manager");
        new EMConversationWrapper(binging, "chat_conversation");
        new EMPushManagerWrapper(binging, "chat_push_manager");
        new EMUserInfoManagerWrapper(binging, "chat_userInfo_manager");
        new EMPresenceManagerWrapper(binging, "chat_presence_manager");
        new EMMessageWrapper(binging, "chat_message");
        new EMChatThreadManagerWrapper(binging, "chat_thread_manager");
        progressManager = new EMProgressManager(binging, "file_progress_manager");
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
                if (errorCode == 206) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidLoginFromOtherDevice, null));
                }else if (errorCode == 207) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidRemoveFromServer, null));
                }else if (errorCode == 305) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidForbidByServer, null));
                }else if (errorCode == 216) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidChangePassword, null));
                }else if (errorCode == 214) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidLoginTooManyDevice, null));
                }
                else if (errorCode == 217) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserKickedByOtherDevice, null));
                }
                else if (errorCode == 202) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserAuthenticationFailed, null));
                }
                else {
                    post(() -> channel.invokeMethod(EMSDKMethod.onDisconnected, null));
                }
            }

            @Override
            public void onTokenExpired() {
                post(()-> channel.invokeMethod(EMSDKMethod.onTokenDidExpire, null));
            }

            @Override
            public void onTokenWillExpire() {
                post(()-> channel.invokeMethod(EMSDKMethod.onTokenWillExpire, null));
            }
        });
    }
}

