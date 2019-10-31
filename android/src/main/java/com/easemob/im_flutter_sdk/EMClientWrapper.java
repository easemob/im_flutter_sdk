package com.easemob.im_flutter_sdk;

import java.util.LinkedList;
import java.util.Map;
import java.util.HashMap;
import java.util.List;

import android.content.Context;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.hyphenate.EMClientListener;
import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.chat.EMContact;
import com.hyphenate.util.EMLog;

import org.json.JSONException;
import org.json.JSONObject;

@SuppressWarnings("unchecked")
public class EMClientWrapper implements MethodCallHandler, EMWrapper{

    EMClientWrapper(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;
    }

    private Context context;
    private MethodChannel channel;

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (EMSDKMethod.init.equals(call.method)) {
            init(call.arguments, result);
        } else if(EMSDKMethod.login.equals(call.method)){
            login(call.arguments, result);
        } else if(EMSDKMethod.createAccount.equals(call.method)) {
            createAccount(call.arguments, result);
        } else if(EMSDKMethod.loginWithToken.equals(call.method)) {
            loginWithToken(call.arguments, result);
        } else if(EMSDKMethod.logout.equals(call.method)) {
            logout(call.arguments, result);
        } else if(EMSDKMethod.changeAppKey.equals(call.method)) {
            changeAppKey(call.arguments, result);
        } else if(EMSDKMethod.setDebugMode.equals(call.method)) {
            setDebugMode(call.arguments, result);
        } else if(EMSDKMethod.updateCurrentUserNick.equals(call.method)) {
            updateCurrentUserNick(call.arguments, result);
        } else if(EMSDKMethod.uploadLog.equals(call.method)) {
            uploadLog(call.arguments, result);
        } else if(EMSDKMethod.compressLogs.equals(call.method)) {
            compressLogs(call.arguments, result);
        } else if(EMSDKMethod.getLoggedInDevicesFromServer.equals(call.method)) {
            getLoggedInDevicesFromServer(call.arguments, result);
        } else if(EMSDKMethod.kickDevice.equals(call.method)) {
            kickDevice(call.arguments, result);
        } else if(EMSDKMethod.kickAllDevices.equals(call.method)) {
            kickAllDevices(call.arguments, result);
        } else if(EMSDKMethod.sendFCMTokenToServer.equals(call.method)) {
            sendFCMTokenToServer(call.arguments, result);
        } else if(EMSDKMethod.sendHMSPushTokenToServer.equals(call.method)) {
            sendHMSPushTokenToServer(call.arguments, result);
        } else if(EMSDKMethod.getDeviceInfo.equals(call.method)) {
            getDeviceInfo(call.arguments, result);
        } else if(EMSDKMethod.check.equals(call.method)) {
            check(call.arguments, result);
        }
    }

    private void init(Object args, Result result) {
        try {
            EMOptions options = new EMOptions();
            JSONObject argMap = (JSONObject) args;
            options.setAppKey(argMap.getString("appKey"));
            EMClient client = EMClient.getInstance();
            client.getInstance().init(context, options);
            //setup client listener
            client.addClientListener((boolean success) -> {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("status", Boolean.valueOf(success));
                post((Void) -> {
                    channel.invokeMethod(EMSDKMethod.onClientMigrate2x, data);
                });
            });
            //setup connection listener
            client.addConnectionListener(new EMConnectionListener() {
                @Override
                public void onConnected() {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("connected", Boolean.TRUE);
                    post((Void) -> {
                        channel.invokeMethod(EMSDKMethod.onConnectionDidChanged, data);
                    });
                }

                @Override
                public void onDisconnected(int errorCode) {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("errorCode", Boolean.FALSE);
                    post((Void) -> {
                        channel.invokeMethod(EMSDKMethod.onConnectionDidChanged, data);
                    });
                }
            });
            //setup multiple device event listener
            client.addMultiDeviceListener(new EMMultiDeviceListener() {
                @Override
                public void onContactEvent(int event, String target, String ext) {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("event", Integer.valueOf(event));
                    data.put("target", target);
                    data.put("ext", ext);
                    post((Void) -> {
                        channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data);
                    });
                }

                @Override
                public void onGroupEvent(int event, String target, List<String> userNames) {
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("event", Integer.valueOf(event));
                    data.put("target", target);
                    data.put("userNames", userNames);
                    post((Void) -> {
                        channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data);
                    });
                }
            });
        }catch (JSONException e){
            e.printStackTrace();
        }
    }

    private void createAccount(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            String password = argMap.getString("password");
            try {
                EMClient.getInstance().createAccount(userName, password);
                onSuccess(result);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void login(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            String password = argMap.getString("password");
            EMClient.getInstance().login(userName, password, new EMWrapperCallBack(result));
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void loginWithToken(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            String userName = argMap.getString("userName");
            String token = argMap.getString("token");
            EMClient.getInstance().loginWithToken(userName, token, new EMWrapperCallBack(result));
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void logout(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            Boolean unbindToken = argMap.getBoolean("unbindToken");
            EMClient.getInstance().logout(unbindToken, new EMWrapperCallBack(result));
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void changeAppKey(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            String appKey = argMap.getString("appKey");
            try{
                EMClient.getInstance().changeAppkey(appKey);
                onSuccess(result);
            }catch(HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void setDebugMode(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            Boolean debugMode = argMap.getBoolean("debugMode");
            EMClient.getInstance().setDebugMode(debugMode);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void updateCurrentUserNick(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            String nickName = argMap.getString("nickName");
            boolean status = EMClient.getInstance().pushManager().updatePushNickname(nickName);
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("status", new Boolean(status));
            result.success(data);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void uploadLog(Object args, Result result) {
        EMClient.getInstance().uploadLog(new EMWrapperCallBack(result));
    }

    private void compressLogs(Object args, Result result) {
        try{
            // TODO: 返回路径？
            EMClient.getInstance().compressLogs();
            onSuccess(result);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void getLoggedInDevicesFromServer(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject)args;
            String userName = argMap.getString("userName");
            String password = argMap.getString("password");
            try{
                List<EMDeviceInfo> devices = EMClient.getInstance().getLoggedInDevicesFromServer(userName, password);
                List<Map<String, Object>> devicesMap = new LinkedList<Map<String, Object>>();
                for(EMDeviceInfo device : devices) {
                    devicesMap.add(convertDevicesToStringMap(device));
                }
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("success", Boolean.TRUE);
                data.put("devices", devicesMap);
            }catch(HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private Map<String, Object> convertDevicesToStringMap(EMDeviceInfo device){
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("resource", device.getResource());
        result.put("UUID", device.getDeviceUUID());
        result.put("name", device.getDeviceName());
        return result;
    }

    private void kickDevice(Object args, Result result){
        try {
            JSONObject argMap = (JSONObject)args;
            String userName = argMap.getString("userName");
            String password = argMap.getString("password");
            String resource = argMap.getString("resource");
            try{
                EMClient.getInstance().kickDevice(userName, password, resource);
                onSuccess(result);
            }catch (HyphenateException e) {
                onError(result,e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void kickAllDevices(Object args, Result result){
        try {
            JSONObject argMap = (JSONObject)args;
            String userName = argMap.getString("userName");
            String password = argMap.getString("password");
            try{
                EMClient.getInstance().kickAllDevices(userName, password);
                onSuccess(result);
            }catch (HyphenateException e) {
                onError(result,e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void sendFCMTokenToServer(Object args, Result result){
        try {
            JSONObject argMap = (JSONObject)args;
            String token = argMap.getString("token");
            EMClient.getInstance().sendFCMTokenToServer(token);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void sendHMSPushTokenToServer(Object args, Result result){
        try {
            JSONObject argMap = (JSONObject)args;
            String token = argMap.getString("token");
            EMClient.getInstance().sendHMSPushTokenToServer(token);
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    // TODO: 返回?
    private void getDeviceInfo(Object args, Result result){
        JSONObject device = EMClient.getInstance().getDeviceInfo();
        Map<String, Object> info = convertDeviceInfoToStringMap(device);
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("deviceInfo", info);
    }

    private Map<String, Object> convertDeviceInfoToStringMap(JSONObject device) {
        Map<String, Object> result = new HashMap<String, Object>();
        while(device.keys().hasNext()) {
            try{
                result.put(device.keys().next(), device.get(device.keys().next()));
            }catch(JSONException e) {}// ignore
        }
        return result;
    }

    private void check(Object args, Result result){
        try {
            JSONObject argMap = (JSONObject)args;
            String userName = argMap.getString("userName");
            String password = argMap.getString("password");
            EMClient.getInstance().check(userName, password, new EMClient.CheckResultListener() {
                @Override
                public void onResult(int type, int _result, String desc) {
                    post((Void)->{
                        Map<String, Object> data = new HashMap<String, Object>();
                        data.put("success", Boolean.TRUE);
                        data.put("type", type);
                        data.put("result", _result);
                        data.put("desc", desc);
                        result.success(data);
                    });
                }
            });
        }catch(JSONException e) {
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private Map<String, Object> convertContactToStringMap(EMContact contact) {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("userName", contact.getUsername());
        result.put("nickName", contact.getNickname());
        return result;
    }
}

