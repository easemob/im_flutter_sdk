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

import android.content.Context;

import com.hyphenate.EMConnectionListener;
import com.hyphenate.EMMultiDeviceListener;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMRTCTokenInfo;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMLoginExtensionInfo;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMDeviceInfo;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.DeviceUuidFactory;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class ClientWrapper extends Wrapper implements MethodCallHandler {

    private ChatManagerWrapper chatManagerWrapper;
    private GroupManagerWrapper groupManagerWrapper;
    private ChatRoomManagerWrapper chatRoomManagerWrapper;
    private PushManagerWrapper pushManagerWrapper;
    private PresenceManagerWrapper presenceManagerWrapper;
    private UserInfoManagerWrapper userInfoManagerWrapper;
    private ChatThreadManagerWrapper chatThreadManagerWrapper;
    private ContactManagerWrapper contactManagerWrapper;
    private ConversationWrapper conversationWrapper;
    private MessageWrapper messageWrapper;
    public ProgressManager progressManager;
    private EMMultiDeviceListener multiDeviceListener;
    private EMConnectionListener connectionListener;

    private EMOptions options;

    ClientWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerAll();
        applyVersionOverrides();
    }

    public void sendDataToFlutter(final Map data) {
        if (data == null) {
            return;
        }
        post(()-> channel.invokeMethod(MethodKey.onSendDataToFlutter, data));
    }

    @Override
    protected void registerAll() {
        register(MethodKey.init, this::init);
        register(MethodKey.login, this::login);
        register(MethodKey.logout, this::logout);
        register(MethodKey.changeAppKey, this::changeAppKey);
        register(MethodKey.uploadLog, this::uploadLog);
        register(MethodKey.compressLogs, this::compressLogs);
        register(MethodKey.getLoggedInDevicesFromServer, this::getLoggedInDevicesFromServer);
        register(MethodKey.kickDevice, this::kickDevice);
        register(MethodKey.kickAllDevices, this::kickAllDevices);
        register(MethodKey.isLoggedInBefore, this::isLoggedInBefore);
        register(MethodKey.getCurrentUser, this::getCurrentUser);
        register(MethodKey.getToken, this::getToken);
        register(MethodKey.getCurrentDeviceId, this::getCurrentDeviceId);
        register(MethodKey.isConnected, this::isConnected);
        register(MethodKey.renewToken, this::renewToken);
        register(MethodKey.startCallback, this::startCallback);
        register(MethodKey.updateUsingHttpsOnlySetting, this::updateUsingHttpsOnlySetting);
        register(MethodKey.updateLoginExtensionInfo, this::updateLoginExtensionInfo);
        register(MethodKey.updateDeleteMessagesWhenLeaveGroupSetting, this::updateDeleteMessagesWhenLeaveGroupSetting);
        register(MethodKey.updateDeleteMessageWhenLeaveRoomSetting, this::updateDeleteMessageWhenLeaveRoomSetting);
        register(MethodKey.updateRoomOwnerCanLeaveSetting, this::updateRoomOwnerCanLeaveSetting);
        register(MethodKey.updateAutoAcceptGroupInvitationSetting, this::updateAutoAcceptGroupInvitationSetting);
        register(MethodKey.acceptInvitationAlways, this::acceptInvitationAlways);
        register(MethodKey.updateAutoDownloadAttachmentThumbnailSetting, this::updateAutoDownloadAttachmentThumbnailSetting);
        register(MethodKey.updateDeliveryAckSetting, this::updateDeliveryAckSetting);
        register(MethodKey.updateSortMessageByServerTimeSetting, this::updateSortMessageByServerTimeSetting);
        register(MethodKey.updateMessagesReceiveCallbackIncludeSendSetting, this::updateMessagesReceiveCallbackIncludeSendSetting);
        register(MethodKey.updateRegradeMessagesSetting, this::updateRegradeMessagesSetting);
        register(MethodKey.changeAppId, this::changeAppId);
        register(MethodKey.notifyTokenExpired, this::notifyTokenExpired);
        register(MethodKey.sendFCMTokenToServer, this::sendFCMTokenToServer);
        register(MethodKey.sendHonorPushTokenToServer, this::sendHonorPushTokenToServer);
        register(MethodKey.getRTCTokenInfoWithChannelName, this::getRTCTokenInfoWithChannelName);
        register(MethodKey.getUserIdsWithRTCUids, this::getUserIdsWithRTCUids);
    }




    private void login(JSONObject param, String channelName, Result result) throws JSONException {
        String username = param.getString("userId");
        String pwdOrToken = param.has("pwdOrToken")
                ? param.getString("pwdOrToken")
                : param.getString("password");
        // 5.0 统一 token 登录
        EMClient.getInstance().loginWithToken(username, pwdOrToken, new EMWrapperCallBack(result, channelName, null) {
            @Override
            public void onSuccess() {
                post(() -> {
                    object = EMClient.getInstance().getCurrentUser();
                    super.onSuccess();
                });
            }
        });
    }


    private void logout(JSONObject param, String channelName, Result result) throws JSONException {
        boolean unbindToken = param.optBoolean("unbindToken", false);
        EMClient.getInstance().logout(unbindToken, new EMWrapperCallBack(result, channelName, null){
            @Override
            public void onSuccess() {
                ListenerHandle.getInstance().clearHandle();
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
        post(() -> {
            try {
                String user = EMClient.getInstance().getCurrentUser();
                onSuccess(result, channelName, user != null ? user : "");
            } catch (Throwable t) {
                onSuccess(result, channelName, "");
            }
        });
    }

    private void getToken(JSONObject param, String channelName, Result result) throws JSONException
    {
        asyncRunnable(()-> onSuccess(result, channelName, EMClient.getInstance().getAccessToken()));
    }

    private void getCurrentDeviceId(JSONObject param, String channelName, Result result) throws JSONException {
        asyncRunnable(()->{
            // 手动构建 Map 对象，避免 EMDeviceInfo 只读属性问题
            Map<String, Object> deviceInfo = new HashMap<>();
            deviceInfo.put("deviceName", "");
            deviceInfo.put("resource", "");

            Context context = EMClient.getInstance().getContext();

            String deviceUuid = "";
            if (context != null) {
                try {
                    DeviceUuidFactory factory = new DeviceUuidFactory(context);
                    deviceUuid = factory.getDeviceUuid().toString();
                } catch (Exception e) {
                    // 获取失败时使用空字符串
                }
            }

            deviceInfo.put("deviceUUID", deviceUuid);

            onSuccess(result, channelName, deviceInfo);
        });
    }

    private void isLoggedInBefore(JSONObject param, String channelName, Result result) throws JSONException {
        // 5.0 移除了 isLoggedInBefore/getAutoLogin，统一用 isLoggedIn()
        asyncRunnable(()->{
            onSuccess(result, channelName, EMClient.getInstance().isLoggedIn());
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
        // 5.0 统一 token 版
        String username = param.getString("userId");
        String token = param.getString("password");
        String resource = param.getString("resource");
        asyncRunnable(()->{
            try {
                EMClient.getInstance().kickDeviceWithToken(username, token, resource);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void kickAllDevices(JSONObject param, String channelName, Result result) throws JSONException {
        // 5.0 统一 token 版
        String username = param.getString("userId");
        String token = param.getString("password");
        asyncRunnable(()->{
            try {
                EMClient.getInstance().kickAllDevicesWithToken(username, token);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void init(JSONObject param, String channelName, Result result) throws JSONException {
        if (options != null) {
            onSuccess(result, channelName, null);
            return;
        }
        options = OptionsHelper.fromJson(param, this.context);
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
        // 5.0 改为异步 fetchLoggedInDevicesFromServerWithToken
        String username = param.getString("userId");
        String token = param.getString("password");
        EMClient.getInstance().fetchLoggedInDevicesFromServerWithToken(username, token, new EMValueWrapperCallBack<List<EMDeviceInfo>>(result, channelName) {
            @Override
            public void onSuccess(List<EMDeviceInfo> devices) {
                List<Map> jsonList = new ArrayList<>();
                for (EMDeviceInfo info: devices) {
                    jsonList.add(DeviceInfoHelper.toJson(info));
                }
                updateObject(jsonList);
            }
        });
    }

    private void startCallback(JSONObject param, String channelName, Result result) {
        ListenerHandle.getInstance().startCallback();
        onSuccess(result, channelName, null);
    }

    private void bindingManagers() {
        chatManagerWrapper = new ChatManagerWrapper(binging, "chat_manager");
        contactManagerWrapper = new ContactManagerWrapper(binging, "chat_contact_manager");
        chatRoomManagerWrapper = new ChatRoomManagerWrapper(binging, "chat_room_manager");
        groupManagerWrapper = new GroupManagerWrapper(binging, "chat_group_manager");
        groupManagerWrapper.clientWrapper = this;
        conversationWrapper = new ConversationWrapper(binging, "chat_conversation");
        pushManagerWrapper = new PushManagerWrapper(binging, "chat_push_manager");
        presenceManagerWrapper = new PresenceManagerWrapper(binging, "chat_presence_manager");
        userInfoManagerWrapper = new UserInfoManagerWrapper(binging, "chat_userInfo_manager");
        messageWrapper = new MessageWrapper(binging, "chat_message");
        chatThreadManagerWrapper = new ChatThreadManagerWrapper(binging, "chat_thread_manager");
        progressManager = new ProgressManager(binging, "file_progress_manager");
    }

    private void clearAllListener() {
        if (chatManagerWrapper != null) chatManagerWrapper.unRegisterEaseListener();
        if (contactManagerWrapper != null) contactManagerWrapper.unRegisterEaseListener();
        if (chatRoomManagerWrapper != null) chatRoomManagerWrapper.unRegisterEaseListener();
        if (groupManagerWrapper != null) groupManagerWrapper.unRegisterEaseListener();
        if (conversationWrapper != null) conversationWrapper.unRegisterEaseListener();
        if (pushManagerWrapper != null) pushManagerWrapper.unRegisterEaseListener();
        if (presenceManagerWrapper != null) presenceManagerWrapper.unRegisterEaseListener();
        if (userInfoManagerWrapper != null) userInfoManagerWrapper.unRegisterEaseListener();
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
                post(()-> channel.invokeMethod(MethodKey.onMultiDeviceContactEvent, data));
            }

            @Override
            public void onGroupEvent(int event, String target, List<String> userNames) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", event);
                data.put("target", target);
                data.put("userIds", userNames);
                post(()-> channel.invokeMethod(MethodKey.onMultiDeviceGroupEvent, data));
            }

            public void onChatThreadEvent(int event, String target, List<String> usernames) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", event);
                data.put("target", target);
                data.put("userIds", usernames);
                post(()-> channel.invokeMethod(MethodKey.onMultiDeviceThreadEvent, data));
            }

            @Override
            public void onMessageRemoved(String conversationId, String deviceId) {
                Map<String, Object> data = new HashMap<>();
                data.put("convId", conversationId);
                data.put("deviceId", deviceId);
                post(()-> channel.invokeMethod(MethodKey.onMultiDeviceRemoveMessagesEvent, data));
            }

            @Override
            public void onConversationEvent(int event, String conversationId, EMConversation.EMConversationType type) {
                Map<String, Object> data = new HashMap<>();
                data.put("event", event);
                data.put("convId", conversationId);
                data.put("convType", EnumTools.conversationTypeToInt(type));
                post(()-> channel.invokeMethod(MethodKey.onMultiDevicesConversationEvent, data));
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
                post(()-> channel.invokeMethod(MethodKey.onConnected, data));
            }

            @Override
            public void onDisconnected(int errorCode) {
                if (errorCode == 206) {
                    // 这部分实现放到onLogout中。
//                    EMListenerHandle.getInstance().clearHandle();
//                    post(() -> channel.invokeMethod(EMSDKMethod.onUserDidLoginFromOtherDevice, null));
                }else if (errorCode == 207) {
                    ListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(MethodKey.onUserDidRemoveFromServer, null));
                }else if (errorCode == 305) {
                    ListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(MethodKey.onUserDidForbidByServer, null));
                }else if (errorCode == 216) {
                    ListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(MethodKey.onUserDidChangePassword, null));
                }else if (errorCode == 214) {
                    ListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(MethodKey.onUserDidLoginTooManyDevice, null));
                }
                else if (errorCode == 217) {
                    ListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(MethodKey.onUserKickedByOtherDevice, null));
                }
                else if (errorCode == 202) {
                    ListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(MethodKey.onUserAuthenticationFailed, null));
                }
                else if (errorCode == 8) {
                    post(() -> channel.invokeMethod(MethodKey.onAppActiveNumberReachLimit, null));
                }                
                else {
                    post(() -> channel.invokeMethod(MethodKey.onDisconnected, null));
                }
            }

            @Override
            public void onDatabaseOpened(String dbPath) {
                // 5.0 新增回调：数据库打开（避免 AbstractMethodError）
            }

            @Override
            public void onTokenExpired() {
                post(()-> channel.invokeMethod(MethodKey.onTokenDidExpire, null));
            }

            @Override
            public void onTokenWillExpire() {
                post(()-> channel.invokeMethod(MethodKey.onTokenWillExpire, null));
            }

            @Override
            public void onLogout(int errorCode, EMLoginExtensionInfo info) {
                if (errorCode == 206 || errorCode == 220) {
                    ListenerHandle.getInstance().clearHandle();
                    post(() -> channel.invokeMethod(MethodKey.onUserDidLoginFromOtherDevice, LoginExtensionInfoHelper.toJson(info)));
                }
            }
            @Override
            public void onOfflineMessageSyncStart() {
                post(()-> channel.invokeMethod(MethodKey.onOfflineMessageSyncStart, null));
            }
            @Override
            public void onOfflineMessageSyncFinish() {
                post(()-> channel.invokeMethod(MethodKey.onOfflineMessageSyncFinish, null));
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

    private void changeAppId(JSONObject param, String channelName, Result result) throws JSONException {
        String appId = param.getString("appId");
        asyncRunnable(()-> {
            try {
                EMClient.getInstance().changeAppId(appId);
                onSuccess(result, channelName, true);
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void notifyTokenExpired(JSONObject params, String channelName, Result result) throws JSONException {
        String pushToken = params.optString("pushToken", null);
        EMClient.getInstance().notifyTokenExpired(pushToken);
        onSuccess(result, channelName, true);
    }

    private void sendFCMTokenToServer(JSONObject params, String channelName, Result result) throws JSONException {
        String token = params.getString("token");
        EMClient.getInstance().sendFCMTokenToServer(token);
        onSuccess(result, channelName, true);
    }

    private void sendHonorPushTokenToServer(JSONObject params, String channelName, Result result) throws JSONException {
        String token = params.getString("token");
        EMClient.getInstance().sendHonorPushTokenToServer(token);
        onSuccess(result, channelName, true);
    }

    private void getRTCTokenInfoWithChannelName(JSONObject params, String channelName, Result result) throws JSONException {
        String channelNameStr = params.getString("channelName");
        EMClient.getInstance().asyncGetRTCTokenInfoWithChannelName(channelNameStr,
                new EMValueWrapperCallBack<EMRTCTokenInfo>(result, channelName) {
                    @Override
                    public void onSuccess(EMRTCTokenInfo info) {
                        Map<String, Object> map = new HashMap<>();
                        map.put("rtcToken", info.getRtcToken());
                        updateObject(map);
                    }
                });
    }

    private void getUserIdsWithRTCUids(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray ja = params.getJSONArray("rtcUids");
        List<Integer> rtcUids = new ArrayList<>();
        for (int i = 0; i < ja.length(); i++) {
            rtcUids.add(ja.getInt(i));
        }
        EMClient.getInstance().asyncGetUserIdsWithRTCUids(rtcUids,
                new EMValueWrapperCallBack<Map<Integer, String>>(result, channelName) {
                    @Override
                    public void onSuccess(Map<Integer, String> map) {
                        Map<String, Object> out = new HashMap<>();
                        for (Map.Entry<Integer, String> e : map.entrySet()) {
                            out.put(String.valueOf(e.getKey()), e.getValue());
                        }
                        updateObject(out);
                    }
                });
    }
}

