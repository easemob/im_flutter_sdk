package com.easemob.im_flutter_sdk;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ImFlutterSdkPlugin */
public class ImFlutterSdkPlugin {
  private static final String CHANNEL_PREFIX = "com.easemob.im";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    registerClientWith(registrar);
    registerChatManagerWith(registrar);
    registerContactManagerWith(registrar);
  }

  public static void registerClientWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_client");
    channel.setMethodCallHandler(new EMClientWrapper(registrar.context()));
  }

  public static void registerChatManagerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_chat_manager");
    channel.setMethodCallHandler(new EMChatManagerWrapper());
  }

  public static void registerContactManagerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_contact_manager");
    channel.setMethodCallHandler(new EMContactManagerWrapper());
  }

  public static void registerConversationWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_PREFIX + "/em_conversation");
    channel.setMethodCallHandler(new EMConversationWrapper());
  }
}