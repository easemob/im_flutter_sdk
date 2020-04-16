package com.easemob.im_flutter_sdk_example;

import com.easemob.im_flutter_sdk.EMWrapper;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class
ImDemoFlugin implements MethodChannel.MethodCallHandler, EMWrapper {
    public static final String CHANNEL = "com.easemob.demo/plugin";
    static MethodChannel channel;

    private ImDemoFlugin(){}

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), CHANNEL);
        ImDemoFlugin imDemoFlugin = new ImDemoFlugin();
        channel.setMethodCallHandler(imDemoFlugin);
    }


    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if(methodCall.method.equals("loginComplete")){
            /***
             * 已登录成功进入主界面，去注册华为推送，实现方式和Android demo一样，
             * 需要在PushReceiver#onToken里调用
             * EMClient.getInstance().sendHMSPushTokenToServer(token)
             * 去上传推送token
             */
            post(new Runnable() {
                @Override
                public void run() {
                    result.success("success");
                }});
        }
    }
}
