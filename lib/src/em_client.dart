import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/em_sdk_method.dart';

import 'dart:async';

import 'em_chat_manager.dart';
import 'em_domain_terms.dart';

class EMClient {

//  Future<dynamic> platformCallHandler(MethodCall methodCall) {
//
//    return Future.value(true);
//  }
//
//  static const MethodChannel _emClientChannel = const MethodChannel('em_client')
//  .setMethodCallHandler(platformCallHandler);

  static const MethodChannel _emClientChannel = const MethodChannel('em_client');

  EMChatManager _chatManager = new EMChatManager();
  EMContactManager _contactManager = new EMContactManager();

  static EMClient _instance;
  EMClient._internal() {
    // 日志?
  }
  static EMClient getInstance() {
    if (_instance == null) {
      _instance = new EMClient._internal();
    }
    return _instance;
  }


  static void _addNativeMethodCallHandler() {
    _emClientChannel.setMethodCallHandler((MethodCall call) {
      // todo
      return;
    });
  }

//  static Function() onOtherDeviceLogined;
  
  void init(EMOptions options) {
    _emClientChannel.invokeMethod(EMSDKMethod.Init, {"appkey": options.appKey});
    _addNativeMethodCallHandler();
  }

//  Future<bool> createAccount(String username, String password) async {
//    _emClientChannel.invokeMethod(EMSDKMethod.Register,
//        {"username": username, "password": password});
//      return await false;
//  }

  static void login() {
    _emClientChannel.invokeMethod(EMSDKMethod.Login);
  }

  EMChatManager chatManager() {
    return _chatManager;
  }

  EMContactManager contactManager() {
    return _contactManager;
  }
}
