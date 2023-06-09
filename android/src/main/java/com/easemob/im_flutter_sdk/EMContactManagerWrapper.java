package com.easemob.im_flutter_sdk;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.hyphenate.EMContactListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class EMContactManagerWrapper extends EMWrapper implements MethodCallHandler {

    private EMContactListener contactListener;

    EMContactManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerEaseListener();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.addContact.equals(call.method)) {
                addContact(param, call.method, result);
            } else if (EMSDKMethod.deleteContact.equals(call.method)) {
                deleteContact(param, call.method, result);
            } else if (EMSDKMethod.getAllContactsFromServer.equals(call.method)) {
                getAllContactsFromServer(param, call.method, result);
            } else if (EMSDKMethod.getAllContactsFromDB.equals(call.method)) {
                getAllContactsFromDB(param, call.method, result);
            } else if (EMSDKMethod.addUserToBlockList.equals(call.method)) {
                addUserToBlockList(param, call.method, result);
            } else if (EMSDKMethod.removeUserFromBlockList.equals(call.method)) {
                removeUserFromBlockList(param, call.method, result);
            } else if (EMSDKMethod.getBlockListFromServer.equals(call.method)) {
                getBlockListFromServer(param, call.method, result);
            } else if (EMSDKMethod.getBlockListFromDB.equals(call.method)) {
                getBlockListFromDB(param, call.method, result);
            } else if (EMSDKMethod.acceptInvitation.equals(call.method)) {
                acceptInvitation(param, call.method, result);
            } else if (EMSDKMethod.declineInvitation.equals(call.method)) {
                declineInvitation(param, call.method, result);
            } else if (EMSDKMethod.getSelfIdsOnOtherPlatform.equals(call.method)) {
                getSelfIdsOnOtherPlatform(param, call.method, result);
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


    private void registerEaseListener() {

        if (contactListener != null) {
            EMClient.getInstance().contactManager().removeContactListener(contactListener);
        }

        contactListener = new EMContactListener() {
            @Override
            public void onContactAdded(String userName) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onContactAdded");
                            data.put("username", userName);
                            post(() -> channel.invokeMethod(EMSDKMethod.onContactChanged, data));
                        }
                );
            }

            @Override
            public void onContactDeleted(String userName) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onContactDeleted");
                            data.put("username", userName);
                            post(() -> channel.invokeMethod(EMSDKMethod.onContactChanged, data));
                        }
                );
            }

            @Override
            public void onContactInvited(String userName, String reason) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onContactInvited");
                            data.put("username", userName);
                            data.put("reason", reason);
                            post(() -> channel.invokeMethod(EMSDKMethod.onContactChanged, data));
                        }
                );
            }

            @Override
            public void onFriendRequestAccepted(String userName) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onFriendRequestAccepted");
                            data.put("username", userName);
                            post(() -> channel.invokeMethod(EMSDKMethod.onContactChanged, data));
                        }
                );
            }

            @Override
            public void onFriendRequestDeclined(String userName) {
                EMListenerHandle.getInstance().addHandle(
                        ()-> {
                            Map<String, Object> data = new HashMap<>();
                            data.put("type", "onFriendRequestDeclined");
                            data.put("username", userName);
                            post(() -> channel.invokeMethod(EMSDKMethod.onContactChanged, data));
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
