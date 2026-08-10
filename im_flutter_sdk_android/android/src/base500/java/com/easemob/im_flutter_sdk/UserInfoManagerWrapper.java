package com.easemob.im_flutter_sdk;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMUserInfo;
import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class UserInfoManagerWrapper extends Wrapper implements MethodCallHandler {

    UserInfoManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
        registerAll();
        applyVersionOverrides();
    }

    @Override
    protected void registerAll() {
        register(MethodKey.updateOwnUserInfo, this::updateOwnUserInfo);
        register(MethodKey.updateOwnUserInfoWithType, this::updateOwnUserInfoWithType);
        register(MethodKey.fetchUserInfoById, this::fetchUserInfoById);
        register(MethodKey.fetchUserInfoByIdWithType, this::fetchUserInfoByIdWithType);
        register(MethodKey.fetchOwnInfo, (params, channelName, result) -> fetchOwnInfo(channelName, result));
        register(MethodKey.getUserInfoWithUserId, this::getUserInfoWithUserId);
        register(MethodKey.getUserInfoWithUserIds, this::getUserInfoWithUserIds);
        register(MethodKey.subscribeUsersInfo, this::subscribeUsersInfo);
        register(MethodKey.unsubscribeUsersInfo, this::unsubscribeUsersInfo);
        register(MethodKey.fetchSubscribedUsers, this::fetchSubscribedUsers);
    }



    private void fetchOwnInfo(String channelName, Result result) {
        String currentUser = EMClient.getInstance().getCurrentUser();
        if (currentUser == null || currentUser.isEmpty()) {
            onError(result, new HyphenateException(201, "User not login"));
            return;
        }
        EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(
                new String[]{currentUser},
                new EMValueWrapperCallBack<Map<String, EMUserInfo>>(
                        result,
                        channelName
                ) {
                    @Override
                    public void onSuccess(Map<String, EMUserInfo> object) {
                        updateObject(
                                object == null
                                        ? null
                                        : userInfoToJson(object.get(currentUser))
                        );
                    }
                }
        );
    }

    private void updateOwnUserInfo(JSONObject param, String channelName, Result result) {
        String currentUser = EMClient.getInstance().getCurrentUser();
        if (currentUser == null) {
            onError(result, new HyphenateException(201, "User not login"));
            return;
        }

        EMUserInfo info = userInfoFromJson(param);
        info.setUserId(currentUser);
        EMClient.getInstance().userInfoManager().updateOwnInfo(info, new EMValueWrapperCallBack<String>(result, channelName) {
            @Override
            public void onSuccess(String object) {
                updateObject(userInfoToJson(info));
            }
        });
    }

    private void updateOwnUserInfoWithType(JSONObject param, String channelName, Result result) throws JSONException {
        EMUserInfo.EMUserInfoType type = userInfoTypeFromInt(param.getInt("userInfoType"));
        String value = param.optString("userInfoValue", "");
        EMClient.getInstance().userInfoManager().updateOwnInfoByAttribute(type, value, new EMValueWrapperCallBack<String>(result, channelName));
    }

    private void fetchUserInfoById(JSONObject param, String channelName, Result result) throws JSONException {
        String[] userIds = stringArrayFromJson(param.getJSONArray("userIds"));
        EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(userIds, new EMValueWrapperCallBack<Map<String, EMUserInfo>>(result, channelName) {
            @Override
            public void onSuccess(Map<String, EMUserInfo> object) {
                updateObject(userInfoMapToJson(object));
            }
        });
    }

    private void fetchUserInfoByIdWithType(JSONObject param, String channelName, Result result) throws JSONException {
        String[] userIds = stringArrayFromJson(param.getJSONArray("userIds"));
        EMUserInfo.EMUserInfoType[] types = userInfoTypeArrayFromJson(param.getJSONArray("userInfoTypes"));
        EMClient.getInstance().userInfoManager().fetchUserInfoByAttribute(userIds, types, new EMValueWrapperCallBack<Map<String, EMUserInfo>>(result, channelName) {
            @Override
            public void onSuccess(Map<String, EMUserInfo> object) {
                updateObject(userInfoMapToJson(object));
            }
        });
    }

    private static EMUserInfo userInfoFromJson(JSONObject json) {
        EMUserInfo info = new EMUserInfo();
        if (json.has("userId")) {
            info.setUserId(json.optString("userId", null));
        }
        if (json.has("nickName")) {
            info.setNickname(json.optString("nickName", null));
        }
        if (json.has("avatarUrl")) {
            info.setAvatarUrl(json.optString("avatarUrl", null));
        }
        if (json.has("mail")) {
            info.setEmail(json.optString("mail", null));
        }
        if (json.has("phone")) {
            info.setPhoneNumber(json.optString("phone", null));
        }
        if (json.has("gender")) {
            info.setGender(json.optInt("gender", 0));
        }
        if (json.has("sign")) {
            info.setSignature(json.optString("sign", null));
        }
        if (json.has("birth")) {
            info.setBirth(json.optString("birth", null));
        }
        if (json.has("ext")) {
            info.setExt(json.optString("ext", null));
        }
        return info;
    }

    private static Map<String, Object> userInfoToJson(EMUserInfo info) {
        if (info == null) {
            return null;
        }
        Map<String, Object> data = new HashMap<>();
        data.put("userId", info.getUserId());
        data.put("nickName", info.getNickname());
        data.put("avatarUrl", info.getAvatarUrl());
        data.put("mail", info.getEmail());
        data.put("phone", info.getPhoneNumber());
        data.put("gender", info.getGender());
        data.put("sign", info.getSignature());
        data.put("birth", info.getBirth());
        data.put("ext", info.getExt());
        return data;
    }

    private static Map<String, Object> userInfoMapToJson(Map<String, EMUserInfo> userInfoMap) {
        Map<String, Object> data = new HashMap<>();
        if (userInfoMap == null) {
            return data;
        }
        for (Map.Entry<String, EMUserInfo> entry : userInfoMap.entrySet()) {
            data.put(entry.getKey(), userInfoToJson(entry.getValue()));
        }
        return data;
    }

    private static String[] stringArrayFromJson(JSONArray jsonArray) throws JSONException {
        String[] values = new String[jsonArray.length()];
        for (int i = 0; i < jsonArray.length(); i++) {
            values[i] = jsonArray.getString(i);
        }
        return values;
    }

    private static EMUserInfo.EMUserInfoType[] userInfoTypeArrayFromJson(JSONArray jsonArray) throws JSONException {
        EMUserInfo.EMUserInfoType[] values = new EMUserInfo.EMUserInfoType[jsonArray.length()];
        for (int i = 0; i < jsonArray.length(); i++) {
            values[i] = userInfoTypeFromInt(jsonArray.getInt(i));
        }
        return values;
    }

    private static EMUserInfo.EMUserInfoType userInfoTypeFromInt(int typeValue) {
        switch (typeValue) {
            case 0:
                return EMUserInfo.EMUserInfoType.NICKNAME;
            case 1:
                return EMUserInfo.EMUserInfoType.AVATAR_URL;
            case 2:
                return EMUserInfo.EMUserInfoType.PHONE;
            case 3:
                return EMUserInfo.EMUserInfoType.EMAIL;
            case 4:
                return EMUserInfo.EMUserInfoType.GENDER;
            case 5:
                return EMUserInfo.EMUserInfoType.SIGN;
            case 6:
                return EMUserInfo.EMUserInfoType.BIRTH;
            case 7:
                return EMUserInfo.EMUserInfoType.EXT;
            default:
                return EMUserInfo.EMUserInfoType.NICKNAME;
        }
    }

    private void getUserInfoWithUserId(JSONObject params, String channelName, Result result) throws JSONException {
        String userId = params.getString("userId");
        asyncRunnable(() -> {
            try {
                EMUserInfo info = EMClient.getInstance().userInfoManager().getUserInfoWithUserId(userId);
                onSuccess(result, channelName, info == null ? null : userInfoToJson(info));
            } catch (HyphenateException e) {
                onError(result, e);
            }
        });
    }

    private void getUserInfoWithUserIds(JSONObject params, String channelName, Result result) throws JSONException {
        String[] userIds = stringArrayFromJson(params.getJSONArray("userIds"));
        EMClient.getInstance().userInfoManager().getUserInfoWithUserIds(userIds,
                new EMValueWrapperCallBack<Map<String, EMUserInfo>>(result, channelName) {
                    @Override
                    public void onSuccess(Map<String, EMUserInfo> object) {
                        updateObject(userInfoMapToJson(object));
                    }
                });
    }

    private void subscribeUsersInfo(JSONObject params, String channelName, Result result) throws JSONException {
        String[] userIds = stringArrayFromJson(params.getJSONArray("userIds"));
        EMClient.getInstance().userInfoManager().subscribeUsersInfo(userIds,
                new EMWrapperCallBack(result, channelName, null));
    }

    private void unsubscribeUsersInfo(JSONObject params, String channelName, Result result) throws JSONException {
        String[] userIds = stringArrayFromJson(params.getJSONArray("userIds"));
        EMClient.getInstance().userInfoManager().unsubscribeUsersInfo(userIds,
                new EMWrapperCallBack(result, channelName, null));
    }

    private void fetchSubscribedUsers(JSONObject params, String channelName, Result result) throws JSONException {
        EMClient.getInstance().userInfoManager().fetchSubscribedUsers(
                new EMValueWrapperCallBack<List<EMUserInfo>>(result, channelName) {
                    @Override
                    public void onSuccess(List<EMUserInfo> object) {
                        List<Map<String, Object>> list = new ArrayList<>();
                        for (EMUserInfo info : object) {
                            list.add(userInfoToJson(info));
                        }
                        updateObject(list);
                    }
                });
    }
}
