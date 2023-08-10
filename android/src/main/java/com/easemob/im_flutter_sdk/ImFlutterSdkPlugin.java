package com.easemob.im_flutter_sdk;

import android.os.Handler;
import android.os.Looper;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.HashMap;
import java.util.Map;


/**
 * ImFlutterSdkPlugin
 */
public class ImFlutterSdkPlugin implements FlutterPlugin {

    static final Handler handler = new Handler(Looper.getMainLooper());

    EMClientWrapper clientWrapper;

    public ImFlutterSdkPlugin() {
    }

     public void sendDataToFlutter(final Map data) {
        if (clientWrapper != null) {
            clientWrapper.sendDataToFlutter(data);
        }
    }

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        clientWrapper = new EMClientWrapper(flutterPluginBinding, "chat_client");
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

    void post(Runnable runnable) {
        ImFlutterSdkPlugin.handler.post(runnable);
    }

    @Override
    public void onSuccess() {
        post(() -> {
            Map<String, Object> data = new HashMap<>();
            if (object != null) {
                data.put(channelName, object);
            }
            result.success(data);
        });
    }

    @Override
    public void onError(int code, String desc) {
        post(() -> {
            Map<String, Object> data = new HashMap<>();
            data.put("error", EMErrorHelper.toJson(code, desc));
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

    public void post(Runnable runnable) {
        ImFlutterSdkPlugin.handler.post(runnable);
    }

    @Override
    public void onSuccess(T object) {
        updateObject(object);
    }

    @Override
    public void onError(int code, String desc) {
        post(() -> {
            Map<String, Object> data = new HashMap<>();
            data.put("error", EMErrorHelper.toJson(code, desc));
            EMLog.e("callback", "onError");
            result.success(data);
        });
    }

    public void updateObject(Object object) {
        post(()-> {
            Map<String, Object> data = new HashMap<>();
            if (object != null) {
                data.put(channelName, object);
            }
            result.success(data);
        });
    }
}