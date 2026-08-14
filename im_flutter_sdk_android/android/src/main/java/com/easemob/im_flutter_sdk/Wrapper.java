package com.easemob.im_flutter_sdk;

import android.content.Context;

import com.hyphenate.exceptions.HyphenateException;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class Wrapper implements MethodChannel.MethodCallHandler {

  private static final String CHANNEL_PREFIX = "com.chat.im/";

  private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
  private final ExecutorService cachedThreadPool = Executors.newFixedThreadPool(CPU_COUNT + 1);
  private final ExecutorService heavyWorkCachedThreadPool = Executors.newFixedThreadPool(CPU_COUNT + 1);

  public Wrapper(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
    this.context = flutterPluginBinding.getApplicationContext();
    this.binging = flutterPluginBinding;
    this.channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_PREFIX + channelName, JSONMethodCodec.INSTANCE);
    channel.setMethodCallHandler(this);
  }

  public Context context;
  public FlutterPlugin.FlutterPluginBinding binging;
  public MethodChannel channel;

  /**
   * 统一安全入口：每次调用只解析一次参数、只创建一个 OnceResult，再交给子类显式分发。
   * 子类只覆盖 dispatchMethodCall，避免绕过防重复提交与统一异常处理。
   */
  @Override
  public final void onMethodCall(MethodCall call, MethodChannel.Result result) {
    // 全局防重复提交：同一个 MethodChannel.Result 只允许提交一次（success/error/notImplemented）
    // 原生回调重复 / wrapper 提前返回 + 回调双提交 → 第二次忽略（防 "Reply already submitted" 崩溃）
    final MethodChannel.Result once = new OnceResult(result);
    final JSONObject param;
    try {
      param = argumentsToJSONObject(call.arguments);
    } catch (JSONException e) {
      replyJsonOrRuntimeError(once, e);
      return;
    }
    try {
      if (!dispatchMethodCall(call.method, param, once)) {
        once.notImplemented();
      }
    } catch (Exception e) {
      replyJsonOrRuntimeError(once, e);
    }
  }

  /**
   * 子类的 API 路由入口。返回 true 表示命令已处理，false 由公共入口回复 notImplemented。
   */
  protected boolean dispatchMethodCall(
      String method,
      JSONObject param,
      MethodChannel.Result result
  ) throws Exception {
    return false;
  }

  /** 包装 MethodChannel.Result：只允许一次 success/error/notImplemented。 */
  private static class OnceResult implements MethodChannel.Result {
    private final MethodChannel.Result delegate;
    private final java.util.concurrent.atomic.AtomicBoolean submitted = new java.util.concurrent.atomic.AtomicBoolean(false);

    OnceResult(MethodChannel.Result delegate) {
      this.delegate = delegate;
    }

    @Override
    public void success(Object result) {
      if (submitted.compareAndSet(false, true)) {
        delegate.success(result);
      }
    }

    @Override
    public void error(String code, String message, Object details) {
      if (submitted.compareAndSet(false, true)) {
        delegate.error(code, message, details);
      }
    }

    @Override
    public void notImplemented() {
      if (submitted.compareAndSet(false, true)) {
        delegate.notImplemented();
      }
    }
  }

  /**
   * JSON 通道里 args 在部分机型/版本上可能是 {@link JSONObject}，也可能是 {@link Map} 等，
   * 强转失败会抛 ClassCastException。统一转 JSONObject。
   */
  protected static JSONObject argumentsToJSONObject(Object args) throws JSONException {
    if (args == null) {
      return new JSONObject();
    }
    if (args instanceof JSONObject) {
      return (JSONObject) args;
    }
    if (args instanceof Map) {
      return new JSONObject((Map<?, ?>) args);
    }
    if (args instanceof String) {
      return new JSONObject((String) args);
    }
    throw new JSONException("Unsupported args type: " + args.getClass().getName());
  }

  /** 统一错误响应。 */
  protected void replyJsonOrRuntimeError(MethodChannel.Result result, Throwable t) {
    post(() -> {
      Map<String, Object> data = new HashMap<>();
      String msg = t.getMessage() != null ? t.getMessage() : t.toString();
      data.put("error", ErrorHelper.toJson(-1, msg));
      result.success(data);
    });
  }

  public void post(Runnable runnable) {
    ImFlutterSdkPlugin.handler.post(runnable);
  }

  public void asyncRunnable(Runnable runnable) {
    cachedThreadPool.execute(runnable);
  }

  public void asyncHeavyWorkRunnable(Runnable runnable) {
    heavyWorkCachedThreadPool.execute(runnable);
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
}
