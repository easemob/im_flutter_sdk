package com.easemob.im_flutter_sdk;

import android.os.Handler;
import android.os.Looper;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.util.EMLog;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.HashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.Map;


/**
 * ImFlutterSdkPlugin
 */
public class ImFlutterSdkPlugin implements FlutterPlugin {

    static final Handler handler = new Handler(Looper.getMainLooper());

    ClientWrapper clientWrapper;

    public ImFlutterSdkPlugin() {
    }

     public void sendDataToFlutter(final Map data) {
        if (clientWrapper != null) {
            clientWrapper.sendDataToFlutter(data);
        }
    }

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        clientWrapper = new ClientWrapper(flutterPluginBinding, "chat_client");
    }

    @Override
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        clientWrapper.unRegisterEaseListener();
    }
}


class EMWrapperCallBack implements EMCallBack {

    EMWrapperCallBack(Result result, String channelName, Object object) {
        this.result = result;
        this.channelName = channelName;
        this.object = object;
    }

    Result result;
    String channelName;
    Object object;
    // result 只能提交一次：原生回调重复/超时后再回调 → 第二次忽略（防 "Reply already submitted" 崩溃）
    private final AtomicBoolean submitted = new AtomicBoolean(false);

    void post(Runnable runnable) {
        ImFlutterSdkPlugin.handler.post(runnable);
    }

    private void submitOnce(Runnable runnable) {
        post(() -> {
            if (submitted.compareAndSet(false, true)) {
                runnable.run();
            } else {
                EMLog.e("callback", "duplicate result submission ignored (already replied)");
            }
        });
    }

    @Override
    public void onSuccess() {
        submitOnce(() -> {
            Map<String, Object> data = new HashMap<>();
            if (object != null) {
                data.put(channelName, object);
            }
            result.success(data);
        });
    }

    public void updateObject(Object object) {
        submitOnce(()-> {
            Map<String, Object> data = new HashMap<>();
            if (object != null) {
                data.put(channelName, object);
            }
            result.success(data);
        });
    }

    @Override
    public void onError(int code, String desc) {
        submitOnce(() -> {
            Map<String, Object> data = new HashMap<>();
            data.put("error", ErrorHelper.toJson(code, desc));
            EMLog.e("callback", desc);
            result.success(data);
        });
    }

    @Override
    public void onProgress(int progress, String status) {
        // no need
    }
}

class EMDownloadCallback implements EMCallBack {

    EMDownloadCallback(String fileId, String savePath) {
        this.fileId = fileId;
        this.savePath = savePath;
    }
    String savePath;
    String fileId;


    @Override
    public void onSuccess() {

    }

    @Override
    public void onError(int code, String error) {

    }

    @Override
    public void onProgress(int progress, String status) {

    }
}


class EMValueWrapperCallBack<T> implements EMValueCallBack<T> {

    EMValueWrapperCallBack(MethodChannel.Result result, String channelName)
    {
        this.result = result;
        this.channelName = channelName;
    }

    private MethodChannel.Result result;
    private String channelName;
    // result 只能提交一次：原生回调重复/超时后再回调 → 第二次忽略（防 "Reply already submitted" 崩溃）
    private final AtomicBoolean submitted = new AtomicBoolean(false);

    public void post(Runnable runnable) {
        ImFlutterSdkPlugin.handler.post(runnable);
    }

    private void submitOnce(Runnable runnable) {
        post(() -> {
            if (submitted.compareAndSet(false, true)) {
                runnable.run();
            } else {
                EMLog.e("callback", "duplicate result submission ignored (already replied)");
            }
        });
    }

    @Override
    public void onSuccess(T object) {
        updateObject(object);
    }

    @Override
    public void onError(int code, String desc) {
        submitOnce(() -> {
            Map<String, Object> data = new HashMap<>();
            data.put("error", ErrorHelper.toJson(code, desc));
            EMLog.e("callback", "onError");
            result.success(data);
        });
    }

    public void updateObject(Object object) {
        submitOnce(()-> {
            Map<String, Object> data = new HashMap<>();
            if (object != null) {
                data.put(channelName, object);
            }
            result.success(data);
        });
    }
}