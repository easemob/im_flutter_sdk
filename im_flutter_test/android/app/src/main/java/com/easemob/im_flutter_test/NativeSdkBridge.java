package com.easemob.im_flutter_test;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMContactListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMGroupManager;
import com.hyphenate.chat.EMGroupOptions;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMOptions;
import com.hyphenate.chat.EMUserInfo;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.DeviceUuidFactory;

import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONArray;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Test-only native Wrapper. All Dart calls arrive through
 * im_flutter_sdk_interface's fixed JSON MethodChannels.
 */
public final class NativeSdkBridge {
    private static final String PREFIX = "com.chat.im/";
    private static final String CLIENT = "Client";
    private static final String CONTACT = "ContactManager";
    private static final String GROUP = "GroupManager";
    private static final String USER_INFO = "UserInfoManager";

    private final Activity activity;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final ExecutorService worker = Executors.newCachedThreadPool();
    private final Map<String, MethodChannel> channels = new HashMap<>();
    private final SdkVersionAdapter versionAdapter = new SdkVersionAdapterImpl();
    private EMContactListener contactListener;
    private boolean initialized;

    public NativeSdkBridge(Activity activity, BinaryMessenger messenger) {
        this.activity = activity;
        register(messenger, CLIENT, "chat_client");
        register(messenger, "ChatManager", "chat_manager");
        register(messenger, CONTACT, "chat_contact_manager");
        register(messenger, GROUP, "chat_group_manager");
        register(messenger, "ChatRoomManager", "chat_room_manager");
        register(messenger, "PushManager", "chat_push_manager");
        register(messenger, "UserInfoManager", "chat_userInfo_manager");
        register(messenger, "PresenceManager", "chat_presence_manager");
        register(messenger, "ChatThreadManager", "chat_thread_manager");
        register(messenger, "ConversationManager", "chat_conversation");
        register(messenger, "MessageManager", "chat_message");
    }

    private void register(BinaryMessenger messenger, String manager, String channelName) {
        MethodChannel channel = new MethodChannel(
                messenger,
                PREFIX + channelName,
                JSONMethodCodec.INSTANCE
        );
        channel.setMethodCallHandler((call, result) -> onMethodCall(manager, call, result));
        channels.put(manager, channel);
    }

    private void onMethodCall(String manager, MethodCall call, MethodChannel.Result result) {
        final JSONObject arguments = asJson(call.arguments);
        try {
            if (CLIENT.equals(manager)) {
                invokeClient(call.method, arguments, result);
            } else if (CONTACT.equals(manager)) {
                invokeContact(call.method, arguments, result);
            } else if (USER_INFO.equals(manager)) {
                invokeUserInfo(call.method, arguments, result);
            } else if (GROUP.equals(manager)) {
                if (!invokeGroupCommon(call.method, arguments, result)
                        && !versionAdapter.invokeGroup(
                        call.method,
                        arguments,
                        callback(result, call.method))) {
                    unsupported(result, manager, call.method);
                }
            } else {
                unsupported(result, manager, call.method);
            }
        } catch (Throwable error) {
            postError(
                    result,
                    -1,
                    error.getMessage() == null ? error.toString() : error.getMessage()
            );
        }
    }

    private void invokeClient(String method, JSONObject args, MethodChannel.Result result)
            throws JSONException {
        switch (method) {
            case "init":
                init(args, result, method);
                return;
            case "getRunnerInfo":
                postValue(result, runnerInfo());
                return;
            case "login":
                login(args, result, method);
                return;
            case "createAccount":
                createAccount(args, result, method);
                return;
            case "logout":
                logout(args, result, method);
                return;
            case "isConnected":
                postValue(result, EMClient.getInstance().isConnected());
                return;
            case "getCurrentDeviceId":
                getCurrentDeviceId(result);
                return;
            case "startCallback":
                postSuccess(result, method, true);
                return;
            case "createUpgradeMessage":
                createUpgradeMessage(args, result, method);
                return;
            case "exportUpgradeSnapshot":
                exportUpgradeSnapshot(args, result, method);
                return;
            default:
                unsupported(result, CLIENT, method);
        }
    }

    private void getCurrentDeviceId(MethodChannel.Result result) {
        worker.execute(() -> {
            Map<String, Object> deviceInfo = new HashMap<>();
            deviceInfo.put("deviceName", "");
            deviceInfo.put("resource", "");
            String deviceUuid = "";
            Context context = EMClient.getInstance().getContext();
            if (context != null) {
                try {
                    deviceUuid = new DeviceUuidFactory(context)
                            .getDeviceUuid()
                            .toString();
                } catch (Throwable ignored) {
                }
            }
            deviceInfo.put("deviceUUID", deviceUuid);
            postValue(result, deviceInfo);
        });
    }

