package com.easemob.im_flutter_sdk_example;

import android.app.Activity;

import com.easemob.im_flutter_sdk.EMWrapper;
import com.easemob.im_flutter_sdk_example.receiver.CallReceiver;
import com.hyphenate.chat.EMCallManager;
import com.hyphenate.chat.EMCallSession;

import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class EMConferencePlugin implements MethodChannel.MethodCallHandler, EMWrapper {
    static final String Conference = "com.easemob.im/em_Conference_manager";
    static MethodChannel channel;
    private Activity activity;

    private EMConferencePlugin(Activity activity) {
        this.activity = activity;
    }

    static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), Conference , JSONMethodCodec.INSTANCE);
        EMConferencePlugin emConferencePlugin = new EMConferencePlugin(registrar.activity());
        channel.setMethodCallHandler(emConferencePlugin);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if(methodCall.method.equals("")){

        }
    }
}
