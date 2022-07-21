package com.easemob.im_flutter_sdk;


import java.util.HashMap;
import java.util.Map;

import com.hyphenate.EMError;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMUserInfo;
import com.hyphenate.exceptions.HyphenateException;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


public class EMUserInfoManagerWrapper extends EMWrapper implements MethodCallHandler {

    EMUserInfoManagerWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        JSONObject param = (JSONObject) call.arguments;
        try {
            if (EMSDKMethod.updateOwnUserInfo.equals(call.method)) {
                updateOwnUserInfo(param, call.method, result);
            } else if (EMSDKMethod.updateOwnUserInfoWithType.equals(call.method)) {
                updateOwnUserInfoWithType(param, call.method, result);
            }else if (EMSDKMethod.fetchUserInfoById.equals(call.method)) {
                fetchUserInfoByUserId(param, call.method, result);
            }else if (EMSDKMethod.fetchUserInfoByIdWithType.equals(call.method)) {
                fetchUserInfoByIdWithType(param, call.method, result);
            } else {
                super.onMethodCall(call, result);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void updateOwnUserInfo(JSONObject params, String channelName, Result result) throws JSONException {
        String username = EMClient.getInstance().getCurrentUser();
        if (username == null) {
            HyphenateException e = new HyphenateException(EMError.USER_NOT_LOGIN,"User not login");
            onError(result, e);
            return;
        }

        EMUserInfo userInfo = EMUserInfoHelper.fromJson(params);
        userInfo.setUserId(username);
        asyncRunnable(() -> {

            EMValueWrapperCallBack<String> callBack = new EMValueWrapperCallBack<String>(result, channelName){
                @Override
                public void onSuccess(final String object) {
                    updateObject(EMUserInfoHelper.toJson(userInfo));
                }

                @Override
                public void onError(final int code, final String desc) {
                    super.onError(code, desc);
                }
            };

            EMClient.getInstance().userInfoManager().updateOwnInfo(userInfo, callBack);
        });

    }


    private void updateOwnUserInfoWithType(JSONObject params, String channelName, Result result) throws JSONException {
        int userInfoTypeInt = params.getInt("userInfoType");
        String userInfoTypeValue = params.getString("userInfoValue");
        EMUserInfo.EMUserInfoType userInfoType = getUserInfoTypeFromInt(userInfoTypeInt);

         asyncRunnable(()->{

             EMValueWrapperCallBack<String> callBack = new EMValueWrapperCallBack<String>(result, channelName){
                 @Override
                 public void onSuccess(final String object) {

                     if(object != null && object.length() > 0) {
                         JSONObject obj = null;
                         try {
                             obj = new JSONObject(object);
                     String userId = EMClient.getInstance().getCurrentUser();
                             obj.put("userId", userId);
                             EMUserInfo userInfo = EMUserInfoHelper.fromJson(obj);
                             updateObject(EMUserInfoHelper.toJson(userInfo));

                     } catch (JSONException e) {
                         e.printStackTrace();
                     }
                 }
                 }
             };

             EMClient.getInstance().userInfoManager().updateOwnInfoByAttribute(userInfoType,userInfoTypeValue,callBack);

         });
    }


    private void fetchUserInfoByUserId(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray userIdArray = params.getJSONArray("userIds");
        String[] userIds = new String[userIdArray.length()];
        for (int i = 0; i < userIdArray.length(); i++) {
            userIds[i] = (String) userIdArray.get(i);
        }

        asyncRunnable(()->{
            EMValueWrapperCallBack<Map<String,EMUserInfo>> callBack = new EMValueWrapperCallBack<Map<String,EMUserInfo>>(result, channelName) {
                @Override
                public void onSuccess(Map<String,EMUserInfo> object) {
                    final Map<String,Map> rMap = generateMapFromMap(object);
                    updateObject(rMap);
                }
            };

            EMClient.getInstance().userInfoManager().fetchUserInfoByUserId(userIds, callBack);
        });
    }
    

    private void fetchUserInfoByIdWithType(JSONObject params, String channelName, Result result) throws JSONException {
        JSONArray userIdArray = params.getJSONArray("userIds");
        JSONArray userInfoTypeArray = params.getJSONArray("userInfoTypes");

        String[] userIds = new String[userIdArray.length()];
        for (int i = 0; i < userIdArray.length(); i++) {
            userIds[i] = (String) userIdArray.get(i);
        }

        EMUserInfo.EMUserInfoType[] infoTypes = new EMUserInfo.EMUserInfoType[userInfoTypeArray.length()];
        for (int i = 0; i < userInfoTypeArray.length(); i++) {
            EMUserInfo.EMUserInfoType infoType = getUserInfoTypeFromInt((int) userInfoTypeArray.get(i));
            infoTypes[i] = infoType;
        }

        asyncRunnable(()->{
            EMValueWrapperCallBack<Map<String,EMUserInfo>> callBack = new EMValueWrapperCallBack<Map<String,EMUserInfo>>(result, channelName) {
                @Override
                public void onSuccess(Map<String,EMUserInfo> object) {
                    final Map<String,Map> rMap = generateMapFromMap(object);
                    updateObject(rMap);
                }
            };

            EMClient.getInstance().userInfoManager().fetchUserInfoByAttribute(userIds, infoTypes, callBack);
        });

    }


    //组装response map
     Map<String,Map> generateMapFromMap(Map<String, EMUserInfo> aMap){
        Map<String,Map> resultMap = new HashMap<>();

        for(Map.Entry<String, EMUserInfo> entry : aMap.entrySet()){
            String mapKey = entry.getKey();
            EMUserInfo mapValue = entry.getValue();
            resultMap.put(mapKey, EMUserInfoHelper.toJson(mapValue));
        }
        return resultMap;
    }


    //获取用户属性类型
    private EMUserInfo.EMUserInfoType getUserInfoTypeFromInt(int value){
        int typeInt = value;
        EMUserInfo.EMUserInfoType infoType;

        switch (typeInt){
            case 0:
            {
                infoType = EMUserInfo.EMUserInfoType.NICKNAME;
            }
            break;

            case 1:
            {
                infoType = EMUserInfo.EMUserInfoType.AVATAR_URL;
            }
            break;

            case 2:
            {
                infoType = EMUserInfo.EMUserInfoType.EMAIL;
            }
            break;

            case 3:
            {
                infoType = EMUserInfo.EMUserInfoType.PHONE;
            }
            break;

            case 4:
            {
                infoType = EMUserInfo.EMUserInfoType.GENDER;
            }
            break;

            case 5:
            {
                infoType = EMUserInfo.EMUserInfoType.SIGN;
            }
            break;

            case 6:
            {
                infoType = EMUserInfo.EMUserInfoType.BIRTH;
            }
            break;

            case 100:
            {
                infoType = EMUserInfo.EMUserInfoType.EXT;
            }
            break;

            default:
                throw new IllegalStateException("Unexpected value: " + typeInt);
        }

        return infoType;
    }


}

