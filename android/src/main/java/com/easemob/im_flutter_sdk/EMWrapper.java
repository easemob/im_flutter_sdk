package com.easemob.im_flutter_sdk;

import com.hyphenate.exceptions.HyphenateException;

import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

import io.flutter.plugin.common.MethodChannel;

public interface EMWrapper {
  default void post(Runnable runnable) {
    ImFlutterSdkPlugin.handler.post(runnable);
  }

  default void onSuccess(MethodChannel.Result result) {
    post(new Runnable() {
      @Override
      public void run() {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.TRUE);
        result.success(data);      }
    });
  }

  default void onError(MethodChannel.Result result, HyphenateException e) {
    post(new Runnable() {
      @Override
      public void run() {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("success", Boolean.FALSE);
        data.put("code", e.getErrorCode());
        data.put("desc", e.getDescription());
        result.success(data);     }
    });
  }
}
