package com.easemob.im_flutter_sdk;

import java.util.LinkedList;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.function.Consumer;

import android.content.Context;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.push.EMPushHelper;
import com.hyphenate.push.EMPushType;
import com.hyphenate.util.EMLog;

import org.json.JSONException;
import org.json.JSONObject;


@SuppressWarnings("unchecked")
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
        }else if (EMSDKMethod.getCurrentUser.equals(call.method)) {
            getCurrentUser(call.arguments, result);
        }
    }

    private void init(Object args, String channelName, Result result) {
        JSONObject argMap = (JSONObject) args;
        EMOptions options = EMHelper.convertStringMapToEMOptions(argMap, context);
        EMClient client = EMClient.getInstance();
        client.init(context, options);

        try {
            boolean debugModel = argMap.getBoolean("debugModel");
            client.setDebugMode(debugModel);
        }catch (JSONException e) {

        }

        //setup connection listener
        client.addConnectionListener(new EMConnectionListener() {
            @Override
            public void onConnected() {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("connected", Boolean.TRUE);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onConnected, data);
                    }
                });
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

        client.addMultiDeviceListener(new EMMultiDeviceListener() {
            @Override
            public void onContactEvent(int event, String target, String ext) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("event", Integer.valueOf(event));
                data.put("target", target);
                data.put("ext", ext);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data);
                    }
                });
            }

            @Override
            public void onGroupEvent(int event, String target, List<String> userNames) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("event", Integer.valueOf(event));
                data.put("target", target);
                data.put("userNames", userNames);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onMultiDeviceEvent, data);
                    }
                });
            }
        });
    }

    private void createAccount(Object args, Result result) {
        new Thread(new Runnable() {
            @Override
            public void run() {
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
                } catch (JSONException e) {
                    EMLog.e("JSONException", e.getMessage());
                }
            }
        }).start();

    }

    private void login(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            String password = argMap.getString("password");
            EMClient.getInstance().login(userName, password, new EMWrapperCallBack(result));
        } catch (JSONException e) {
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void loginWithToken(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            String token = argMap.getString("token");
            EMClient.getInstance().loginWithToken(userName, token, new EMWrapperCallBack(result));
        } catch (JSONException e) {
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void logout(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            Boolean unbindToken = argMap.getBoolean("unbindToken");
            EMClient.getInstance().logout(unbindToken, new EMWrapperCallBack(result));
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