    private void init(JSONObject args, MethodChannel.Result result, String method)
            throws JSONException {
        if (initialized) {
            postSuccess(result, method, true);
            return;
        }
        EMOptions options = new EMOptions();
        options.setAppKey(args.getString("appKey"));
        options.setAutoLogin(args.optBoolean("autoLogin", false));
        options.setRequireAck(args.optBoolean("requireAck", true));
        options.setRequireDeliveryAck(args.optBoolean("requireDeliveryAck", false));
        options.setAcceptInvitationAlways(
                args.optBoolean("acceptInvitationAlways", false)
        );
        options.enableDNSConfig(args.optBoolean("enableDNSConfig", true));
        if (!args.optBoolean("enableDNSConfig", true)) {
            if (args.has("imServer")) options.setIMServer(args.getString("imServer"));
            if (args.has("imPort")) options.setImPort(args.getInt("imPort"));
            if (args.has("restServer")) options.setRestServer(args.getString("restServer"));
        }
        EMClient.getInstance().init(activity.getApplicationContext(), options);
        EMClient.getInstance().setDebugMode(args.optBoolean("debugModel", true));
        registerContactListener();
        initialized = true;
        postSuccess(result, method, true);
    }

    private void login(JSONObject args, MethodChannel.Result result, String method)
            throws JSONException {
        final String userId = args.getString("userId");
        final String credential = args.has("pwdOrToken")
                ? args.getString("pwdOrToken")
                : args.getString("password");
        final boolean password = args.has("isPassword")
                ? args.getBoolean("isPassword")
                : args.optBoolean("isPwd", true);
        // Native SDK 4.10 does not invoke the login callback when the same user
        // is already logged in. Treat that state as an idempotent success so a
        // retry after a relay reconnect always receives a MethodChannel result.
        if (EMClient.getInstance().isConnected()
                && userId.equals(EMClient.getInstance().getCurrentUser())) {
            postSuccess(result, method, userId);
            return;
        }
        EMCallBack callback = new EMCallBack() {
            @Override
            public void onSuccess() {
                // Re-register after login as well. Some native SDK versions
                // replace manager listeners while creating the login session.
                registerContactListener();
                postSuccess(result, method, EMClient.getInstance().getCurrentUser());
            }

            @Override
            public void onError(int code, String error) {
                postError(result, code, error);
            }

            @Override
            public void onProgress(int progress, String status) {
            }
        };
        if (password) {
            EMClient.getInstance().login(userId, credential, callback);
        } else {
            EMClient.getInstance().loginWithToken(userId, credential, callback);
        }
    }

    private void createAccount(
            JSONObject args,
            MethodChannel.Result result,
            String method
    ) throws JSONException {
        final String userId = args.getString("userId");
        final String password = args.getString("password");
        worker.execute(() -> {
            try {
                EMClient.getInstance().createAccount(userId, password);
                postSuccess(result, method, userId);
            } catch (HyphenateException error) {
                postError(result, error.getErrorCode(), error.getDescription());
            }
        });
    }

    private void logout(JSONObject args, MethodChannel.Result result, String method) {
        EMClient.getInstance().logout(
                args.optBoolean("unbindToken", false),
                new EMCallBack() {
                    @Override
                    public void onSuccess() {
                        postSuccess(result, method, true);
                    }

                    @Override
                    public void onError(int code, String error) {
                        postError(result, code, error);
                    }

                    @Override
                    public void onProgress(int progress, String status) {
                    }
                });
    }

