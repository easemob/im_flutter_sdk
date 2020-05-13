package com.easemob.im_flutter_sdk;

import android.content.Context;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMPushConfigs;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import static com.easemob.im_flutter_sdk.EMHelper.convertEMPushConfigsToStringMap;

public class EMPushManagerWrapper  implements MethodCallHandler, EMWrapper {

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (EMSDKMethod.enableOfflinePush.equals(call.method)) {
            enableOfflinePush(call.arguments, result);
        } else if(EMSDKMethod.disableOfflinePush.equals(call.method)){
            disableOfflinePush(call.arguments, result);
        }else if(EMSDKMethod.getPushConfigs.equals(call.method)){
            getPushConfigs(call.arguments, result);
        }else if(EMSDKMethod.getPushConfigsFromServer.equals(call.method)){
            getPushConfigsFromServer(call.arguments, result);
        }else if(EMSDKMethod.updatePushServiceForGroup.equals(call.method)){
            updatePushServiceForGroup(call.arguments, result);
        }else if(EMSDKMethod.getNoPushGroups.equals(call.method)){
            getNoPushGroups(call.arguments, result);
        }else if(EMSDKMethod.updatePushNickname.equals(call.method)){
            updatePushNickname(call.arguments, result);
        }else if(EMSDKMethod.updatePushDisplayStyle.equals(call.method)){
            updatePushDisplayStyle(call.arguments, result);
        }
    }

    private void enableOfflinePush(Object args, Result result){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    EMClient.getInstance().pushManager().enableOfflinePush();
                    onSuccess(result);
                }catch (HyphenateException e){
                    EMLog.e("HyphenateException", e.getMessage());
                    onError(result, e);
                }
            }
        }).start();
    }

    private void disableOfflinePush(Object args, Result result){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argMap = (JSONObject) args;
                    int startTime = argMap.getInt("startTime");
                    int endTime = argMap.getInt("endTime");
                    try {
                        EMClient.getInstance().pushManager().disableOfflinePush(startTime, endTime);
                        onSuccess(result);
                    } catch (HyphenateException e) {
                        EMLog.e("HyphenateException", e.getMessage());
                        onError(result, e);
                    }
                }catch (JSONException e){
                    EMLog.e("JSONException", e.getMessage());
                }
            }
        }).start();
    }

    private void getPushConfigs(Object args, Result result){
        EMPushConfigs configs = EMClient.getInstance().pushManager().getPushConfigs();
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("value", convertEMPushConfigsToStringMap(configs));
        post(new Runnable() {
            @Override
            public void run() {
                result.success(data);
            }});
    }

    private void getPushConfigsFromServer(Object args, Result result){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    EMPushConfigs configs = EMClient.getInstance().pushManager().getPushConfigsFromServer();
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("success", Boolean.TRUE);
                    data.put("value", convertEMPushConfigsToStringMap(configs));
                    post(new Runnable() {
                        @Override
                        public void run() {
                            result.success(data);
                        }});
                }catch (HyphenateException e){
                    EMLog.e("HyphenateException", e.getMessage());
                    onError(result, e);
                }
            }
        }).start();
    }

    private void updatePushServiceForGroup(Object args, Result result){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argMap = (JSONObject) args;
                    JSONArray groupIds = argMap.getJSONArray("groupIds");
                    boolean noPush = argMap.getBoolean("noPush");
                    List<String> groupIdList = new ArrayList<String>();
                    for(int i = 0; i < groupIds.length(); i++){
                        groupIdList.add(groupIds.get(i).toString());
                    }
                    try {
                        EMClient.getInstance().pushManager().updatePushServiceForGroup(groupIdList, noPush);
                        onSuccess(result);
                    } catch (HyphenateException e) {
                        EMLog.e("HyphenateException", e.getMessage());
                        onError(result, e);
                    }
                }catch (JSONException e){
                    EMLog.e("JSONException", e.getMessage());
                }
            }
        }).start();
    }

    private void getNoPushGroups(Object args, Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        data.put("value", EMClient.getInstance().pushManager().getNoPushGroups());
        post(new Runnable() {
            @Override
            public void run() {
                result.success(data);
            }});
    }

    private void updatePushNickname(Object args, Result result){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject argMap = (JSONObject) args;
                    String nickname = argMap.getString("nickname");
                    boolean updatenick = EMClient.getInstance().pushManager().updatePushNickname(nickname);
                    Map<String, Object> data = new HashMap<String, Object>();
                    data.put("success", Boolean.TRUE);
                    data.put("value", updatenick);
                    post(new Runnable() {
                        @Override
                        public void run() {
                            result.success(data);
                        }});
                }catch (JSONException e){
                    EMLog.e("JSONException", e.getMessage());
                }
            }
        }).start();
    }

    private void updatePushDisplayStyle(Object args, Result result){
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        post(new Runnable() {
            @Override
            public void run() {
                result.success(data);
            }});
    }
}
