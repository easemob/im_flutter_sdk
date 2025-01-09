import 'dart:io';

import 'internal/inner_headers.dart';

/// ~english
/// The message push configuration options.
/// ~end
///
/// ~chinese
/// 推送设置管理类。
/// ~end
class PushManager {
  /// ~english
  /// Gets the push configurations from the server.
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取推送设置信息。
  /// ~end
  Future<PushConfigs> fetchPushConfigsFromServer() async {
    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.getImPushConfigFromServer);
    try {
      Error.hasErrorFromResult(result);
      return PushConfigs.fromJson(
          result[ChatMethodKeys.getImPushConfigFromServer]);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Updates the push display nickname of the current user.
  ///
  /// This method can be used to set a push display nickname, the push display nickname will be used to show for offline push notification.
  /// When the app user changes the nickname in the user profile use [UserInfoManager.updateUserInfo]
  /// be sure to also call this method to update to prevent the display differences.
  ///
  /// Param [nickname] The push display nickname, which is different from the nickname in the user profile.
  ///
  /// **Throws** A description of the issue that caused this exception. See [Error]
  /// ~end
  ///
  /// ~chinese
  /// 更新推送通知收到时显示的昵称。
  ///
  /// 该昵称与用户信息中的昵称设置不同，我们建议这两种昵称的设置保持一致。更新用户属性昵称详见 [UserInfoManager.updateUserInfo]。
  ///
  /// Param [nickname] 推送通知收到时显示的昵称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> updatePushNickname(String nickname) async {
    Map req = {'nickname': nickname};
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.updatePushNickname, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Updates the push message display style. The default value is [DisplayStyle.Simple].
  ///
  /// Param [displayStyle] The push message display style.
  ///
  /// **Throws** A description of the issue that caused this exception. See [Error]
  /// ~end
  ///
  /// ~chinese
  /// 更新推送通知的展示方式。
  ///
  /// Param [displayStyle] 推送通知的展示方式。默认为 [DisplayStyle.Simple]。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> updatePushDisplayStyle(DisplayStyle displayStyle) async {
    Map req = {'pushStyle': displayStyle == DisplayStyle.Simple ? 0 : 1};
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.updateImPushStyle, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  @Deprecated("Use [bindDeviceToken] instead")

  /// ~english
  /// Updates the HMS push token.
  ///
  /// Param [token] The HMS push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [Error]
  /// ~end
  ///
  /// ~chinese
  /// 更新华为推送 token。
  ///
  /// Param [token] 要更新的华为推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> updateHMSPushToken(String token) async {
    if (Platform.isAndroid) {
      Map req = {'token': token};
      Map result = await PushChannel.invokeMethod(
          ChatMethodKeys.updateHMSPushToken, req);
      try {
        Error.hasErrorFromResult(result);
      } on Error catch (e) {
        throw e;
      }
    }
  }

  @Deprecated("Use [bindDeviceToken] instead")

  /// ~english
  /// Updates the FCM push token,
  ///
  /// Param [token] The FCM push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [Error]
  /// ~end
  ///
  /// ~chinese
  /// 更新谷歌 FCM 推送 token。
  ///
  /// Param [token] 要更新的谷歌 FCM 推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> updateFCMPushToken(String token) async {
    Map req = {'token': token};
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.updateFCMPushToken, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  @Deprecated("Use [bindDeviceToken] instead")