    private void invokeContact(String method, JSONObject args, MethodChannel.Result result) {
        worker.execute(() -> {
            try {
                switch (method) {
                    case "addContact": {
                        String userId = args.getString("userId");
                        EMClient.getInstance().contactManager()
                                .addContact(userId, args.optString("reason", null));
                        postSuccess(result, method, userId);
                        return;
                    }
                    case "deleteContact": {
                        String userId = args.getString("userId");
                        EMClient.getInstance().contactManager().deleteContact(
                                userId,
                                args.optBoolean("keepConversation", true)
                        );
                        postSuccess(result, method, userId);
                        return;
                    }
                    case "acceptInvitation": {
                        String userId = args.getString("userId");
                        EMClient.getInstance().contactManager().acceptInvitation(userId);
                        postSuccess(result, method, userId);
                        return;
                    }
                    case "declineInvitation": {
                        String userId = args.getString("userId");
                        EMClient.getInstance().contactManager().declineInvitation(userId);
                        postSuccess(result, method, userId);
                        return;
                    }
                    case "getAllContactsFromServer":
                        postSuccess(
                                result,
                                method,
                                EMClient.getInstance().contactManager()
                                        .getAllContactsFromServer()
                        );
                        return;
                    case "getAllContactsFromDB":
                        postSuccess(
                                result,
                                method,
                                EMClient.getInstance().contactManager()
                                        .getContactsFromLocal()
                        );
                        return;
                    case "addUserToBlockList": {
                        String userId = args.getString("userId");
                        EMClient.getInstance().contactManager()
                                .addUserToBlackList(userId, false);
                        postSuccess(result, method, userId);
                        return;
                    }
                    case "removeUserFromBlockList": {
                        String userId = args.getString("userId");
                        EMClient.getInstance().contactManager()
                                .removeUserFromBlackList(userId);
                        postSuccess(result, method, userId);
                        return;
                    }
                    default:
                        unsupported(result, CONTACT, method);
                }
            } catch (HyphenateException error) {
                postError(result, error.getErrorCode(), error.getDescription());
            } catch (Throwable error) {
                postError(
                        result,
                        -1,
                        error.getMessage() == null ? error.toString() : error.getMessage()
                );
            }
        });
    }

    private boolean invokeGroupCommon(
            String method,
            JSONObject args,
            MethodChannel.Result result
    ) throws JSONException {
        if ("createGroup".equals(method)) {
            final String groupName = args.optString("groupName", "phase1-capability");
            final String description = args.optString("desc", "phase1 capability validation");
            final String inviteReason = args.optString("inviteReason", "");
            final JSONArray membersJson = args.optJSONArray("inviteMembers");
            final String[] members = new String[membersJson == null ? 0 : membersJson.length()];
            for (int index = 0; index < members.length; index++) {
                members[index] = membersJson.getString(index);
            }
            final JSONObject optionsJson = args.optJSONObject("options");
            EMGroupOptions options = new EMGroupOptions();
            options.maxUsers = optionsJson == null
                    ? 20
                    : optionsJson.optInt("maxCount", 20);
            options.inviteNeedConfirm = optionsJson != null
                    && optionsJson.optBoolean("inviteNeedConfirm", false);
            options.style = EMGroupManager.EMGroupStyle.EMGroupStylePrivateOnlyOwnerInvite;
            EMClient.getInstance().groupManager().asyncCreateGroup(
                    groupName,
                    description,
                    members,
                    inviteReason,
                    options,
                    new EMValueCallBack<EMGroup>() {
                        @Override
                        public void onSuccess(EMGroup group) {
                            Map<String, Object> value = new HashMap<>();
                            value.put("groupId", group.getGroupId());
                            value.put("name", group.getGroupName());
                            callback(result, method).success(value);
                        }

                        @Override
                        public void onError(int code, String error) {
                            callback(result, method).error(code, error);
                        }
                    }
            );
            return true;
        }
        if ("destroyGroup".equals(method)) {
            EMClient.getInstance().groupManager().asyncDestroyGroup(
                    args.getString("groupId"),
                    new EMCallBack() {
                        @Override
                        public void onSuccess() {
                            postSuccess(result, method, true);
                        }

                        @Override
                        public void onError(int code, String error) {
                            postError(result, code, error);
                        }

                        @Override
                        public void onProgress(int progress, String status) {
                        }
                    }
            );
            return true;
        }
        return false;
    }

