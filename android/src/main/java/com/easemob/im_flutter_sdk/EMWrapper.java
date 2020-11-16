package com.easemob.im_flutter_sdk;

import com.hyphenate.exceptions.HyphenateException;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;



public class EMWrapper implements MethodChannel.MethodCallHandler {

  private static final String CHANNEL_PREFIX = "com.easemob.im/";

  private final ExecutorService cachedThreadPool = Executors.newCachedThreadPool();

  public EMWrapper(PluginRegistry.Registrar registrar, String channelName) {
    this.registrar = registrar;
    this.channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + channelName, JSONMethodCodec.INSTANCE);
    channel.setMethodCallHandler(this);
  }

  public PluginRegistry.Registrar registrar;
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

  public void onError(MethodChannel.Result result, HyphenateException e) {
    post(()-> {
      Map<String, Object> data = new HashMap<>();
        data.put("error", HyphenateExceptionHelper.toJson(e));
        result.success(data);
    });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    result.notImplemented();
  }
}
