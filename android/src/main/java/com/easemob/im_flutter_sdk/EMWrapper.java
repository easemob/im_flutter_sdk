package com.easemob.im_flutter_sdk;

import android.content.Context;

import com.hyphenate.exceptions.HyphenateException;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;



public class EMWrapper implements MethodChannel.MethodCallHandler {

  private static final String CHANNEL_PREFIX = "com.chat.im/";

  private final ExecutorService cachedThreadPool = Executors.newCachedThreadPool();

  public EMWrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
    this.context = flutterPluginBinding.getApplicationContext();
    this.binging = flutterPluginBinding;
    this.channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_PREFIX + channelName, JSONMethodCodec.INSTANCE);
    channel.setMethodCallHandler(this);
  }

  public Context context;
  public FlutterPlugin.FlutterPluginBinding binging;
  public MethodChannel channel;


  public void post(Runnable runnable) {
    ImFlutterSdkPlugin.handler.post(runnable);
  }

  public void asyncRunnable(Runnable runnable) {
    cachedThreadPool.execute(runnable);
  }

  public void onSuccess(MethodChannel.Result result, String channelName, Object object) {
    post(()-> {
      Map<String, Object> data = new HashMap<>();
      if (object != null) {
        data.put(channelName, object);
      }
      result.success(data);
    });
  }

  public void unRegisterEaseListener() {}

  public void onError(MethodChannel.Result result, HyphenateException e) {
    post(()-> {
      Map<String, Object> data = new HashMap<>();
        data.put("error", HyphenateExceptionHelper.toJson(e));
        result.success(data);
    });
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    result.notImplemented();
  }
}
