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

import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.exceptions.HyphenateException;

import com.hyphenate.util.EMLog;

import org.json.JSONException;
import org.json.JSONObject;


public class EMClientWrapper implements MethodCallHandler, EMWrapper {

    EMClientWrapper(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;
    }

    private Context context;
    private MethodChannel channel;

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (EMSDKMethod.init.equals(call.method)) {
            init(call.arguments, EMSDKMethod.init, result);
        }
        else if (EMSDKMethod.createAccount.equals(call.method))
        {
            createAccount(call.arguments, EMSDKMethod.init, result);
        }
        else if (EMSDKMethod.login.equals(call.method))
        {
            login(call.arguments, EMSDKMethod.init, result);
        }
        else if (EMSDKMethod.logout.equals(call.method))
        {
            logout(call.arguments, EMSDKMethod.init, result);
        }
        else if (EMSDKMethod.getCurrentUser.equals(call.method))
        {
            getCurrentUser(call.arguments, result);
        }
    }

    private void init(Object args, String channelName, Result result) {
        JSONObject argMap = (JSONObject) args;
        try {
            EMOptions options = EMOptionsHelper.fromJson(argMap);
            EMClient.getInstance().init(context, options);
            EMClient.getInstance().setDebugMode(argMap.getBoolean("debugModel"));
            addEMListener();
            onSuccess(result, channelName,null);
        }catch (JSONException e) {

        }
    }


    private void addEMListener() {
        EMClient.getInstance().addMultiDeviceListener(new EMMultiDeviceListener() {
            @Override
            public void onContactEvent(int event, String target, String ext) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", Integer.valueOf(event));
                data.put("target", target);
                data.put("ext", ext);
                post(()-> {
                    channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data);
                });
            }

            @Override
            public void onGroupEvent(int event, String target, List<String> userNames) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", Integer.valueOf(event));
                data.put("target", target);
                data.put("userNames", userNames);
                post(()-> {
                    channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data);
                });
            }
        });

        //setup connection listener
        EMClient.getInstance().addConnectionListener(new EMConnectionListener() {
            @Override
            public void onConnected() {
                Map<String, Object> data = new HashMap<>();
                data.put("connected", Boolean.TRUE);
                post(()-> { channel.invokeMethod(EMSDKMethod.onConnected, data);});
            }

            @Override
            public void onDisconnected(int errorCode) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("errorCode", errorCode);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onDisconnected, data);
                    }
                });
            }
        });
    }

    private void createAccount(Object args, String channelName, Result result) {
        new Thread(()-> {
                try {
                    JSONObject argMap = (JSONObject) args;
                    String userName = argMap.getString("username");
                    String password = argMap.getString("password");
                    EMClient.getInstance().createAccount(userName, password);
                    onSuccess(result, channelName, userName);
                } catch (HyphenateException e) {
                    onError(result, e);
                } catch (JSONException e) {
                    EMLog.e("JSONException", e.getMessage());
                }
        });
    }

    private void login(Object args, String channelName, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            boolean isPwd = argMap.getBoolean("isPassword");
            String username = argMap.getString("username");
            String pwdOrToken = argMap.getString("pwdOrToken");
            if (isPwd){
                EMClient.getInstance().login(username, pwdOrToken, new EMWrapperCallBack(result, channelName, username));
            } else {
                EMClient.getInstance().loginWithToken(username, pwdOrToken, new EMWrapperCallBack(result, channelName, username));
            }
        } catch (JSONException e) {
            EMLog.e("JSONException", e.getMessage());
        }
    }


    private void logout(Object args, String channelName, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            Boolean unbindToken = argMap.getBoolean("unbindToken");
            EMClient.getInstance().logout(unbindToken, new EMWrapperCallBack(result, channelName, null));
        } catch (JSONException e) {
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void changeAppKey(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String appKey = argMap.getString("appKey");
            try {
                EMClient.getInstance().changeAppkey(appKey);
                onSuccess(result);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        } catch (JSONException e) {
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void updateCurrentUserNick(Object args, Result result) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argMap = (JSONObject) args;
                    String nickName = argMap.getString("nickName");
                    boolean status = EMClient.getInstance().pushManager().updatePushNickname(nickName);
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("success", Boolean.TRUE);
                    data.put("status", new Boolean(status));
                    post(new Runnable() {
                        @Override
                        public void run() {
                            result.success(data);
                        }
                    });
                } catch (JSONException | HyphenateException e) {
                    EMLog.e("updatePushNickname", e.getMessage());
                }
            }
        }).start();
    }

    private void uploadLog(Object args, Result result) {
        EMClient.getInstance().uploadLog(new EMWrapperCallBack(result));
    }

    private void compressLogs(Object args, Result result) {
        try {
            String path = EMClient.getInstance().compressLogs();
            Map<String, Object> data = new HashMap<String, Object>();
            data.put("success", Boolean.TRUE);
            data.put("logs", path);
            post(new Runnable() {
                @Override
                public void run() {
                    result.success(data);
                }
            });
        } catch (HyphenateException e) {
            onError(result, e);
        }
    }

    private void getLoggedInDevicesFromServer(Object args, Result result) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argMap = (JSONObject) args;
                    String userName = argMap.getString("userName");
                    String password = argMap.getString("password");
                    try {
                        List<EMDeviceInfo> devices = EMClient.getInstance().getLoggedInDevicesFromServer(userName, password);
                        List<Map<String, Object>> devicesMap = new LinkedList<Map<String, Object>>();
                        for (EMDeviceInfo device : devices) {
                            devicesMap.add(EMHelper.convertDevicesToStringMap(device));
                        }
                        Map<String, Object> data = new HashMap<String, Object>();
                        data.put("success", Boolean.TRUE);
                        data.put("devices", devicesMap);
                        post(new Runnable() {
                            @Override
                            public void run() {
                                result.success(data);
                            }
                        });
                    } catch (HyphenateException e) {
                        onError(result, e);
                    }
                } catch (JSONException e) {
                    EMLog.e("JSONException", e.getMessage());
                }
            }
        }).start();
    }

    private void kickDevice(Object args, Result result) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argMap = (JSONObject) args;
                    String userName = argMap.getString("userName");
                    String password = argMap.getString("password");
                    String resource = argMap.getString("resource");
                    try {
                        EMClient.getInstance().kickDevice(userName, password, resource);
                        onSuccess(result);
                    } catch (HyphenateException e) {
                        onError(result, e);
                    }
                } catch (JSONException e) {
                    EMLog.e("JSONException", e.getMessage());
                }
            }
        }).start();
    }

    private void kickAllDevices(Object args, Result result) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argMap = (JSONObject) args;
                    String userName = argMap.getString("userName");
                    String password = argMap.getString("password");
                    try {
                        EMClient.getInstance().kickAllDevices(userName, password);
                        onSuccess(result);
                    } catch (HyphenateException e) {
                        onError(result, e);
                    }
                } catch (JSONException e) {
                    EMLog.e("JSONException", e.getMessage());
                }
            }
        }).start();
    }

    private void isLoggedInBefore(Object args, Result result) {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("isLogged", EMClient.getInstance().isLoggedInBefore());
        post(new Runnable() {
            @Override
            public void run() {
                result.success(data);
            }
        });
    }

    private void getCurrentUser(Object args, Result result) {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("userName", EMClient.getInstance().getCurrentUser());
        post(new Runnable() {
            @Override
            public void run() {
                result.success(data);
            }
        });
    }