    private void invokeUserInfo(
            String method,
            JSONObject args,
            MethodChannel.Result result
    ) throws JSONException {
        switch (method) {
            case "updateOwnUserInfo": {
                final String currentUser = EMClient.getInstance().getCurrentUser();
                if (currentUser == null || currentUser.trim().isEmpty()) {
                    postError(result, 201, "User not login");
                    return;
                }
                final EMUserInfo userInfo = userInfoFromJson(args);
                userInfo.setUserId(currentUser);
                EMClient.getInstance().userInfoManager().updateOwnInfo(
                        userInfo,
                        new EMValueCallBack<String>() {
                            @Override
                            public void onSuccess(String value) {
                                postSuccess(result, method, userInfoToJson(userInfo));
                            }

                            @Override
                            public void onError(int code, String error) {
                                postError(result, code, error);
                            }
                        }
                );
                return;
            }
            case "updateOwnUserInfoWithType": {
                final EMUserInfo.EMUserInfoType type = userInfoTypeFromInt(
                        args.getInt("userInfoType")
                );
                final String value = args.optString("userInfoValue", "");
                EMClient.getInstance().userInfoManager().updateOwnInfoByAttribute(
                        type,
                        value,
                        new EMValueCallBack<String>() {
                            @Override
                            public void onSuccess(String response) {
                                postSuccess(result, method, response);
                            }

                            @Override
                            public void onError(int code, String error) {
                                postError(result, code, error);
                            }
                        }
                );
                return;
            }
            case "fetchUserInfoById": {
                final String[] userIds = stringArrayFromJson(args.getJSONArray("userIds"));
                fetchUserInfoMap(method, userIds, null, result);
                return;
            }
            case "fetchUserInfoByIdWithType": {
                final String[] userIds = stringArrayFromJson(args.getJSONArray("userIds"));
                final EMUserInfo.EMUserInfoType[] types = userInfoTypeArrayFromJson(
                        args.getJSONArray("userInfoTypes")
                );
                fetchUserInfoMap(method, userIds, types, result);
                return;
            }
            case "fetchOwnInfo": {
                final String currentUser = EMClient.getInstance().getCurrentUser();
                if (currentUser == null || currentUser.trim().isEmpty()) {
                    postError(result, 201, "User not login");
                    return;
                }
                EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(
                        new String[]{currentUser},
                        new EMValueCallBack<Map<String, EMUserInfo>>() {
                            @Override
                            public void onSuccess(Map<String, EMUserInfo> value) {
                                EMUserInfo ownInfo = value == null ? null : value.get(currentUser);
                                postSuccess(
                                        result,
                                        method,
                                        ownInfo == null
                                                ? Collections.emptyMap()
                                                : userInfoToJson(ownInfo)
                                );
                            }

                            @Override
                            public void onError(int code, String error) {
                                postError(result, code, error);
                            }
                        }
                );
                return;
            }
            default:
                unsupported(result, USER_INFO, method);
        }
    }

    private void fetchUserInfoMap(
            String method,
            String[] userIds,
            EMUserInfo.EMUserInfoType[] types,
            MethodChannel.Result result
    ) {
        EMValueCallBack<Map<String, EMUserInfo>> callback =
                new EMValueCallBack<Map<String, EMUserInfo>>() {
                    @Override
                    public void onSuccess(Map<String, EMUserInfo> value) {
                        postSuccess(result, method, userInfoMapToJson(value));
                    }

                    @Override
                    public void onError(int code, String error) {
                        postError(result, code, error);
                    }
                };
        if (types == null) {
            EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(
                    userIds,
                    callback
            );
        } else {
            EMClient.getInstance().userInfoManager().fetchUserInfoByAttribute(
                    userIds,
                    types,
                    callback
            );
        }
    }

    private static EMUserInfo userInfoFromJson(JSONObject json) {
        EMUserInfo info = new EMUserInfo();
        if (json.has("userId")) info.setUserId(json.optString("userId", null));
        if (json.has("nickName")) info.setNickname(json.optString("nickName", null));
        if (json.has("avatarUrl")) info.setAvatarUrl(json.optString("avatarUrl", null));
        if (json.has("mail")) info.setEmail(json.optString("mail", null));
        if (json.has("phone")) info.setPhoneNumber(json.optString("phone", null));
        if (json.has("gender")) info.setGender(json.optInt("gender", 0));
        if (json.has("sign")) info.setSignature(json.optString("sign", null));
        if (json.has("birth")) info.setBirth(json.optString("birth", null));
        if (json.has("ext")) info.setExt(json.optString("ext", null));
        return info;
    }

    private static Map<String, Object> userInfoToJson(EMUserInfo info) {
        Map<String, Object> value = new HashMap<>();
        value.put("userId", info.getUserId());
        value.put("nickName", info.getNickname());
        value.put("avatarUrl", info.getAvatarUrl());
        value.put("mail", info.getEmail());
        value.put("phone", info.getPhoneNumber());
        value.put("gender", info.getGender());
        value.put("sign", info.getSignature());
        value.put("birth", info.getBirth());
        value.put("ext", info.getExt());
        return value;
    }

