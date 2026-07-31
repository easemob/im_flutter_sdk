package com.easemob.im_flutter_test;

import org.json.JSONObject;

import java.util.Set;

interface SdkVersionAdapter {
    Set<String> capabilities();

    boolean invokeGroup(String method, JSONObject arguments, NativeSdkBridge.NativeCallback callback);
}