//    private void addMultiDeviceListener(Object args, Result result){
//        //setup multiple device event listener
//        client.addMultiDeviceListener(new EMMultiDeviceListener() {
//            @Override
//            public void onContactEvent(int event, String target, String ext) {
//                Map<String, Object> data = new HashMap<String, Object>();
//                data.put("event", Integer.valueOf(event));
//                data.put("target", target);
//                data.put("ext", ext);
//                post((Void) -> {
//                    channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data);
//                });
//            }
//
//            @Override
//            public void onGroupEvent(int event, String target, List<String> userNames) {
//                Map<String, Object> data = new HashMap<String, Object>();
//                data.put("event", Integer.valueOf(event));
//                data.put("target", target);
//                data.put("userNames", userNames);
//                post((Void) -> {
//                    channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data);
//                });
//            }
//        });
//    }

//
//    /// TODO: 需要修改为Remove方式
//    private void removeMultiDeviceListener(Object args, Result result){
//
//    }
//

//    private void addConnectionListener(Object args, Result result){
//        client.addConnectionListener(new EMConnectionListener() {
//            @Override
//            public void onConnected() {
//                Map<String, Object> data = new HashMap<String, Object>();
//                data.put("connected", Boolean.TRUE);
//                post((Void) -> {
//                    channel.invokeMethod(EMSDKMethod.onConnected, data);
//                });
//            }
//
//            @Override
//            public void onDisconnected(int errorCode) {
//                Map<String, Object> data = new HashMap<String, Object>();
//                data.put("errorCode", errorCode);
//                post((Void) -> {
//                    channel.invokeMethod(EMSDKMethod.onDisconnected, data);
//                });
//            }
//        });
//    }
//
//    /// TODO: 需要修改为Remove方式
//    private void removeConnectionListener(Object args, Result result){
//
//    }
}

