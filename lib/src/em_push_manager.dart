import 'dart:io';

import 'internal/inner_headers.dart';

///
/// The message push configuration options.
///
class EMPushManager {
  @deprecated
  Future<EMPushConfigs?> getPushConfigsFromCache() async {
    Map result = await PushChannel.invokeMethod(ChatMethodKeys.getImPushConfig);
    try {
      EMError.hasErrorFromResult(result);
      return EMPushConfigs.fromJson(result[ChatMethodKeys.getImPushConfig]);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the push configurations from the server.
  ///
  Future<EMPushConfigs> fetchPushConfigsFromServer() async {
    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.getImPushConfigFromServer);
    try {
      EMError.hasErrorFromResult(result);
      return EMPushConfigs.fromJson(
          result[ChatMethodKeys.getImPushConfigFromServer]);
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
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  @deprecated
  Future<void> updatePushServiceForGroup({
    required List<String> groupIds,
    required bool enablePush,
  }) async {
    Map req = {'noPush': !enablePush, 'group_ids': groupIds};
    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.updateGroupPushService, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the list of users which have blocked the push notification.
  ///
  /// **return** The list of user that blocked the push notification.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  @Deprecated('')
  Future<List<String>> getNoPushUsersFromCache() async {
    Map result = await PushChannel.invokeMethod(ChatMethodKeys.getNoPushUsers);
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
  /// When the app user changes the nickname in the user profile use [EMUserInfoManager.updateUserInfo]
  /// be sure to also call this method to update to prevent the display differences.
  ///
  /// Param [nickname] The push display nickname, which is different from the nickname in the user profile.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  Future<void> updatePushNickname(String nickname) async {
    Map req = {'nickname': nickname};
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.updatePushNickname, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Updates the push message style. The default value is [DisplayStyle.Simple].
  ///
  /// Param [displayStyle] The push message display style.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  Future<void> updatePushDisplayStyle(DisplayStyle displayStyle) async {
    Map req = {'pushStyle': displayStyle == DisplayStyle.Simple ? 0 : 1};
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.updateImPushStyle, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Updates the HMS push token.
  ///
  /// Param [token] The HMS push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  Future<void> updateHMSPushToken(String token) async {
    if (Platform.isAndroid) {
      Map req = {'token': token};
      Map result = await PushChannel.invokeMethod(
          ChatMethodKeys.updateHMSPushToken, req);
      try {
        EMError.hasErrorFromResult(result);
      } on EMError catch (e) {
        throw e;
      }
    }
  }

  ///
  /// Updates the FCM push token.
  ///
  /// Param [token] The FCM push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  Future<void> updateFCMPushToken(String token) async {
    if (Platform.isAndroid) {
      Map req = {'token': token};
      Map result = await PushChannel.invokeMethod(
          ChatMethodKeys.updateFCMPushToken, req);
      try {
        EMError.hasErrorFromResult(result);
      } on EMError catch (e) {
        throw e;
      }
    }
  }

  ///
  /// Updates the APNs push token.
  ///
  /// Param [token] The APNs push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  Future<void> updateAPNsDeviceToken(String token) async {
    if (Platform.isIOS) {
      Map req = {'token': token};
      Map result = await PushChannel.invokeMethod(
          ChatMethodKeys.updateAPNsPushToken, req);
      try {
        EMError.hasErrorFromResult(result);
      } on EMError catch (e) {
        throw e;
      }
    }
  }

  // Future<void> reportPushAction(
  //   {String taskId,
  //   String provider,
  //   String action,}
  // ) async {
  //   Map req = {};
  // }

  ///
  /// Set offline push notification type for the special conversation.
  ///
  /// Param [conversationId] The conversation id.
  ///
  /// Param [type] The conversation type.
  ///
  /// Param [param]  Push DND parameters offline.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  ///
  Future<void> setConversationSilentMode({
    required String conversationId,
    required EMConversationType type,
    required ChatSilentModeParam param,
  }) async {
    Map req = {};
    req["conversationId"] = conversationId;
    req["conversationType"] = conversationTypeToInt(type);
    req["param"] = param.toJson();

    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.setConversationSilentMode, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Remove the setting of offline push notification type for the special conversation.
  /// After clearing, the session follows the Settings of the current logged-in user  [EMPushManager.setSilentModeForAll].
  ///
  /// Param [conversationId] The conversation id.
  ///
  /// Param [type] The conversation type.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> removeConversationSilentMode({
    required String conversationId,
    required EMConversationType type,
  }) async {
    Map req = {};
    req["conversationId"] = conversationId;
    req["conversationType"] = conversationTypeToInt(type);
    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.removeConversationSilentMode, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the DND setting of the special conversation.
  ///
  /// Param [conversationId] The conversation id.
  ///
  /// Param [type] The conversation type.
  ///
  /// **Return** The conversation silent mode.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<ChatSilentModeResult> fetchConversationSilentMode({
    required String conversationId,
    required EMConversationType type,
  }) async {
    Map req = {};
    req["conversationId"] = conversationId;
    req["conversationType"] = conversationTypeToInt(type);
    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.fetchConversationSilentMode, req);
    try {
      EMError.hasErrorFromResult(result);
      Map map = result[ChatMethodKeys.fetchConversationSilentMode];
      return ChatSilentModeResult.fromJson(map);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Set the DND normal settings for the current login user.
  ///
  /// Param [param] Push DND parameters offline.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> setSilentModeForAll({
    required ChatSilentModeParam param,
  }) async {
    Map req = {};
    req["param"] = param.toJson();
    Map result = await PushChannel.invokeMethod(
      ChatMethodKeys.setSilentModeForAll,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the DND normal settings of the current login user.
  ///
  /// **Return** The normal silent mode.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<ChatSilentModeResult> fetchSilentModeForAll() async {
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.fetchSilentModeForAll);
    try {
      EMError.hasErrorFromResult(result);
      return ChatSilentModeResult.fromJson(
        result[ChatMethodKeys.fetchSilentModeForAll],
      );
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Obtain the DND Settings of specified conversations in batches.
  ///
  /// Param [conversations]  The conversation list.
  ///
  /// **Return** key is conversation id and the value is silent mode.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<Map<String, ChatSilentModeResult>> fetchSilentModeForConversations(
    List<EMConversation> conversations,
  ) async {
    Map<String, int> req = {};
    for (var item in conversations) {
      req[item.id] = conversationTypeToInt(item.type);
    }
    Map result = await PushChannel.invokeMethod(
      ChatMethodKeys.fetchSilentModeForConversations,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
      Map<String, ChatSilentModeResult> ret = {};
      Map? tmpMap = result[ChatMethodKeys.fetchSilentModeForConversations];
      if (tmpMap != null) {
        for (var item in tmpMap.entries) {
          if (item.key is String && item.value is Map) {
            ret[item.key] = ChatSilentModeResult.fromJson(item.value);
          }
        }
      }
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Set user push translation language.
  ///
  /// Param [languageCode] language code.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> setPreferredNotificationLanguage(String languageCode) async {
    Map req = {"code": languageCode};
    Map result = await PushChannel.invokeMethod(
      ChatMethodKeys.setPreferredNotificationLanguage,
      req,
    );
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the push translation language set by the user.
  ///
  /// **Return** has set language code.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<String?> fetchPreferredNotificationLanguage() async {
    Map result = await PushChannel.invokeMethod(
      ChatMethodKeys.fetchPreferredNotificationLanguage,
    );
    try {
      EMError.hasErrorFromResult(result);
      String? ret = result[ChatMethodKeys.fetchPreferredNotificationLanguage];
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Set the push template for offline push.
  ///
  /// Param [pushTemplateName] push template name.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<void> setPushTemplate(String pushTemplateName) async {
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.setPushTemplate, {
      "pushTemplateName": pushTemplateName,
    });
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the offline push template for Settings.
  ///
  /// **Return** The push template name.
  ///
  /// **Throws** A description of the exception. See [EMError].
  ///
  Future<String?> getPushTemplate() async {
    Map result = await PushChannel.invokeMethod(ChatMethodKeys.getPushTemplate);
    try {
      EMError.hasErrorFromResult(result);
      String? ret = result[ChatMethodKeys.getPushTemplate];
      return ret;
    } on EMError catch (e) {
      throw e;
    }
  }
}

extension EMPushManagerDeprecated on EMPushManager {
  ///
  /// Turns on the push notification.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  @Deprecated("Use #setSilentModeForAll to instead.")
  Future<void> enableOfflinePush() async {
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.enableOfflinePush);
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
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  @Deprecated("Use #setSilentModeForAll to instead.")
  Future<void> disableOfflinePush({
    required int start,
    required int end,
  }) async {
    Map req = {'start': start, 'end': end};
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.disableOfflinePush, req);
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
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///

  @deprecated
  Future<List<String>> getNoPushGroupsFromCache() async {
    Map result = await PushChannel.invokeMethod(ChatMethodKeys.getNoPushGroups);
    List<String> list = [];
    if (result.containsKey(ChatMethodKeys.getNoPushGroups)) {
      list = result[ChatMethodKeys.getNoPushGroups]?.cast<String>();
    }
    return list;
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
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  ///
  @Deprecated('Use EMPushManager#setConversationSilentMode to instead.')
  Future<void> updatePushServiceFroUsers({
    required List<String> userIds,
    required bool enablePush,
  }) async {
    Map req = {'noPush': !enablePush, 'user_ids': userIds};
    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.updateUserPushService, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }
}
