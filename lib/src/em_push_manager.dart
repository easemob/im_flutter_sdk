import 'dart:io';

import 'internal/inner_headers.dart';

///
/// 推送设置管理类。
///
class EMPushManager {
  ///
  /// 从服务器获取推送设置信息。
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
  /// 更新推送通知收到时显示的昵称。
  ///
  /// 该昵称与用户信息中的昵称设置不同，我们建议这两种昵称的设置保持一致。更新用户属性昵称详见 [EMUserInfoManager.updateUserInfo]。
  ///
  /// Param [nickname] 推送通知收到时显示的昵称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 更新推送通知的展示方式。
  ///
  /// Param [displayStyle] 推送通知的展示方式。默认为 [DisplayStyle.Simple]。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 更新华为推送 token。
  ///
  /// Param [token] 要更新的华为推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 更新谷歌 FCM 推送 token。
  ///
  /// Param [token] 要更新的谷歌 FCM 推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 更新苹果推送（APNs）token。
  ///
  /// Param [token] 要更新的苹果推送（APNs）token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 设置会话消息免打扰数据。
  ///
  /// Param [conversationId] 会话Id。
  ///
  /// Param [type] 会话类型。
  ///
  /// Param [param]  免打扰数据参数模型，详见 [ChatSilentModeParam]。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 清除会话离线推送消息提醒类型设置。
  ///
  /// Param [conversationId] 会话Id。
  ///
  /// Param [type] 会话类型。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 获取会话消息免打扰数据。
  ///
  /// Param [conversationId] 会话Id。
  ///
  /// Param [type] 会话类型。
  ///
  /// **Return** 获取结果。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 设置全局消息免打扰数据。
  ///
  /// Param [param] 免打扰数据参数模型，详见 [ChatSilentModeParam]。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 获取全局消息免打扰数据。
  ///
  /// **Return** 获取结果。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 获取多个会话免打扰数据设置。
  ///
  /// 注意：一次最多20条数据。如果没设置过或者设置失效，则结果Map中不会返回该条数据。
  ///
  /// Param [conversations]  会话数组。
  ///
  /// **Return** 获取结果。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 设置推送消息的翻译语言。
  ///
  /// Param [languageCode] 翻译语言代码。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  ///  获取推送消息的翻译语言。
  ///
  /// **Return** 获取结果。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 设置离线推送模板。
  ///
  /// Param [pushTemplateName] 模板名称.
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 获取离线推送模板。
  ///
  /// **Return** 离线推送模板名称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 开启离线消息推送。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  ///
  @Deprecated("Use #setSilentModeForAll to instead")
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
  /// 关闭离线消息推送，即开启免打扰模式。
  ///
  /// Param [start] 免打扰开始时间，精确到小时。该时间为 24 小时制，取值范围为 [0~23]。
  ///
  /// Param [end] 免打扰结束时间，精确到小时。该时间为 24 小时制，取值范围为 [0~23]。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]
  ///
  @Deprecated("Use EMPushManager.setSilentModeForAll to instead")
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
  /// 从内存中获取关闭离线消息推送的群组。
  ///
  /// **return** 关闭了离线消息推送的群组。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
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
  /// 设置针对环信id设置推送
  ///
  /// [userIds]  免打扰用户列表。
  ///
  /// [enablePush] 是否开启推送。
  ///
  /// `true`: 开启;
  /// `false`: 关闭;
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  ///
  @Deprecated('Use EMPushManager.setConversationSilentMode to instead')
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

  ///
  /// 从内存中获取关闭离线消息推送的用户。
  ///
  /// **return** 关闭了离线消息推送的用户。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  ///
  @deprecated
  Future<List<String>> getNoPushUsersFromCache() async {
    Map result = await PushChannel.invokeMethod(ChatMethodKeys.getNoPushUsers);
    List<String> list = [];
    if (result.containsKey(ChatMethodKeys.getNoPushUsers)) {
      list = result[ChatMethodKeys.getNoPushUsers]?.cast<String>();
    }
    return list;
  }

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
  /// 设置指定群组的离线推送模式。
  ///
  /// [groupIds]  要设置的群组 ID 列表。
  ///
  /// [enablePush] 是否开启离线推送。
  /// - `true`：是。
  /// - `false`：否。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [EMError]。
  ///
  @Deprecated('Use EMPushManager.setConversationSilentMode to instead')
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
}
