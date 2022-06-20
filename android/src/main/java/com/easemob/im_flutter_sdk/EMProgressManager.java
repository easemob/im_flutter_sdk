package com.easemob.im_flutter_sdk;

import com.hyphenate.EMError;
import com.hyphenate.exceptions.HyphenateException;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodChannel;

public class EMProgressManager extends EMWrapper implements MethodChannel.MethodCallHandler {

    public EMProgressManager(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String channelName) {
        super(flutterPluginBinding, channelName);
    }

    public void sendDownloadProgressToFlutter(String fileId, int progress){
        HashMap<String, Object> data = new HashMap<>();
        data.put("fileId", fileId);
        data.put("progress", progress);
        post(()->{
            channel.invokeMethod("onProgress", data);
        });
    }

    public void sendDownloadSuccessToFlutter(String fileId, String savePath) {
        HashMap<String, Object> data = new HashMap<>();
        data.put("fileId", fileId);
        data.put("savePath", savePath);
        post(()->{
            channel.invokeMethod("onSuccess", data);
        });
    }

    public void sendDownloadErrorToFlutter(String fileId, HyphenateException e) {
        Map<String, Object> error = new HashMap<>();
        error.put("code", e.getErrorCode());
        error.put("description", e.getDescription());
        HashMap<String, Object> data = new HashMap<>();
        data.put("fileId", fileId);
        data.put("error", error);
        post(()->{
            channel.invokeMethod("onError", data);
        });
    }
}
