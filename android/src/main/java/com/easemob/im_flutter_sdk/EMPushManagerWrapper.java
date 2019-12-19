package com.easemob.im_flutter_sdk;

import android.content.Context;

import com.hyphenate.chat.EMClient;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class EMPushManagerWrapper  implements MethodCallHandler, EMWrapper {

    EMPushManagerWrapper(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;
    }

    private Context context;
    private MethodChannel channel;

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
        EMClient.getInstance().pushManager().getPushConfigs();
    }

    private void getPushConfigsFromServer(Object args, Result result){

    }

    private void updatePushServiceForGroup(Object args, Result result){

    }

    private void getNoPushGroups(Object args, Result result){

    }

    private void updatePushNickname(Object args, Result result){

    }
}
