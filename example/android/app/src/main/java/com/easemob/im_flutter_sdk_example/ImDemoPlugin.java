package com.easemob.im_flutter_sdk_example;

import android.content.Context;

import androidx.annotation.NonNull;

import com.easemob.im_flutter_sdk.EMWrapper;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class
ImDemoPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, EMWrapper {
    public static final String CHANNEL = "com.easemob.demo/plugin";
    static MethodChannel channel;
    private Context context;
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), CHANNEL, JSONMethodCodec.INSTANCE);
        context = binding.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), CHANNEL, JSONMethodCodec.INSTANCE);
        ImDemoPlugin imDemoPlugin = new ImDemoPlugin();
        channel.setMethodCallHandler(imDemoPlugin);
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