    private static Map<String, Object> userInfoMapToJson(
            Map<String, EMUserInfo> userInfoMap
    ) {
        Map<String, Object> value = new HashMap<>();
        if (userInfoMap == null) return value;
        for (Map.Entry<String, EMUserInfo> entry : userInfoMap.entrySet()) {
            value.put(entry.getKey(), userInfoToJson(entry.getValue()));
        }
        return value;
    }

    private static String[] stringArrayFromJson(JSONArray jsonArray)
            throws JSONException {
        String[] values = new String[jsonArray.length()];
        for (int index = 0; index < jsonArray.length(); index++) {
            values[index] = jsonArray.getString(index);
        }
        return values;
    }

    private static EMUserInfo.EMUserInfoType[] userInfoTypeArrayFromJson(
            JSONArray jsonArray
    ) throws JSONException {
        EMUserInfo.EMUserInfoType[] values =
                new EMUserInfo.EMUserInfoType[jsonArray.length()];
        for (int index = 0; index < jsonArray.length(); index++) {
            values[index] = userInfoTypeFromInt(jsonArray.getInt(index));
        }
        return values;
    }

    private static EMUserInfo.EMUserInfoType userInfoTypeFromInt(int value) {
        switch (value) {
            case 0:
                return EMUserInfo.EMUserInfoType.NICKNAME;
            case 1:
                return EMUserInfo.EMUserInfoType.AVATAR_URL;
            case 2:
                return EMUserInfo.EMUserInfoType.EMAIL;
            case 3:
                return EMUserInfo.EMUserInfoType.PHONE;
            case 4:
                return EMUserInfo.EMUserInfoType.GENDER;
            case 5:
                return EMUserInfo.EMUserInfoType.SIGN;
            case 6:
                return EMUserInfo.EMUserInfoType.BIRTH;
            case 7:
            case 100:
                return EMUserInfo.EMUserInfoType.EXT;
            default:
                throw new IllegalArgumentException(
                        "Unsupported userInfoType: " + value
                );
        }
    }

    private void registerContactListener() {
        if (contactListener != null) {
            EMClient.getInstance().contactManager().removeContactListener(contactListener);
        }
        contactListener = new EMContactListener() {
            @Override
            public void onContactAdded(String userName) {
                emitContact("onContactAdded", userName, null);
            }

            @Override
            public void onContactDeleted(String userName) {
                emitContact("onContactDeleted", userName, null);
            }

            @Override
            public void onContactInvited(String userName, String reason) {
                emitContact("onContactInvited", userName, reason);
            }

            @Override
            public void onFriendRequestAccepted(String userName) {
                emitContact("onFriendRequestAccepted", userName, null);
            }

            @Override
            public void onFriendRequestDeclined(String userName) {
                emitContact("onFriendRequestDeclined", userName, null);
            }
        };
        EMClient.getInstance().contactManager().setContactListener(contactListener);
    }

    private void emitContact(String type, String userId, String reason) {
        Log.d(
                "NativeSdkBridge",
                "contact event type=" + type + " userId=" + userId
        );
        Map<String, Object> data = new HashMap<>();
        data.put("type", type);
        data.put("userId", userId);
        if (reason != null) data.put("reason", reason);
        MethodChannel channel = channels.get(CONTACT);
        if (channel != null) {
            mainHandler.post(() -> channel.invokeMethod("onContactChanged", data));
        }
    }

    private void createUpgradeMessage(
            JSONObject args,
            MethodChannel.Result result,
            String method
    ) throws JSONException {
        final String marker = args.getString("marker");
        final String conversationId = args.optString("conversationId", "upgrade-peer");
        worker.execute(() -> {
            EMMessage message = EMMessage.createTxtSendMessage(marker, conversationId);
            message.setMsgId(marker);
            EMConversation conversation = EMClient.getInstance().chatManager().getConversation(
                    conversationId,
                    EMConversation.EMConversationType.Chat,
                    true
            );
            conversation.insertMessage(message);
            Map<String, Object> snapshot = new HashMap<>();
            snapshot.put("marker", marker);
            snapshot.put("conversationId", conversationId);
            snapshot.put(
                    "exists",
                    EMClient.getInstance().chatManager().getMessage(marker) != null
            );
            postSuccess(result, method, snapshot);
        });
    }

    private void exportUpgradeSnapshot(
            JSONObject args,
            MethodChannel.Result result,
            String method
    ) throws JSONException {
        final String marker = args.getString("marker");
        worker.execute(() -> {
            EMMessage message = EMClient.getInstance().chatManager().getMessage(marker);
            Map<String, Object> snapshot = new HashMap<>();
            snapshot.put("marker", marker);
            snapshot.put("exists", message != null);
            if (message != null) {
                snapshot.put("messageId", message.getMsgId());
                snapshot.put("conversationId", message.conversationId());
                snapshot.put(
                        "body",
                        message.getBody() == null ? null : message.getBody().toString()
                );
            }
            postSuccess(result, method, snapshot);
        });
    }

