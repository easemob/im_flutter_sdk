import 'dart:io';

import 'package:flutter/services.dart';
import 'internal/chat_method_keys.dart';
import 'models/em_error.dart';
import 'models/em_push_configs.dart';

///
/// The push message presentation style: Simple represents the presentation of a simple message,
///
/// and Summary represents the presentation of message content.
///
enum DisplayStyle {
  /// 显示 ”您有一条新消息“
  Simple,

  /// 显示推送内容详情
  Summary,
}

///
///  The message push configuration options.
///
class EMPushManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_push_manager', JSONMethodCodec());

  Future<EMPushConfigs?> getPushConfigsFromCache() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getImPushConfig);
    try {
      EMError.hasErrorFromResult(result);
      return EMPushConfigs.fromJson(result[ChatMethodKeys.getImPushConfig]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取 `EMPushConfigs`
  Future<EMPushConfigs> getPushConfigsFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getImPushConfigFromServer);
    try {
      EMError.hasErrorFromResult(result);
      return EMPushConfigs.fromJson(
          result[ChatMethodKeys.getImPushConfigFromServer]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Turns on the push notification.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> enableOfflinePush() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.enableOfflinePush);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Do not push the offline messages within the specified time period (24-hour clock).
  ///
  /// Param [start] The start hour.
  ///
  /// Param [end] The end hour.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> disableOfflinePush({
    required int start,
    required int end,
  }) async {
    Map req = {'start': start, 'end': end};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.disableOfflinePush, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Sets wether to turn on or turn off the push notification for the the specified groups.
  ///
  /// [groupId] 群组id
  ///
  /// [enablePush] 是否接收离线推送
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> updatePushServiceForGroup({
    required List<String> groupIds,
    required bool enablePush,
  }) async {
    Map req = {'noPush': !enablePush, 'group_ids': groupIds};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupPushService, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从本地获取不接收推送的群组
  /// 如果需要从服务器获取，需要调用{@link #getPushConfigsFromServer}后再调用本方法
  Future<List<String>?> getNoPushGroupsFromCache() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getNoPushGroups);
    List<String> list = [];
    if (result.containsKey(ChatMethodKeys.getNoDisturbGroups)) {
      list = result[ChatMethodKeys.getNoDisturbGroups]?.cast<String>();
    }
    return list;
  }

  /// 更新当前用户的[nickname],这样离线消息推送的时候可以显示用户昵称而不是id，需要登录环信服务器成功后调用才生效
  Future<void> updatePushNickname(String nickname) async {
    Map req = {'nickname': nickname};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updatePushNickname, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 设置推送样式
  Future<void> updatePushDisplayStyle(DisplayStyle displayStyle) async {
    Map req = {'pushStyle': displayStyle == DisplayStyle.Simple ? 0 : 1};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateImPushStyle, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 上传华为推送token, 需要确保登录成功后再调用(可以是进入home页面后)
  Future<void> updateHMSPushToken(String token) async {
    if (Platform.isAndroid) {
      Map req = {'token': token};
      Map result =
          await _channel.invokeMethod(ChatMethodKeys.updateHMSPushToken, req);
      try {
        EMError.hasErrorFromResult(result);
      } on EMError catch (e) {
        throw e;
      }
    }
  }

  /// 上传FCM推送token, 需要确保登录成功后再调用(可以是进入home页面后)
  Future<void> updateFCMPushToken(String token) async {
    if (Platform.isAndroid) {
      Map req = {'token': token};
      Map result =
          await _channel.invokeMethod(ChatMethodKeys.updateFCMPushToken, req);
      try {
        EMError.hasErrorFromResult(result);
      } on EMError catch (e) {
        throw e;
      }
    }
  }

  /// 上传iOS推送deviceToken
  Future<void> updateAPNsDeviceToken(String token) async {
    if (Platform.isIOS) {
      Map req = {'token': token};
      Map result =
          await _channel.invokeMethod(ChatMethodKeys.updateAPNsPushToken, req);
      try {
        EMError.hasErrorFromResult(result);
      } on EMError catch (e) {
        throw e;
      }
    }
  }

  /// 从本地获取ImPushConfig
  @Deprecated('use - getPushConfigsFromCache method instead.')
  Future<EMPushConfigs> getImPushConfig() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getImPushConfig);
    try {
      EMError.hasErrorFromResult(result);
      return EMPushConfigs.fromJson(result[ChatMethodKeys.getImPushConfig]);
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 从服务器获取ImPushConfig
  @Deprecated('use - getPushConfigsFromServer method instead.')
  Future<EMPushConfigs> getImPushConfigFromServer() async {
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.getImPushConfigFromServer);
    try {
      EMError.hasErrorFromResult(result);
      return EMPushConfigs.fromJson(
          result[ChatMethodKeys.getImPushConfigFromServer]);
    } on EMError catch (e) {
      throw e;
    }
  }
}
