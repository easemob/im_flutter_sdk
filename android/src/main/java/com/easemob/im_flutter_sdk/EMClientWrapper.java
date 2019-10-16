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
        } else if(EMSDKMethod.getUserTokenFromServer.equals(call.method)) {
            getUserTokenFromServer(call.arguments, result);
        } else if(EMSDKMethod.getRobotsFromServer.equals(call.method)) {
            getRobotsFromServer(call.arguments,result);
        }
    }

    private void init(Object args, Result result) {
        EMOptions options = new EMOptions();
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        options.setAppKey((String)argMap.get("appKey"));
        EMClient client = EMClient.getInstance();
        client.getInstance().init(context, options);
        //setup client listener
        client.addClientListener((boolean success) -> {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("status", Boolean.valueOf(success));
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onClientMigrate2x,data);
                });
        });
        //setup connection listener
        client.addConnectionListener(new EMConnectionListener(){
            @Override
            public void onConnected() {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("isConnected", Boolean.TRUE);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onConnectionDidChanged,data);
                });
            }

            @Override
            public void onDisconnected(int errorCode) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("isConnected", Boolean.FALSE);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onConnectionDidChanged,data);
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
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent,data);
                });
            }

            @Override
            public void onGroupEvent(int event, String target, List<String> userNames) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("event", Integer.valueOf(event));
                data.put("target", target);
                data.put("userNames", userNames);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent,data);
                });
            }
        });
    }

    private void createAccount(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String password = (String)argMap.get("password");
        try{
            EMClient.getInstance().createAccount(userName, password);
            onSuccess(result);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void login(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String password = (String)argMap.get("password");
        EMClient.getInstance().login(userName, password, new EMWrapperCallBack(result));
    }

    private void loginWithToken(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String token = (String)argMap.get("token");
        EMClient.getInstance().loginWithToken(userName, token, new EMWrapperCallBack(result));
    }

    private void logout(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        Boolean unbindToken = (Boolean)argMap.get("unbindToken");
        EMClient.getInstance().logout(unbindToken, new EMWrapperCallBack(result));
    }

    private void changeAppKey(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String appKey = (String)argMap.get("appKey");
        try{
            EMClient.getInstance().changeAppkey(appKey);
            onSuccess(result);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void setDebugMode(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        Boolean debugMode = (Boolean)argMap.get("debugMode");
        EMClient.getInstance().setDebugMode(debugMode);
    }

    private void updateCurrentUserNick(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String nickName = (String)argMap.get("nickName");
        boolean status = EMClient.getInstance().updateCurrentUserNick(nickName);
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("status", new Boolean(status));
        result.success(data);
    }

    private void uploadLog(Object args, Result result) {
        assert(args instanceof Map);
        EMClient.getInstance().uploadLog(new EMWrapperCallBack(result));
    }

    private void compressLogs(Object args, Result result) {
        assert(args instanceof Map);
        try{
            EMClient.getInstance().compressLogs();
            onSuccess(result);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void getLoggedInDevicesFromServer(Object args, Result result) {
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String password = (String)argMap.get("password");
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
    }

    private Map<String, Object> convertDevicesToStringMap(EMDeviceInfo device){
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("resource", device.getResource());
        result.put("UUID", device.getDeviceUUID());
        result.put("name", device.getDeviceName());
        return result;
    }

    private void kickDevice(Object args, Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String password = (String)argMap.get("password");
        String resource = (String)argMap.get("resource");
        try{
            EMClient.getInstance().kickDevice(userName, password, resource);
            onSuccess(result);
        }catch (HyphenateException e) {
            onError(result,e);
        }
    }

    private void kickAllDevices(Object args, Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String password = (String)argMap.get("password");
        try{
            EMClient.getInstance().kickAllDevices(userName, password);
            onSuccess(result);
        }catch (HyphenateException e) {
            onError(result,e);
        }
    }

    private void sendFCMTokenToServer(Object args, Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String token = (String)argMap.get("token");
        EMClient.getInstance().sendFCMTokenToServer(token);
    }

    private void sendHMSPushTokenToServer(Object args, Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String appId = (String)argMap.get("appId");
        String token = (String)argMap.get("token");
        EMClient.getInstance().sendHMSPushTokenToServer(appId,token);
    }

    private void getDeviceInfo(Object args, Result result){
        assert(args instanceof Map);
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
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String password = (String)argMap.get("password");
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
    }

    private void getUserTokenFromServer(Object args, Result result){
        assert(args instanceof Map);
        Map<String, Object> argMap = (Map<String, Object>)args;
        String userName = (String)argMap.get("userName");
        String password = (String)argMap.get("password");
        EMClient.getInstance().getUserTokenFromServer(userName, password, new EMValueCallBack<String>() {
            @Override
            public void onSuccess(String token) {
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("success", Boolean.TRUE);
                    data.put("token", token);
                    result.success(data);
                });
            }

            @Override
            public void onError(int code, String desc) {
                post((Void)->{
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("success", Boolean.FALSE);
                    data.put("code", code);
                    data.put("desc", desc);
                    result.success(data);
                });
            }
        });
    }

    private void getRobotsFromServer(Object args, Result result){
        assert(args instanceof Map);
        try{
            List<EMContact> contacts = EMClient.getInstance().getRobotsFromServer();
            List<Map<String, Object>> contactsMap = new LinkedList<Map<String, Object>>();
            for(EMContact contact : contacts) {
                contactsMap.add(convertContactToStringMap(contact));
            }
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("contacts", contactsMap);
        }catch (HyphenateException e) {
            onError(result, e);
        }
    }

    private Map<String, Object> convertContactToStringMap(EMContact contact) {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("userName", contact.getUsername());
        result.put("nickName", contact.getNickname());
        return result;
    }
}

