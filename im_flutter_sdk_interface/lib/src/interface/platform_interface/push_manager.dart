import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart';
import 'package:im_flutter_sdk_interface/src/interface/manager_mixin.dart';

class PushManager with ManagerMixin {
  @override
  void initHandler() {}

  /// ~english
  /// Gets the push configurations from the server.
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取推送设置信息。
  /// ~end
  Future<EMPushConfigs> fetchPushConfigsFromServer() async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Updates the push display nickname of the current user.
  ///
  /// This method can be used to set a push display nickname, the push display nickname will be used to show for offline push notification.
  /// When the app user changes the nickname in the user profile use [EMUserInfoManager.updateUserInfo]
  /// be sure to also call this method to update to prevent the display differences.
  ///
  /// Param [nickname] The push display nickname, which is different from the nickname in the user profile.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  /// ~end
  ///
  /// ~chinese
  /// 更新推送通知收到时显示的昵称。
  ///
  /// 该昵称与用户信息中的昵称设置不同，我们建议这两种昵称的设置保持一致。更新用户属性昵称详见 [EMUserInfoManager.updateUserInfo]。
  ///
  /// Param [nickname] 推送通知收到时显示的昵称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> updatePushNickname(String nickname) async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Updates the push message display style. The default value is [DisplayStyle.Simple].
  ///
  /// Param [displayStyle] The push message display style.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  /// ~end
  ///
  /// ~chinese
  /// 更新推送通知的展示方式。
  ///
  /// Param [displayStyle] 推送通知的展示方式。默认为 [DisplayStyle.Simple]。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> updatePushDisplayStyle(DisplayStyle displayStyle) async {
    throw UnimplementedError("not implemented");
  }

  @Deprecated("Use [bindDeviceToken] instead")

  /// ~english
  /// Updates the HMS push token.
  ///
  /// Param [token] The HMS push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  /// ~end
  ///
  /// ~chinese
  /// 更新华为推送 token。
  ///
  /// Param [token] 要更新的华为推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> updateHMSPushToken(String token) async {
    throw UnimplementedError("not implemented");
  }

  @Deprecated("Use [bindDeviceToken] instead")

  /// ~english
  /// Updates the FCM push token,
  ///
  /// Param [token] The FCM push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  /// ~end
  ///
  /// ~chinese
  /// 更新谷歌 FCM 推送 token。
  ///
  /// Param [token] 要更新的谷歌 FCM 推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> updateFCMPushToken(String token) async {
    throw UnimplementedError("not implemented");
  }

  @Deprecated("Use [bindDeviceToken] instead")

  /// ~english
  /// Updates the APNs push token.
  ///
  /// Param [token] The APNs push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  /// ~end
  ///
  /// ~chinese
  /// 更新苹果推送（APNs）token。
  ///
  /// Param [token] 要更新的苹果推送（APNs）token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> updateAPNsDeviceToken(String token) async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// bind the push token.
  ///
  /// Param [token] The push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [EMError]
  /// ~end
  ///
  /// ~chinese
  /// 更新推送 token。
  ///
  /// Param [token] 要更新的推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> bindDeviceToken(
      {required String notifierName, required String deviceToken}) async {
    throw UnimplementedError("not implemented");
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> setConversationSilentMode({
    required String conversationId,
    required EMConversationType type,
    required ChatSilentModeParam param,
  }) async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Removes the offline push notification settings for a conversation.
  ///
  /// After the setting is deleted, the conversation follows the setting of [EMPushManager.setSilentModeForAll] of the current logged-in user.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 删除指定会话的离线推送通知设置。
  ///
  /// 清除后，会话遵循当前登录用户的设置 [EMPushManager.setSilentModeForAll]。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> removeConversationSilentMode({
    required String conversationId,
    required EMConversationType type,
  }) async {
    throw UnimplementedError("not implemented");
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
  /// **Throws** A description of the exception. See [EMError].
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<ChatSilentModeResult> fetchConversationSilentMode({
    required String conversationId,
    required EMConversationType type,
  }) async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Sets the offline push settings at the app level for the current login user.
  ///
  /// Param [param] The offline push parameters.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 设置当前登录用户的 app 级别的推送设置。
  ///
  /// Param [param] 离线推送参数。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> setSilentModeForAll({
    required ChatSilentModeParam param,
  }) async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Gets the offline push settings at the app level for the current login user.
  ///
  /// **Return** The offline push settings settings.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取当前登录用户的 app 级别的推送通知设置。
  ///
  /// **Return** 推送通知设置。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<ChatSilentModeResult> fetchSilentModeForAll() async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Gets the offline push settings of specified conversations.
  ///
  /// Param [conversations]  The conversation list.
  ///
  /// **Return** The key is the conversation ID and the value is offline push settings.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 批量获取指定会话的推送通知设置。
  ///
  /// Param [conversations] 会话列表。
  ///
  /// **Return** 键为会话 ID，值为离线推送设置。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<Map<String, ChatSilentModeResult>> fetchSilentModeForConversations(
    List<EMConversation> conversations,
  ) async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Sets the preferred language for push notifications.
  ///
  /// Param [languageCode] The language code.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 设置用户推送翻译语言。
  ///
  /// Param [languageCode] 语言代码。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> setPreferredNotificationLanguage(String languageCode) async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Gets the preferred language for push notifications.
  ///
  /// **Return** The language code.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取用户设置的推送翻译语言。
  ///
  /// **Return** 设置的语言代码。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<String?> fetchPreferredNotificationLanguage() async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Sets the template for offline push notifications.
  ///
  /// Param [pushTemplateName] The push template name.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 设置离线推送模板。
  ///
  /// Param [pushTemplateName] 推送模板名称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> setPushTemplate(String pushTemplateName) async {
    throw UnimplementedError("not implemented");
  }

  /// ~english
  /// Gets the template for offline push notifications.
  ///
  /// **Return** The push template name.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 获取推送模板名称。
  ///
  /// **Return** 推送模板名称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<String?> getPushTemplate() async {
    throw UnimplementedError("not implemented");
  }

  // 481

  /// ~english
  /// Get all conversations mute info from server.
  ///
  /// **Throws** A description of the exception. See [EMError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取所有会话免打扰。
  ///
  /// 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。回调`EMError`为空则可以调用 [EMChatManager.loadAllConversations] 方法重新获取会话列表刷新UI
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  /// ~end
  Future<void> syncConversationsSilentMode() async {
    throw UnimplementedError("not implemented");
  }
}
