package com.easemob.im_flutter_sdk;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.hyphenate.EMContactListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMContact;
import com.hyphenate.chat.EMCursorResult;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class ContactManagerWrapper extends Wrapper implements MethodCallHandler {

    private EMContactListener contactListener;

    ContactManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        JSONObject param = (JSONObject) call.arguments;
        try {
            if (MethodKey.addContact.equals(call.method)) {
                addContact(param, call.method, result);
            } else if (MethodKey.deleteContact.equals(call.method)) {
                deleteContact(param, call.method, result);
            } else if (MethodKey.getAllContactsFromServer.equals(call.method)) {
                getAllContactsFromServer(param, call.method, result);
            } else if (MethodKey.getAllContactsFromDB.equals(call.method)) {
                getAllContactsFromDB(param, call.method, result);
            } else if (MethodKey.addUserToBlockList.equals(call.method)) {
                addUserToBlockList(param, call.method, result);
            } else if (MethodKey.removeUserFromBlockList.equals(call.method)) {
                removeUserFromBlockList(param, call.method, result);
            } else if (MethodKey.getBlockListFromServer.equals(call.method)) {
                getBlockListFromServer(param, call.method, result);
            } else if (MethodKey.getBlockListFromDB.equals(call.method)) {
                getBlockListFromDB(param, call.method, result);
            } else if (MethodKey.acceptInvitation.equals(call.method)) {
                acceptInvitation(param, call.method, result);
            } else if (MethodKey.declineInvitation.equals(call.method)) {
                declineInvitation(param, call.method, result);
            } else if (MethodKey.getSelfIdsOnOtherPlatform.equals(call.method)) {
                getSelfIdsOnOtherPlatform(param, call.method, result);
            }else if (MethodKey.getAllContacts.equals(call.method)) {
                getAllContacts(param, call.method, result);
            }else if (MethodKey.setContactRemark.equals(call.method)) {
                setContactRemark(param, call.method, result);
            }else if (MethodKey.getContact.equals(call.method)) {
                getContact(param, call.method, result);
            }else if (MethodKey.fetchAllContacts.equals(call.method)) {
                fetchAllContacts(param, call.method, result);
            }else if (MethodKey.fetchContacts.equals(call.method)) {
                fetchContacts(param, call.method, result);
            }
            else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void addContact(JSONObject param, String channelName, Result result) throws JSONException {
        String username = param.getString("username");
        String reason = null;
        if(param.has("reason")) {
            reason = param.getString("reason");
        }
        String finalReason = reason;
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().contactManager().addContact(username, finalReason);
                onSuccess(result, channelName, username);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void deleteContact(JSONObject param, String channelName, Result result) throws JSONException {
        String username = param.getString("username");
        boolean keepConversation = param.getBoolean("keepConversation");
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().contactManager().deleteContact(username, keepConversation);
                onSuccess(result, channelName, username);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getAllContactsFromServer(JSONObject params, String channelName, Result result) throws JSONException {
        asyncRunnable(() -> {
            try {
                List contacts = EMClient.getInstance().contactManager().getAllContactsFromServer();
                onSuccess(result, channelName, contacts);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getAllContactsFromDB(JSONObject params, String channelName, Result result) throws JSONException {
        asyncRunnable(() -> {
            try {
                List contacts = EMClient.getInstance().contactManager().getContactsFromLocal();
                onSuccess(result, channelName, contacts);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void addUserToBlockList(JSONObject params, String channelName, Result result) throws JSONException {
        String username = params.getString("username");
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().contactManager().addUserToBlackList(username, false);
                onSuccess(result, channelName, username);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void removeUserFromBlockList(JSONObject params, String channelName, Result result) throws JSONException {
        String username = params.getString("username");
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().contactManager().removeUserFromBlackList(username);
                onSuccess(result, channelName, username);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getBlockListFromServer(JSONObject params, String channelName, Result result) throws JSONException {
        asyncRunnable(() -> {
            try {
                List contacts = EMClient.getInstance().contactManager().getBlackListFromServer();
                onSuccess(result, channelName, contacts);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getBlockListFromDB(JSONObject params, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            List contacts = EMClient.getInstance().contactManager().getBlackListUsernames();
            onSuccess(result, channelName, contacts);
        });
    }

    private void acceptInvitation(JSONObject params, String channelName, Result result) throws JSONException {
        String username = params.getString("username");
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().contactManager().acceptInvitation(username);
                onSuccess(result, channelName, username);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void declineInvitation(JSONObject params, String channelName, Result result) throws JSONException {
        String username = params.getString("username");
        asyncRunnable(() -> {
            try {
                EMClient.getInstance().contactManager().declineInvitation(username);
                onSuccess(result, channelName, username);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getSelfIdsOnOtherPlatform(JSONObject params, String channelName, Result result) throws JSONException {
        asyncRunnable(() -> {
            try {
                List platforms = EMClient.getInstance().contactManager().getSelfIdsOnOtherPlatform();
                onSuccess(result, channelName, platforms);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getAllContacts(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().contactManager().asyncFetchAllContactsFromLocal(new EMValueWrapperCallBack<List<EMContact>>(result, channelName) {
            @Override
            public void onSuccess(List<EMContact> list){
                List<Map> contactList = new ArrayList<>();
                for (EMContact contact : list) {
                    contactList.add(ContactHelper.toJson(contact));
                }
                updateObject(contactList);
            }
        });
    }

    private void setContactRemark(JSONObject params, String channelName, Result result) throws JSONException {
        String userId = params.optString("userId");
        String remark = params.optString("remark");
        EMClient.getInstance().contactManager().asyncSetContactRemark(userId, remark, new EMWrapperCallBack(result, channelName, null));
    }

    private void getContact(JSONObject params, String channelName, Result result) throws JSONException {
        String userId = params.optString("userId");
        asyncRunnable(() -> {
            try {
                EMContact contact = EMClient.getInstance().contactManager().fetchContactFromLocal(userId);
                if (contact != null) {
                    onSuccess(result, channelName, ContactHelper.toJson(contact));
                }else {
                    onSuccess(result, channelName, null);
                }
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void fetchAllContacts(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().contactManager().asyncFetchAllContactsFromServer(new EMValueWrapperCallBack<List<EMContact>>(result, channelName) {
            @Override
            public void onSuccess(List<EMContact> list){
                List<Map> contactList = new ArrayList<>();
                for (EMContact contact : list) {
                    contactList.add(ContactHelper.toJson(contact));
                }
                updateObject(contactList);
            }
        });
    }

    private void fetchContacts(JSONObject params, String channelName, Result result) throws JSONException {
        int pageSize = params.getInt("pageSize");
        String cursor = null;
        if (params.has("cursor")) {
            cursor = params.getString("cursor");
        }

        EMClient.getInstance().contactManager().asyncFetchAllContactsFromServer(pageSize, cursor, new EMValueWrapperCallBack<EMCursorResult<EMContact>>(result, channelName){
            @Override
            public void onSuccess(EMCursorResult<EMContact> object) {
                super.updateObject(CursorResultHelper.toJson(object));
            }
        });
    }


    private void registerEaseListener() {

        if (contactListener != null) {
            EMClient.getInstance().contactManager().removeContactListener(contactListener);
        }

        contactListener = new EMContactListener() {
            @Override
            public void onContactAdded(String userName) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onContactAdded");
                            data.put("username", userName);
                            post(() -> channel.invokeMethod(MethodKey.onContactChanged, data));
                        }
                );
            }

            @Override
            public void onContactDeleted(String userName) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onContactDeleted");
                            data.put("username", userName);
                            post(() -> channel.invokeMethod(MethodKey.onContactChanged, data));
                        }
                );
            }

            @Override
            public void onContactInvited(String userName, String reason) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onContactInvited");
                            data.put("username", userName);
                            data.put("reason", reason);
                            post(() -> channel.invokeMethod(MethodKey.onContactChanged, data));
                        }
                );
            }

            @Override
            public void onFriendRequestAccepted(String userName) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onFriendRequestAccepted");
                            data.put("username", userName);
                            post(() -> channel.invokeMethod(MethodKey.onContactChanged, data));
                        }
                );
            }

            @Override
            public void onFriendRequestDeclined(String userName) {
                ListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onFriendRequestDeclined");
                            data.put("username", userName);
                            post(() -> channel.invokeMethod(MethodKey.onContactChanged, data));
                        }
                );
            }
        };

        EMClient.getInstance().contactManager().setContactListener(contactListener);
    }

    @Override
    public void unRegisterEaseListener() {
        EMClient.getInstance().contactManager().removeContactListener(contactListener);
    }
}
