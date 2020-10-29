package com.easemob.im_flutter_sdk;

import com.hyphenate.EMError;
import com.hyphenate.exceptions.HyphenateException;

import java.util.HashMap;
import java.util.Map;
import java.util.function.Consumer;

import io.flutter.plugin.common.MethodChannel;

public interface EMWrapper {
  default void post(Runnable runnable) {
    ImFlutterSdkPlugin.handler.post(runnable);
  }

  default void onSuccess(MethodChannel.Result result, String channelName, Object object) {
    post(()-> {
      Map<String, Object> data = new HashMap<>();
      data.put(channelName, object);
      result.success(data);
    });
  }

  default void onError(MethodChannel.Result result, HyphenateException e) {
    post(()-> {
      Map<String, Object> data = new HashMap<String, Object>();
        data.put("error", HyphenateExceptionHelper.toJson(e));
        result.success(data);
    });
  }
}
