package com.easemob.im_flutter_sdk;

import java.util.ArrayList;

import java.util.Map;
import java.util.HashMap;
import java.util.List;


import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMLoginExtensionInfo;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.exceptions.HyphenateException;


import org.json.JSONException;
import org.json.JSONObject;


public class EMClientWrapper extends EMWrapper implements MethodCallHandler {

    private EMChatManagerWrapper chatManagerWrapper;
    private EMGroupManagerWrapper groupManagerWrapper;
    private EMChatRoomManagerWrapper chatRoomManagerWrapper;
    private EMPushManagerWrapper pushManagerWrapper;
    private EMPresenceManagerWrapper presenceManagerWrapper;
    private EMChatThreadManagerWrapper chatThreadManagerWrapper;
    private EMContactManagerWrapper contactManagerWrapper;
    private EMUserInfoManagerWrapper userInfoManagerWrapper;
    private EMConversationWrapper conversationWrapper;
    private EMMessageWrapper messageWrapper;
    public EMProgressManager progressManager;
    private EMMultiDeviceListener multiDeviceListener;
    private EMConnectionListener connectionListener;

    private EMOptions options;

    EMClientWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
    }

    public void sendDataToFlutter(final Map data) {
        if (data == null) {
            return;
        }
        post(()-> channel.invokeMethod(EMSDKMethod.onSendDataToFlutter, data));
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {

        JSONObject param = (JSONObject)call.arguments;
        try {
            if (EMSDKMethod.init.equals(call.method)) {
                init(param, call.method, result);
            }
            else if (EMSDKMethod.createAccount.equals(call.method))
            {
                createAccount(param, call.method, result);
            }
            else if (EMSDKMethod.login.equals(call.method))
            {
                login(param, call.method, result);
            }
            else if (EMSDKMethod.logout.equals(call.method))
            {
                logout(param, call.method, result);
            }
            else if (EMSDKMethod.changeAppKey.equals(call.method))
            {
                changeAppKey(param, call.method, result);
            }
            else if (EMSDKMethod.uploadLog.equals(call.method))
            {
                uploadLog(param, call.method, result);
            }
            else if (EMSDKMethod.compressLogs.equals(call.method))
            {
                compressLogs(param, call.method, result);
            }
            else if (EMSDKMethod.getLoggedInDevicesFromServer.equals(call.method))
            {
                getLoggedInDevicesFromServer(param, call.method, result);
            }
            else if (EMSDKMethod.kickDevice.equals(call.method))
            {
                kickDevice(param, call.method, result);
            }
            else if (EMSDKMethod.kickAllDevices.equals(call.method))
            {
                kickAllDevices(param, call.method, result);
            }
            else if (EMSDKMethod.isLoggedInBefore.equals(call.method))
            {
                isLoggedInBefore(param, call.method, result);
            }
            else if (EMSDKMethod.getCurrentUser.equals(call.method))
            {
                getCurrentUser(param, call.method, result);
            }
            else if (EMSDKMethod.loginWithAgoraToken.equals(call.method))
            {
                loginWithAgoraToken(param, EMSDKMethod.loginWithAgoraToken, result);
            }
            else if (EMSDKMethod.getToken.equals(call.method))
            {
                getToken(param, call.method, result);
            }
            else if (EMSDKMethod.isConnected.equals(call.method)) {
                isConnected(param, call.method, result);
            }
            else if (EMSDKMethod.renewToken.equals(call.method)){
                renewToken(param, call.method, result);
            } else if (EMSDKMethod.startCallback.equals(call.method)) {
                startCallback(param, call.method, result);
            }
            // 481
            else if (EMSDKMethod.updateUsingHttpsOnlySetting.equals(call.method)) {
                updateUsingHttpsOnlySetting(param, call.method, result);
            }
            else if (EMSDKMethod.updateLoginExtensionInfo.equals(call.method)) {
                updateLoginExtensionInfo(param, call.method, result);
            }
            else if (EMSDKMethod.updateDeleteMessagesWhenLeaveGroupSetting.equals(call.method)) {
                updateDeleteMessagesWhenLeaveGroupSetting(param, call.method, result);
            }
            else if (EMSDKMethod.updateDeleteMessageWhenLeaveRoomSetting.equals(call.method)) {
                updateDeleteMessageWhenLeaveRoomSetting(param, call.method, result);
            }
            else if (EMSDKMethod.updateRoomOwnerCanLeaveSetting.equals(call.method)) {
                updateRoomOwnerCanLeaveSetting(param, call.method, result);
            }
            else if (EMSDKMethod.updateAutoAcceptGroupInvitationSetting.equals(call.method)) {
                updateAutoAcceptGroupInvitationSetting(param, call.method, result);
            }
            else if (EMSDKMethod.acceptInvitationAlways.equals(call.method)) {
                acceptInvitationAlways(param, call.method, result);
            }
            else if (EMSDKMethod.updateAutoDownloadAttachmentThumbnailSetting.equals(call.method)) {
                updateAutoDownloadAttachmentThumbnailSetting(param, call.method, result);
            }
            else if (EMSDKMethod.updateRequireAckSetting.equals(call.method)) {
                updateRequireAckSetting(param, call.method, result);
            }
            else if (EMSDKMethod.updateDeliveryAckSetting.equals(call.method)) {
                updateDeliveryAckSetting(param, call.method, result);
            }
            else if (EMSDKMethod.updateSortMessageByServerTimeSetting.equals(call.method)) {
                updateSortMessageByServerTimeSetting(param, call.method, result);
            }
            else if (EMSDKMethod.updateMessagesReceiveCallbackIncludeSendSetting.equals(call.method)) {
                updateMessagesReceiveCallbackIncludeSendSetting(param, call.method, result);
            }
            else if (EMSDKMethod.updateRegradeMessagesSetting.equals(call.method)) {
                updateRegradeMessagesSetting(param, call.method, result);
            }
            else  {
                super.onMethodCall(call, result);
            }

        }catch (JSONException ignored) {

        }
    }


    private void createAccount(JSONObject param, String channelName, Result result) throws JSONException {
        String username = param.getString("username");
        String password = param.getString("password");
        asyncRunnable(()->{
            try {
                EMClient.getInstance().createAccount(username, password);
                onSuccess(result, channelName, username);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void login(JSONObject param, String channelName, Result result) throws JSONException {
        boolean isPwd = param.getBoolean("isPassword");
        String username = param.getString("username");
        String pwdOrToken = param.getString("pwdOrToken");
        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    object = EMClient.getInstance().getCurrentUser();
                    super.onSuccess();
                });
            }
        };

        if (isPwd){
            EMClient.getInstance().login(username, pwdOrToken, callBack);
        } else {
            EMClient.getInstance().loginWithToken(username, pwdOrToken, callBack);
        }
    }


    private void logout(JSONObject param, String channelName, Result result) throws JSONException {
        boolean unbindToken = param.getBoolean("unbindToken");
        EMClient.getInstance().logout(unbindToken, new EMWrapperCallBack(result, channelName, null){
            @Override
            public void onSuccess() {
                EMListenerHandle.getInstance().clearHandle();
                object = true;
                super.onSuccess();
            }
        });
    }

    private void changeAppKey(JSONObject param, String channelName, Result result) throws JSONException{
        String appKey = param.getString("appKey");
        asyncRunnable(()-> {
            try {
                EMClient.getInstance().changeAppkey(appKey);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getCurrentUser(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()-> onSuccess(result, channelName, EMClient.getInstance().getCurrentUser()));
    }

    private void loginWithAgoraToken(JSONObject param, String channelName, Result result) throws JSONException {

        String username = param.getString("username");
        String agoraToken = param.getString("agora_token");
        EMWrapperCallBack callBack = new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    object = EMClient.getInstance().getCurrentUser();
                    super.onSuccess();
                });
            }
        };

        EMClient.getInstance().loginWithAgoraToken(username, agoraToken, callBack);
    }
    private void getToken(JSONObject param, String channelName, Result result) throws JSONException
    {
        asyncRunnable(()-> onSuccess(result, channelName, EMClient.getInstance().getAccessToken()));
    }

    private void isLoggedInBefore(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            EMOptions emOptions = EMClient.getInstance().getOptions();
            onSuccess(result, channelName, EMClient.getInstance().isLoggedInBefore() && emOptions.getAutoLogin());
        });
    }

    private void isConnected(JSONObject param, String channelName, Result result) throws JSONException{
        asyncRunnable(()-> onSuccess(result, channelName, EMClient.getInstance().isConnected()));
    }

    private void uploadLog(JSONObject param, String channelName, Result result) throws JSONException {
        EMClient.getInstance().uploadLog(new EMWrapperCallBack(result, channelName, true));
    }

    private void compressLogs(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            try {
                String path = EMClient.getInstance().compressLogs();
                onSuccess(result, channelName, path);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void kickDevice(JSONObject param, String channelName, Result result) throws JSONException {

        String username = param.getString("username");
        String password = param.getString("password");
        String resource = param.getString("resource");
        boolean isPwd = param.optBoolean("isPwd");
        if (isPwd) {
            asyncRunnable(()->{
                try {
                    EMClient.getInstance().kickDevice(username, password, resource);
                    onSuccess(result, channelName, true);
                } catch (HyphenateException e) {
                    onError(result, e);
                }
            });
        }else {
            asyncRunnable(()->{
                try {
                    EMClient.getInstance().kickDeviceWithToken(username, password, resource);
                    onSuccess(result, channelName, true);
                } catch (HyphenateException e) {
                    onError(result, e);
                }
            });
        }
    }

    private void kickAllDevices(JSONObject param, String channelName, Result result) throws JSONException {
        String username = param.getString("username");
        String password = param.getString("password");
        boolean isPwd = param.optBoolean("isPwd");
        if (isPwd) {
            asyncRunnable(()->{
                try {
                    EMClient.getInstance().kickAllDevices(username, password);
                    onSuccess(result, channelName, true);
                } catch (HyphenateException e) {
                    onError(result, e);
                }
            });
        }else {
            asyncRunnable(()->{
                try {
                    EMClient.getInstance().kickAllDevicesWithToken(username, password);
                    onSuccess(result, channelName, true);
                } catch (HyphenateException e) {
                    onError(result, e);
                }
            });
        }
    }

    private void init(JSONObject param, String channelName, Result result) throws JSONException {
        if (options != null) {
            onSuccess(result, channelName, null);
            return;
        }
        options = EMOptionsHelper.fromJson(param, this.context);
        EMClient.getInstance().init(this.context, options);
        EMClient.getInstance().setDebugMode(param.getBoolean("debugModel"));

        bindingManagers();
        registerEaseListener();

        onSuccess(result, channelName, null);

    }

    private void renewToken(JSONObject param, String channelName, Result result) throws JSONException {
        String agoraToken = param.getString("agora_token");
        EMClient.getInstance().renewToken(agoraToken, new EMWrapperCallBack(result, channelName,null));
    }

    private void getLoggedInDevicesFromServer(JSONObject param, String channelName, Result result) throws JSONException {
        String username = param.getString("username");
        String password = param.getString("password");
        boolean isPwd = param.optBoolean("isPwd");
        if (isPwd) {
            asyncRunnable(()->{
                try {
                    List<EMDeviceInfo> devices = EMClient.getInstance().getLoggedInDevicesFromServer(username, password);
                    List<Map> jsonList = new ArrayList <>();
                    for (EMDeviceInfo info: devices) {
                        jsonList.add(EMDeviceInfoHelper.toJson(info));
                    }
                    onSuccess(result, channelName, jsonList);
                } catch (HyphenateException e) {
                    onError(result, e);
                }
            });
        }else {
            asyncRunnable(()->{
                try {
                    List<EMDeviceInfo> devices = EMClient.getInstance().getLoggedInDevicesFromServerWithToken(username, password);
                    List<Map> jsonList = new ArrayList <>();
                    for (EMDeviceInfo info: devices) {
                        jsonList.add(EMDeviceInfoHelper.toJson(info));
                    }
                    onSuccess(result, channelName, jsonList);
                } catch (HyphenateException e) {
                    onError(result, e);
                }
            });
        }
    }

    private void startCallback(JSONObject param, String channelName, Result result) {
        EMListenerHandle.getInstance().startCallback();
        onSuccess(result, channelName, null);
    }

    private void bindingManagers() {
        chatManagerWrapper = new EMChatManagerWrapper(binging, "chat_manager");
        contactManagerWrapper = new EMContactManagerWrapper(binging, "chat_contact_manager");
        chatRoomManagerWrapper = new EMChatRoomManagerWrapper(binging, "chat_room_manager");
        groupManagerWrapper = new EMGroupManagerWrapper(binging, "chat_group_manager");
        groupManagerWrapper.clientWrapper = this;
        conversationWrapper = new EMConversationWrapper(binging, "chat_conversation");
        pushManagerWrapper = new EMPushManagerWrapper(binging, "chat_push_manager");
        userInfoManagerWrapper = new EMUserInfoManagerWrapper(binging, "chat_userInfo_manager");
        presenceManagerWrapper = new EMPresenceManagerWrapper(binging, "chat_presence_manager");
        messageWrapper = new EMMessageWrapper(binging, "chat_message");
        chatThreadManagerWrapper = new EMChatThreadManagerWrapper(binging, "chat_thread_manager");
        progressManager = new EMProgressManager(binging, "file_progress_manager");
    }

    private void clearAllListener() {
        if (chatManagerWrapper != null) chatManagerWrapper.unRegisterEaseListener();
        if (contactManagerWrapper != null) contactManagerWrapper.unRegisterEaseListener();
        if (chatRoomManagerWrapper != null) chatRoomManagerWrapper.unRegisterEaseListener();
        if (groupManagerWrapper != null) groupManagerWrapper.unRegisterEaseListener();
        if (conversationWrapper != null) conversationWrapper.unRegisterEaseListener();
        if (pushManagerWrapper != null) pushManagerWrapper.unRegisterEaseListener();
        if (userInfoManagerWrapper != null) userInfoManagerWrapper.unRegisterEaseListener();
        if (presenceManagerWrapper != null) presenceManagerWrapper.unRegisterEaseListener();
        if (messageWrapper != null) messageWrapper.unRegisterEaseListener();
        if (chatThreadManagerWrapper != null) chatThreadManagerWrapper.unRegisterEaseListener();
        if (progressManager != null) progressManager.unRegisterEaseListener();
    }

    @Override
    public void unRegisterEaseListener() {
        EMClient.getInstance().removeConnectionListener(connectionListener);
        EMClient.getInstance().removeMultiDeviceListener(multiDeviceListener);
        clearAllListener();
    }


    private void registerEaseListener() {

        if (multiDeviceListener != null) {
            EMClient.getInstance().removeMultiDeviceListener(multiDeviceListener);
        }


        multiDeviceListener = new EMMultiDeviceListener() {
            @Override
            public void onContactEvent(int event, String target, String ext) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", event);
                data.put("target", target);
                data.put("ext", ext);
                post(()-> channel.invokeMethod(EMSDKMethod.onMultiDeviceContactEvent, data));
            }

            @Override
            public void onGroupEvent(int event, String target, List<String> userNames) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", event);
                data.put("target", target);
                data.put("users", userNames);
                post(()-> channel.invokeMethod(EMSDKMethod.onMultiDeviceGroupEvent, data));
            }

            public void onChatThreadEvent(int event, String target, List<String> usernames) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", event);
                data.put("target", target);
                data.put("users", usernames);
                post(()-> channel.invokeMethod(EMSDKMethod.onMultiDeviceThreadEvent, data));
            }

            @Override
            public void onMessageRemoved(String conversationId, String deviceId) {
                Map<String, Object> data = new HashMap<>();
                data.put("convId", conversationId);
                data.put("deviceId", deviceId);
                post(()-> channel.invokeMethod(EMSDKMethod.onMultiDeviceRemoveMessagesEvent, data));
            }

            @Override
            public void onConversationEvent(int event, String conversationId, EMConversation.EMConversationType type) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", event);
                data.put("convId", conversationId);
                data.put("convType", EnumTools.conversationTypeToInt(type));
                post(()-> channel.invokeMethod(EMSDKMethod.onMultiDevicesConversationEvent, data));
            }
        };

        if (connectionListener != null) {
            EMClient.getInstance().removeConnectionListener(connectionListener);
        }

        connectionListener = new EMConnectionListener() {
            @Override
            public void onConnected() {
                Map<String, Object> data = new HashMap<>();
                data.put("connected", Boolean.TRUE);
                post(()-> channel.invokeMethod(EMSDKMethod.onConnected, data));
            }

            @Override
            public void onDisconnected(int errorCode) {
                if (errorCode == 206) {
                    // 这部分实现放到onLogout中。
//                    EMListenerHandle.getInstance().clearHandle();
//                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidLoginFromOtherDevice, null));
                }else if (errorCode == 207) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidRemoveFromServer, null));
                }else if (errorCode == 305) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidForbidByServer, null));
                }else if (errorCode == 216) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidChangePassword, null));
                }else if (errorCode == 214) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidLoginTooManyDevice, null));
                }
                else if (errorCode == 217) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserKickedByOtherDevice, null));
                }
                else if (errorCode == 202) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserAuthenticationFailed, null));
                }
                else if (errorCode == 8) {
                    post(() -> channel.invokeMethod(EMSDKMethod.onAppActiveNumberReachLimit, null));
                }
                else {
                    post(() -> channel.invokeMethod(EMSDKMethod.onDisconnected, null));
                }
            }

            @Override
            public void onTokenExpired() {
                post(()-> channel.invokeMethod(EMSDKMethod.onTokenDidExpire, null));
            }

            @Override
            public void onTokenWillExpire() {
                post(()-> channel.invokeMethod(EMSDKMethod.onTokenWillExpire, null));
            }

            @Override
            public void onLogout(int errorCode, EMLoginExtensionInfo info) {
                if (errorCode == 206) {
                    EMListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidLoginFromOtherDevice, EMLoginExtensionInfoHelper.toJson(info)));
                }
            }
            @Override
            public void onOfflineMessageSyncStart() {
                post(()-> channel.invokeMethod(EMSDKMethod.onOfflineMessageSyncStart, null));
            }
            @Override
            public void onOfflineMessageSyncFinish() {
                post(()-> channel.invokeMethod(EMSDKMethod.onOfflineMessageSyncFinish, null));
            }

        };

        EMClient.getInstance().addConnectionListener(connectionListener);
        EMClient.getInstance().addMultiDeviceListener(multiDeviceListener);
    }

    // 481
    private void updateUsingHttpsOnlySetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean usingHttpsOnly = param.getBoolean("usingHttpsOnly");
        EMClient.getInstance().getOptions().setUsingHttpsOnly(usingHttpsOnly);
        asyncRunnable(()->onSuccess(result, channelName, null));
    }
    private void updateLoginExtensionInfo(JSONObject param, String channelName, Result result) throws JSONException {
        String extension = param.optString("extension");
        EMClient.getInstance().getOptions().setLoginCustomExt(extension);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }
    private void updateDeleteMessagesWhenLeaveGroupSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean deleteMessagesWhenLeaveGroup = param.getBoolean("deleteMessagesWhenLeaveGroup");
        EMClient.getInstance().getOptions().setDeleteMessagesAsExitGroup(deleteMessagesWhenLeaveGroup);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }
    private void updateDeleteMessageWhenLeaveRoomSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean deleteMessageWhenLeaveRoom = param.getBoolean("deleteMessageWhenLeaveRoom");
        EMClient.getInstance().getOptions().setDeleteMessagesAsExitChatRoom(deleteMessageWhenLeaveRoom);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }
    private void updateRoomOwnerCanLeaveSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean roomOwnerCanLeave = param.getBoolean("roomOwnerCanLeave");
        EMClient.getInstance().getOptions().allowChatroomOwnerLeave(roomOwnerCanLeave);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }
    private void updateAutoAcceptGroupInvitationSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean autoAcceptGroupInvitation = param.getBoolean("autoAcceptGroupInvitation");
        EMClient.getInstance().getOptions().setAutoAcceptGroupInvitation(autoAcceptGroupInvitation);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }
    private void acceptInvitationAlways(JSONObject param, String channelName, Result result) throws JSONException {
        boolean acceptInvitationAlways = param.getBoolean("acceptInvitationAlways");
        EMClient.getInstance().getOptions().setAutoAcceptGroupInvitation(acceptInvitationAlways);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }

    private void updateAutoDownloadAttachmentThumbnailSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean autoDownloadThumbnail = param.getBoolean("autoDownloadThumbnail");
        EMClient.getInstance().getOptions().setAutoDownloadThumbnail(autoDownloadThumbnail);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }
    private void updateRequireAckSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean requireAck = param.getBoolean("requireAck");
        EMClient.getInstance().getOptions().setRequireAck(requireAck);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }
    private void updateDeliveryAckSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean requireDeliveryAck = param.getBoolean("requireDeliveryAck");
        EMClient.getInstance().getOptions().setRequireDeliveryAck(requireDeliveryAck);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }
    private void updateSortMessageByServerTimeSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean sortMessageByServerTime = param.getBoolean("sortMessageByServerTime");
        EMClient.getInstance().getOptions().setSortMessageByServerTime(sortMessageByServerTime);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }
    private void updateMessagesReceiveCallbackIncludeSendSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean includeSend = param.getBoolean("includeSend");
        EMClient.getInstance().getOptions().setIncludeSendMessageInMessageListener(includeSend);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }

    private void updateRegradeMessagesSetting(JSONObject param, String channelName, Result result) throws JSONException {
        boolean isRead = param.getBoolean("isRead");
        EMClient.getInstance().getOptions().setRegardImportedMsgAsRead(isRead);
        asyncRunnable(()-> onSuccess(result, channelName, null));
    }

}

