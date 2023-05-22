package com.easemob.im_flutter_sdk;

import com.hyphenate.EMContactListener;
import com.hyphenate.EMPresenceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMPresence;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class EMPresenceManagerWrapper  extends EMWrapper implements MethodChannel.MethodCallHandler {

    private EMPresenceListener presenceListener;

    EMPresenceManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.presenceWithDescription.equals(call.method)) {
                publishPresenceWithDescription(param, call.method, result);
            } else if (EMSDKMethod.presenceSubscribe.equals(call.method)) {
                subscribe(param, call.method, result);
            } else if (EMSDKMethod.presenceUnsubscribe.equals(call.method)) {
                unsubscribe(param, call.method, result);
            } else if (EMSDKMethod.fetchPresenceStatus.equals(call.method)) {
                fetchPresenceStatus(param, call.method, result);
            } else if (EMSDKMethod.fetchSubscribedMembersWithPageNum.equals(call.method)) {
                fetchSubscribedMembersWithPageNum(param, call.method, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {
            super.onMethodCall(call, result);
        }
    }

    private void publishPresenceWithDescription(JSONObject params, String channelName, Result result) throws JSONException {
        String desc = params.getString("desc");
        EMClient.getInstance().presenceManager().publishPresence(desc, new EMWrapperCallBack(result, channelName, true));
    }

    private void subscribe(JSONObject params, String channelName, Result result) throws JSONException {
        List<String> members = new ArrayList<>();
        if (params.has("members")){
            JSONArray array = params.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }
        int expiry = 0;
        if (params.has("expiry")) {
            expiry = params.getInt("expiry");
        }

        EMValueWrapperCallBack<List<EMPresence>> callBack = new EMValueWrapperCallBack<List<EMPresence>>(result, channelName) {
            @Override
            public void onSuccess(List<EMPresence> object) {
                List<Map> list = new ArrayList<>();
                for (EMPresence presence: object) {
                    list.add(EMPresenceHelper.toJson(presence));
                }
                super.updateObject(list);
            }
        };

        EMClient.getInstance().presenceManager().subscribePresences(members, expiry, callBack);
    }

    private void unsubscribe(JSONObject params, String channelName, Result result) throws JSONException {
        List<String> members = new ArrayList<>();
        if (params.has("members")){
            JSONArray array = params.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }
        EMClient.getInstance().presenceManager().unsubscribePresences(members, new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchSubscribedMembersWithPageNum(JSONObject params, String channelName, Result result) throws JSONException {
        int pageSize = params.getInt("pageSize");
        int pageNum = params.getInt("pageNum");
        EMClient.getInstance().presenceManager().fetchSubscribedMembers(pageNum, pageSize, new EMValueWrapperCallBack<List<String>>(result ,channelName){
            @Override
            public void onSuccess(List<String> object) {
                super.onSuccess(object);
            }
        });
    }

    private void fetchPresenceStatus(JSONObject params, String channelName, Result result) throws JSONException {
        List<String> members = new ArrayList<>();
        if (params.has("members")){
            JSONArray array = params.getJSONArray("members");
            for (int i = 0; i < array.length(); i++) {
                members.add(array.getString(i));
            }
        }
        EMClient.getInstance().presenceManager().fetchPresenceStatus(members, new EMValueWrapperCallBack<List<EMPresence>>(result, channelName){
            @Override
            public void onSuccess(List<EMPresence> object) {
                List<Map> list = new ArrayList<>();
                for (EMPresence presence: object) {
                    list.add(EMPresenceHelper.toJson(presence));
                }
                super.updateObject(list);
            }
        });
    }
    private void registerEaseListener() {

        if (presenceListener != null) {
            EMClient.getInstance().presenceManager().removeListener(presenceListener);
        }

        presenceListener = presences -> {
            Map<String, Object> data = new HashMap<>();
            List<Map> list = new ArrayList<>();
            for (EMPresence presence: presences) {
                list.add(EMPresenceHelper.toJson(presence));
            }
            data.put("presences", list);

            post(() -> channel.invokeMethod(EMSDKMethod.onPresenceStatusChanged, data));
        };
        EMClient.getInstance().presenceManager().addListener(presenceListener);
    }

    @Override
    public void unRegisterEaseListener(){
        EMClient.getInstance().presenceManager().removeListener(presenceListener);
    }
}
