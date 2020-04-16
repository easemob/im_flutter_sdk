package com.easemob.im_flutter_sdk;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.hyphenate.EMContactListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMContactManager;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

@SuppressWarnings("unchecked")
public class EMContactManagerWrapper implements MethodCallHandler, EMWrapper{
    private EMContactManager manager;
    private MethodChannel channel;

    EMContactManagerWrapper(MethodChannel channel) {
        this.channel = channel;
    }

    private void init() {
        //setup contact listener
        manager.setContactListener(new EMContactListener() {
            @Override
            public void onContactAdded(String userName) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onContactAdded");
                data.put("userName", userName);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                    }});

            }

            @Override
            public void onContactDeleted(String userName) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onContactDeleted");
                data.put("userName", userName);
                post(new Runnable() {
                    @Override
                    public void run() {
                        channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                    }});
            }

            @Override
            public void onContactInvited(String userName, String reason) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onContactInvited");
                data.put("userName", userName);
                data.put("reason", reason);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                    }});
            }

            @Override
            public void onFriendRequestAccepted(String userName) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onFriendRequestAccepted");
                data.put("userName", userName);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                }});
            }

            @Override
            public void onFriendRequestDeclined(String userName) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", "onFriendRequestDeclined");
                data.put("userName", userName);
                post(new Runnable() {
                    @Override
                    public void run() {
                    channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                    }});
            }
        });
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if(manager == null) {
            manager = EMClient.getInstance().contactManager();
            init();
        }
        if (EMSDKMethod.addContact.equals(call.method)) {
            addContact(call.arguments, result);
        }else if(EMSDKMethod.deleteContact.equals(call.method)) {
            deleteContact(call.arguments, result);
        }else if(EMSDKMethod.getAllContactsFromServer.equals(call.method)) {
            getAllContactsFromServer(call.arguments, result);
        }else if(EMSDKMethod.addUserToBlackList.equals(call.method)) {
            addUserToBlackList(call.arguments, result);
        }else if(EMSDKMethod.removeUserFromBlackList.equals(call.method)) {
            removeUserFromBlackList(call.arguments, result);
        }else if(EMSDKMethod.getBlackListFromServer.equals(call.method)) {
            getBlackListFromServer(call.arguments,result);
        }else if(EMSDKMethod.acceptInvitation.equals(call.method)) {
            acceptInvitation(call.arguments, result);
        }else if(EMSDKMethod.declineInvitation.equals(call.method)) {
            declineInvitation(call.arguments, result);
        }else if(EMSDKMethod.getSelfIdsOnOtherPlatform.equals(call.method)) {
            getSelfIdsOnOtherPlatform(call.arguments, result);
        }
    }

    private void addContact(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            String reason = argMap.getString("reason");
            manager.aysncAddContact(userName, reason, new EMWrapperCallBack(result));
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void deleteContact(Object args, Result result) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    try {
                        JSONObject argMap = (JSONObject) args;
                        String userName = argMap.getString("userName");
                        boolean keepConversation = argMap.getBoolean("keepConversation");
                        manager.deleteContact(userName, keepConversation);
                        onSuccess(result);
                    }catch (HyphenateException e){
                        onError(result, e);
                    }
                }catch (JSONException e){
                    EMLog.e("JSONException", e.getMessage());
                }
            }
        }).start();
    }

    private void getAllContactsFromServer(Object args, Result result) {
            manager.aysncGetAllContactsFromServer(new EMValueWrapperCallBack<List<String>>(result));
    }

    private void addUserToBlackList(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            Boolean both = argMap.getBoolean("both");
            manager.aysncAddUserToBlackList(userName, both.booleanValue(), new EMWrapperCallBack(result));
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void removeUserFromBlackList(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            manager.aysncRemoveUserFromBlackList(userName, new EMWrapperCallBack(result));
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getBlackListFromServer(Object args, Result result) {
        manager.aysncGetBlackListFromServer(new EMValueWrapperCallBack<List<String>>(result));

    }

    private void acceptInvitation(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            manager.asyncAcceptInvitation(userName, new EMWrapperCallBack(result));
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void declineInvitation(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            manager.asyncDeclineInvitation(userName, new EMWrapperCallBack(result));
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getSelfIdsOnOtherPlatform(Object args, Result result) {
        manager.aysncGetSelfIdsOnOtherPlatform(new EMValueWrapperCallBack<List<String>>(result));
    }
}
