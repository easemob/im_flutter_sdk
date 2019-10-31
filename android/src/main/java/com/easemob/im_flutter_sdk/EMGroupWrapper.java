package com.easemob.im_flutter_sdk;

import org.json.JSONObject;


import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class EMGroupWrapper implements MethodCallHandler, EMWrapper{
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        JSONObject argJson = (JSONObject) call.arguments;

    }
}
