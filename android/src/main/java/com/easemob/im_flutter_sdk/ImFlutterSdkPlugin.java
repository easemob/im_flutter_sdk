package com.easemob.im_flutter_sdk;

import android.os.Handler;
import android.os.Looper;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.util.EMLog;

import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.HashMap;
import java.util.Map;


/**
 * ImFlutterSdkPlugin
 */
public class ImFlutterSdkPlugin {

    static final Handler handler = new Handler(Looper.getMainLooper());

    private ImFlutterSdkPlugin() {
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        new EMClientWrapper(registrar, "em_client");
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
            EMLog.e("callback", "onError");
            result.success(data);
        });
    }

    @Override
    public void onProgress(int progress, String status) {
        // no need
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

    private void post(Runnable runnable) {
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