  /// ~english
  /// Updates the APNs push token.
  ///
  /// Param [token] The APNs push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [Error]
  /// ~end
  ///
  /// ~chinese
  /// 更新苹果推送（APNs）token。
  ///
  /// Param [token] 要更新的苹果推送（APNs）token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> updateAPNsDeviceToken(String token) async {
    if (Platform.isIOS) {
      Map req = {'token': token};
      Map result = await PushChannel.invokeMethod(
          ChatMethodKeys.updateAPNsPushToken, req);
      try {
        Error.hasErrorFromResult(result);
      } on Error catch (e) {
        throw e;
      }
    }
  }

  /// ~english
  /// bind the push token.
  ///
  /// Param [deviceToken] The push deviceToken.
  ///
  /// **Throws** A description of the issue that caused this exception. See [Error]
  /// ~end
  ///
  /// ~chinese
  /// 更新推送 token。
  ///
  /// Param [deviceToken] 要更新的推送 deviceToken
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> bindDeviceToken(
      {required String notifierName, required String deviceToken}) async {
    Map req = {'notifierName': notifierName, 'deviceToken': deviceToken};
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.bindDeviceToken, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Sets the push notifications for a conversation.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type.
  ///
  /// Param [param]  The offline push parameters.
  ///
  /// **Throws** A description of the exception. See [Error].
  ///
  /// ~end
  ///
  /// ~chinese
  /// 设置指定会话的离线推送设置。
  ///
  /// Param [conversationId] 会话 ID.
  ///
  /// Param [type] 会话类型.
  ///
  /// Param [param]  离线推送参数.
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> setConversationSilentMode({
    required String conversationId,
    required ConversationType type,
    required ChatSilentModeParam param,
  }) async {
    Map req = {};
    req["conversationId"] = conversationId;
    req["conversationType"] = type.index;
    req["param"] = param.toJson();

    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.setConversationSilentMode, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Removes the offline push notification settings for a conversation.
  ///
  /// After the setting is deleted, the conversation follows the setting of [PushManager.setSilentModeForAll] of the current logged-in user.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 删除指定会话的离线推送通知设置。
  ///
  /// 清除后，会话遵循当前登录用户的设置 [PushManager.setSilentModeForAll]。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> removeConversationSilentMode({
    required String conversationId,
    required ConversationType type,
  }) async {
    Map req = {};
    req["conversationId"] = conversationId;
    req["conversationType"] = type.index;
    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.removeConversationSilentMode, req);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the offline push settings of a conversation.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type.
  ///
  /// **Return** The offline push settings of the conversation.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 获取指定会话的离线推送设置。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型。
  ///
  /// **Return** 会话的离线推送设置。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<ChatSilentModeResult> fetchConversationSilentMode({
    required String conversationId,
    required ConversationType type,
  }) async {
    Map req = {};
    req["conversationId"] = conversationId;
    req["conversationType"] = type.index;
    Map result = await PushChannel.invokeMethod(
        ChatMethodKeys.fetchConversationSilentMode, req);
    try {
      Error.hasErrorFromResult(result);
      Map map = result[ChatMethodKeys.fetchConversationSilentMode];
      return ChatSilentModeResult.fromJson(map);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Sets the offline push settings at the app level for the current login user.
  ///
  /// Param [param] The offline push parameters.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 设置当前登录用户的 app 级别的推送设置。
  ///
  /// Param [param] 离线推送参数。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
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
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the offline push settings at the app level for the current login user.
  ///
  /// **Return** The offline push settings settings.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 获取当前登录用户的 app 级别的推送通知设置。
  ///
  /// **Return** 推送通知设置。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<ChatSilentModeResult> fetchSilentModeForAll() async {
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.fetchSilentModeForAll);
    try {
      Error.hasErrorFromResult(result);
      return ChatSilentModeResult.fromJson(
        result[ChatMethodKeys.fetchSilentModeForAll],
      );
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the offline push settings of specified conversations.
  ///
  /// Param [conversations]  The conversation list.
  ///
  /// **Return** The key is the conversation ID and the value is offline push settings.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 批量获取指定会话的推送通知设置。
  ///
  /// Param [conversations] 会话列表。
  ///
  /// **Return** 键为会话 ID，值为离线推送设置。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<Map<String, ChatSilentModeResult>> fetchSilentModeForConversations(
    List<Conversation> conversations,
  ) async {
    Map<String, int> req = {};
    for (var item in conversations) {
      req[item.id] = item.type.index;
    }
    Map result = await PushChannel.invokeMethod(
      ChatMethodKeys.fetchSilentModeForConversations,
      req,
    );
    try {
      Error.hasErrorFromResult(result);
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
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Sets the preferred language for push notifications.
  ///
  /// Param [languageCode] The language code.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 设置用户推送翻译语言。
  ///
  /// Param [languageCode] 语言代码。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> setPreferredNotificationLanguage(String languageCode) async {
    Map req = {"code": languageCode};
    Map result = await PushChannel.invokeMethod(
      ChatMethodKeys.setPreferredNotificationLanguage,
      req,
    );
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the preferred language for push notifications.
  ///
  /// **Return** The language code.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 获取用户设置的推送翻译语言。
  ///
  /// **Return** 设置的语言代码。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<String?> fetchPreferredNotificationLanguage() async {
    Map result = await PushChannel.invokeMethod(
      ChatMethodKeys.fetchPreferredNotificationLanguage,
    );
    try {
      Error.hasErrorFromResult(result);
      String? ret = result[ChatMethodKeys.fetchPreferredNotificationLanguage];
      return ret;
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Sets the template for offline push notifications.
  ///
  /// Param [pushTemplateName] The push template name.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 设置离线推送模板。
  ///
  /// Param [pushTemplateName] 推送模板名称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> setPushTemplate(String pushTemplateName) async {
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.setPushTemplate, {
      "pushTemplateName": pushTemplateName,
    });
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }

  /// ~english
  /// Gets the template for offline push notifications.
  ///
  /// **Return** The push template name.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 获取推送模板名称。
  ///
  /// **Return** 推送模板名称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<String?> getPushTemplate() async {
    Map result = await PushChannel.invokeMethod(ChatMethodKeys.getPushTemplate);
    try {
      Error.hasErrorFromResult(result);
      String? ret = result[ChatMethodKeys.getPushTemplate];
      return ret;
    } on Error catch (e) {
      throw e;
    }
  }

  // 481

  /// ~english
  /// Get all conversations mute info from server.
  ///
  /// **Throws** A description of the exception. See [Error].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取所有会话免打扰。
  ///
  /// 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。回调`Error`为空则可以调用 [ChatManager.loadAllConversations] 方法重新获取会话列表刷新UI
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [Error]。
  /// ~end
  Future<void> syncConversationsSilentMode() async {
    Map result =
        await PushChannel.invokeMethod(ChatMethodKeys.syncSilentModels);
    try {
      Error.hasErrorFromResult(result);
    } on Error catch (e) {
      throw e;
    }
  }
}
