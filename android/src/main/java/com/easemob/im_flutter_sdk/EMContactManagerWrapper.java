package com.easemob.im_flutter_sdk;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.hyphenate.EMContactListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMContactManager;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import org.json.JSONArray;
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

    private static final int CONTACT_ADD = 0;
    private static final int CONTACT_DELETE = 1;
    private static final int INVITED = 2;
    private static final int INVITATION_ACCEPTED = 3;
    private static final int INVITATION_DECLINED = 4;

    EMContactManagerWrapper(MethodChannel channel) {
        this.channel = channel;
    }

    private void init() {
        //setup contact listener
        manager.setContactListener(new EMContactListener() {
            @Override
            public void onContactAdded(String userName) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", Integer.valueOf(CONTACT_ADD));
                data.put("userName", userName);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                });
            }

            @Override
            public void onContactDeleted(String userName) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", Integer.valueOf(CONTACT_DELETE));
                data.put("userName", userName);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                });
            }

            @Override
            public void onContactInvited(String userName, String reason) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", Integer.valueOf(INVITED));
                data.put("userName", userName);
                data.put("reason", reason);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                });
            }

            @Override
            public void onFriendRequestAccepted(String userName) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", Integer.valueOf(INVITATION_ACCEPTED));
                data.put("userName", userName);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                });
            }

            @Override
            public void onFriendRequestDeclined(String userName) {
                Map<String, Object> data = new HashMap<String, Object>();
                data.put("type", Integer.valueOf(INVITATION_DECLINED));
                data.put("userName", userName);
                post((Void)->{
                    channel.invokeMethod(EMSDKMethod.onContactChanged, data);
                });
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
            removeUserToBlackList(call.arguments, result);
        }else if(EMSDKMethod.getBlackListFromServer.equals(call.method)) {
            getBlackListFromServer(call.arguments,result);
        }else if(EMSDKMethod.saveBlackList.equals(call.method)) {
            saveBlackList(call.arguments, result);
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
            try {
                manager.addContact(userName, reason);
                onSuccess(result);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void deleteContact(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            try{
                manager.deleteContact(userName);
                onSuccess(result);
            }catch(HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getAllContactsFromServer(Object args, Result result) {
        try{
            List<String> contacts = manager.getAllContactsFromServer();
            Map<String,Object> data = new HashMap<String, Object>();
            data.put("contacts", contacts);
            result.success(data);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void addUserToBlackList(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            Boolean both = argMap.getBoolean("both");
            try{
                manager.addUserToBlackList(userName, both.booleanValue());
                onSuccess(result);
            }catch(HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void removeUserToBlackList(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            try{
                manager.removeUserFromBlackList(userName);
                onSuccess(result);
            }catch(HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getBlackListFromServer(Object args, Result result) {
        try{
            List<String> contacts = manager.getBlackListFromServer();
            Map<String,Object> data = new HashMap<String, Object>();
            data.put("black_list", contacts);
            result.success(data);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }

    private void saveBlackList(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            JSONArray json_contacts = argMap.getJSONArray("blackList");
            List<String> contacts = new ArrayList<>();
            for(int i = 0; i < json_contacts.length(); i++){
                contacts.add(json_contacts.getString(i));
            }
            try{
                manager.saveBlackList(contacts);
                onSuccess(result);
            }catch(HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void acceptInvitation(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            try{
                manager.acceptInvitation(userName);
                onSuccess(result);
            }catch(HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void declineInvitation(Object args, Result result) {
        try {
            JSONObject argMap = (JSONObject) args;
            String userName = argMap.getString("userName");
            try{
                manager.declineInvitation(userName);
                onSuccess(result);
            }catch(HyphenateException e) {
                onError(result, e);
            }
        }catch (JSONException e){
            EMLog.e("JSONException", e.getMessage());
        }
    }

    private void getSelfIdsOnOtherPlatform(Object args, Result result) {
        try{
            List<String> ids = manager.getSelfIdsOnOtherPlatform();
            Map<String,Object> data = new HashMap<String, Object>();
            data.put("ids", ids);
            result.success(data);
        }catch(HyphenateException e) {
            onError(result, e);
        }
    }
}
