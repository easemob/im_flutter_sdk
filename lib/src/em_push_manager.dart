import 'dart:io';

import 'package:flutter/services.dart';
import 'internal/chat_method_keys.dart';
import 'models/em_chat_enums.dart';
import 'models/em_error.dart';
import 'models/em_push_configs.dart';

///
///  推送设置管理类。
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

  /// Gets the push configurations from the server.
  Future<EMPushConfigs> fetchPushConfigsFromServer() async {
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
  /// Param [start] The start hour(24-hour clock).
  ///
  /// Param [end] The end hour(24-hour clock).
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
  /// Sets whether to turn on or turn off the push notification for the the specified groups.
  ///
  /// [groupIds]  The list of groups to be set.
  ///
  /// [enablePush] enable push notification.
  /// `true`: Turns on the notification;
  /// `false`: Turns off the notification;
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

  ///
  /// Sets whether to turn on or turn off the push notification for the the specified users.
  ///
  /// [userIds]  The list of users to be set.
  ///
  /// [enablePush] enable push notification.
  /// `true`: Turns on the notification;
  /// `false`: Turns off the notification;
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<void> updatePushServiceFroUsers({
    required List<String> userIds,
    required bool enablePush,
  }) async {
    Map req = {'noPush': !enablePush, 'user_ids': userIds};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateUserPushService, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the list of groups which have blocked the push notification.
  ///
  /// **return** The list of groups that blocked the push notification.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>> getNoPushGroupsFromCache() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getNoPushGroups);
    List<String> list = [];
    if (result.containsKey(ChatMethodKeys.getNoPushGroups)) {
      list = result[ChatMethodKeys.getNoPushGroups]?.cast<String>();
    }
    return list;
  }

  ///
  /// Gets the list of users which have blocked the push notification.
  ///
  /// **return** The list of user that blocked the push notification.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
  Future<List<String>> getNoPushUsersFromCache() async {
    Map result = await _channel.invokeMethod(ChatMethodKeys.getNoPushUsers);
    List<String> list = [];
    if (result.containsKey(ChatMethodKeys.getNoPushUsers)) {
      list = result[ChatMethodKeys.getNoPushUsers]?.cast<String>();
    }
    return list;
  }

  ///
  /// Updates the push display nickname of the current user.
  ///
  /// This method can be used to set a push display nickname, the push display nickname will be used to show for offline push notification.
  /// When the app user changes the nickname in the user profile(use {@link EMUserInfoManager#updateOwnInfo(EMUserInfo, int?)
  /// be sure to also call this method to update to prevent the display differences.
  ///
  /// Param [nickname] The push display nickname, which is different from the nickname in the user profile.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
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

  ///
  ///  Updates the push message style. The default value is {@link DisplayStyle#Simple}.
  ///
  /// Param [displayStyle] The push message display style.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
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

  ///
  ///  Updates the HMS push token.
  ///
  /// Param [token] The HMS push token.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
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

  ///
  ///  Updates the FCM push token.
  ///
  /// Param [token] The FCM push token.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
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

  ///
  ///  Updates the APNs push token.
  ///
  /// Param [token] The APNs push token.
  ///
  /// **Throws**  A description of the issue that caused this exception. See {@link EMError}
  ///
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
}
