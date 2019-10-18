package com.easemob.im_flutter_sdk;

import com.hyphenate.util.EMLog;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class EMGroupWrapper implements MethodCallHandler, EMWrapper{
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        JSONObject argJson = (JSONObject) call.arguments;
        if (EMSDKMethod.getGroupId.equals(call.method)) {
            getGroupId(argJson, result);
        }
    }

    private void getGroupId(JSONObject argJson, Result result){

    }

    private void getGroupName(JSONObject argJson, Result result){

    }
    private void getDescription(JSONObject argJson, Result result){

    }
    private void isPublic(JSONObject argJson, Result result){

    }
    private void isAllowInvites(JSONObject argJson, Result result){

    }
    private void isMemberAllowToInvite(JSONObject argJson, Result result){

    }
    private void isMembersOnly(JSONObject argJson, Result result){

    }
    private void getMaxUserCount(JSONObject argJson, Result result){

    }
    private void isMsgBlocked(JSONObject argJson, Result result){

    }
    private void getOwner(JSONObject argJson, Result result){

    }
    private void groupSubject(JSONObject argJson, Result result){

    }
    private void getMembers(JSONObject argJson, Result result){

    }
    private void getMemberCount(JSONObject argJson, Result result){

    }
    private void getAdminList(JSONObject argJson, Result result){

    }
    private void getBlackList(JSONObject argJson, Result result){

    }
    private void getMuteList(JSONObject argJson, Result result){

    }
    private void getExtension(JSONObject argJson, Result result){

    }
    private void getAnnouncement(JSONObject argJson, Result result){

    }
    private void getShareFileList(JSONObject argJson, Result result){

    }
}
