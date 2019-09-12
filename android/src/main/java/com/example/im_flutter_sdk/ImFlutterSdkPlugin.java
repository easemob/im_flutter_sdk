package com.example.im_flutter_sdk;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ImFlutterSdkPlugin */
public class ImFlutterSdkPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    registerClientWith(registrar);
    registerChatManagerWith(registrar);
    registerContactManagerWith(registrar);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
  }

  public static void registerClientWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "em_client");
    channel.setMethodCallHandler(new ImClientPlugin());
  }

  public static void registerChatManagerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "em_chat_manager");
    channel.setMethodCallHandler(new ImChatManagerPlugin());
  }

  public static void registerContactManagerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "em_contact_manager");
    channel.setMethodCallHandler(new ImContactManagerPlugin());
  }
}

class ImClientPlugin implements MethodCallHandler {
  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("EMClient.getInstance().init()")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }
}

class ImChatManagerPlugin implements MethodCallHandler {
  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }
}

class ImContactManagerPlugin implements MethodCallHandler {
  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }
}