    private Map<String, Object> runnerInfo() {
        Set<String> capabilities = new LinkedHashSet<>(Arrays.asList(
                "Client.init",
                "Client.getRunnerInfo",
                "Client.login",
                "Client.logout",
                "Client.isConnected",
                "Client.getCurrentDeviceId",
                "Client.createAccount",
                "Client.startCallback",
                "Client.createUpgradeMessage",
                "Client.exportUpgradeSnapshot",
                "ContactManager.addContact",
                "ContactManager.deleteContact",
                "ContactManager.acceptInvitation",
                "ContactManager.declineInvitation",
                "ContactManager.getAllContactsFromServer",
                "ContactManager.getAllContactsFromDB",
                "ContactManager.addUserToBlockList",
                "ContactManager.removeUserFromBlockList",
                "GroupManager.createGroup",
                "GroupManager.destroyGroup",
                "UserInfoManager.updateOwnUserInfo",
                "UserInfoManager.updateOwnUserInfoWithType",
                "UserInfoManager.fetchUserInfoById",
                "UserInfoManager.fetchUserInfoByIdWithType",
                "UserInfoManager.fetchOwnInfo"
        ));
        capabilities.addAll(versionAdapter.capabilities());

        Map<String, Object> info = new HashMap<>();
        info.put("runnerId", intentString("runnerId", BuildConfig.FLAVOR));
        info.put("deviceName", intentString("runnerDevice", "deviceA"));
        info.put("runId", intentString("runnerRunId", ""));
        info.put("logicalDevice", intentString("runnerLogicalDevice", ""));
        info.put("artifactId", intentString("runnerArtifactId", ""));
        info.put("wrapperCommit", intentString("runnerWrapperCommit", ""));
        info.put(
                "nativeSdkSha256",
                intentString("runnerNativeSdkSha256", "")
        );
        info.put("platform", "android");
        info.put("sdkVersion", BuildConfig.CHAT_SDK_VERSION);
        info.put("appVersion", BuildConfig.VERSION_NAME);
        info.put("topic", intentString("runnerTopic", ""));
        info.put("webSocketBaseUrl", intentString("runnerWsBaseUrl", ""));
        info.put(
                "managedWebSocket",
                Boolean.parseBoolean(intentString("runnerWsManaged", "false"))
        );
        List<String> sorted = new ArrayList<>(capabilities);
        Collections.sort(sorted);
        info.put("capabilities", sorted);
        return info;
    }

    private String intentString(String key, String fallback) {
        String value = activity.getIntent().getStringExtra(key);
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    private NativeCallback callback(MethodChannel.Result result, String method) {
        return new NativeCallback() {
            @Override
            public void success(Object value) {
                postSuccess(result, method, value);
            }

            @Override
            public void error(int code, String description) {
                postError(result, code, description);
            }
        };
    }

    private void unsupported(MethodChannel.Result result, String manager, String method) {
        postError(result, -2, "Unsupported API: " + manager + "." + method);
    }

    private void postSuccess(MethodChannel.Result result, String method, Object value) {
        Map<String, Object> response = new HashMap<>();
        response.put(method, value);
        mainHandler.post(() -> result.success(response));
    }

    private void postValue(MethodChannel.Result result, Object value) {
        mainHandler.post(() -> result.success(value));
    }

    private void postError(MethodChannel.Result result, int code, String description) {
        Map<String, Object> error = new HashMap<>();
        error.put("code", code);
        error.put("description", description == null ? "Unknown error" : description);
        Map<String, Object> response = new HashMap<>();
        response.put("error", error);
        mainHandler.post(() -> result.success(response));
    }

    private static JSONObject asJson(Object arguments) {
        return arguments instanceof JSONObject ? (JSONObject) arguments : new JSONObject();
    }

    public void dispose() {
        if (contactListener != null && initialized) {
            EMClient.getInstance().contactManager().removeContactListener(contactListener);
        }
        for (MethodChannel channel : channels.values()) {
            channel.setMethodCallHandler(null);
        }
        channels.clear();
        worker.shutdownNow();
    }

    interface NativeCallback {
        void success(Object value);

        void error(int code, String description);
    }
}
