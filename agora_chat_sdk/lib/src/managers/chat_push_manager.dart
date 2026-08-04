import 'dart:io';

import 'package:flutter/services.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:agora_chat_sdk/src/tools/chat_log.dart';
import 'package:agora_chat_sdk_interface/agora_chat_sdk_interface.dart' as platform_interface;

/// ~english
/// The message push configuration options.
/// ~end
///
/// ~chinese
/// 推送设置管理类。
/// ~end
class ChatPushManager {
  /// ~english
  /// Gets the push configurations from the server.
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取推送设置信息。
  /// ~end

  ChatPushManager() {
    platform_interface.Client.instance.pushManager.updateNativeHandler((MethodCall call) async {
      ChatLog.d("${call.method}: arguments: ${call.arguments}");
    });
  }

  Future<ChatPushConfigs> fetchPushConfigsFromServer() async {
    try {
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.getImPushConfigFromServer);
      ChatError.hasErrorFromResult(result);
      return ChatPushConfigs.fromJson(
          result[ChatMethodKeys.getImPushConfigFromServer]);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Updates the push display nickname of the current user.
  ///
  /// This method can be used to set a push display nickname, the push display nickname will be used to show for offline push notification.
  /// When the app user changes the nickname in the user profile use [ChatUserInfoManager.updateUserInfo]
  /// be sure to also call this method to update to prevent the display differences.
  ///
  /// Param [nickname] The push display nickname, which is different from the nickname in the user profile.
  ///
  /// **Throws** A description of the issue that caused this exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 更新推送通知收到时显示的昵称。
  ///
  /// 该昵称与用户信息中的昵称设置不同，我们建议这两种昵称的设置保持一致。更新用户属性昵称详见 [ChatUserInfoManager.updateUserInfo]。
  ///
  /// Param [nickname] 推送通知收到时显示的昵称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> updatePushNickname(String nickname) async {
    try {
      Map req = {'nickname': nickname};
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.updatePushNickname, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Updates the push message display style. The default value is [DisplayStyle.Simple].
  ///
  /// Param [displayStyle] The push message display style.
  ///
  /// **Throws** A description of the issue that caused this exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 更新推送通知的展示方式。
  ///
  /// Param [displayStyle] 推送通知的展示方式。默认为 [DisplayStyle.Simple]。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> updatePushDisplayStyle(DisplayStyle displayStyle) async {
    try {
      Map req = {'pushStyle': displayStyle == DisplayStyle.Simple ? 0 : 1};
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.updateImPushStyle, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated("Use [bindDeviceToken] instead")

  /// ~english
  /// Updates the HMS push token.
  ///
  /// Param [token] The HMS push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 更新华为推送 token。
  ///
  /// Param [token] 要更新的华为推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end
  Future<void> updateHMSPushToken(String token) async {
    if (Platform.isAndroid) {
      try {
        Map req = {'token': token};
        Map result = await platform_interface.Client.instance.pushManager
            .callNativeMethod(ChatMethodKeys.updateHMSPushToken, req);
        ChatError.hasErrorFromResult(result);
      } catch (e) {
        rethrow;
      }
    } else {
      return;
    }
  }

  @Deprecated("Use [bindDeviceToken] instead")

  /// ~english
  /// Updates the FCM push token,
  ///
  /// Param [token] The FCM push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 更新谷歌 FCM 推送 token。
  ///
  /// Param [token] 要更新的谷歌 FCM 推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end
  Future<void> updateFCMPushToken(String token) async {
    try {
      Map req = {'token': token};
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.updateFCMPushToken, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  @Deprecated("Use [bindDeviceToken] instead")

  /// ~english
  /// Updates the APNs push token.
  ///
  /// Param [token] The APNs push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 更新苹果推送（APNs）token。
  ///
  /// Param [token] 要更新的苹果推送（APNs）token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end
  Future<void> updateAPNsDeviceToken(String token) async {
    if (Platform.isIOS) {
      try {
        Map req = {'token': token};
        Map result = await platform_interface.Client.instance.pushManager
            .callNativeMethod(ChatMethodKeys.updateAPNsPushToken, req);
        ChatError.hasErrorFromResult(result);
      } catch (e) {
        rethrow;
      }
    } else {
      return;
    }
  }

  /// ~english
  /// bind the push token.
  ///
  /// Param [token] The push token.
  ///
  /// **Throws** A description of the issue that caused this exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 更新推送 token。
  ///
  /// Param [token] 要更新的推送 token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> bindDeviceToken(
      {required String notifierName, required String deviceToken}) async {
    try {
      Map req = {'notifierName': notifierName, 'deviceToken': deviceToken};
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.bindDeviceToken, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> setConversationSilentMode({
    required String conversationId,
    required ChatConversationType type,
    required ChatSilentModeParam param,
  }) async {
    try {
      Map req = {};
      req["convId"] = conversationId;
      req["conversationType"] = type.index;
      req["param"] = param.toJson();

      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.setConversationSilentMode, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Removes the offline push notification settings for a conversation.
  ///
  /// After the setting is deleted, the conversation follows the setting of [ChatPushManager.setSilentModeForAll] of the current logged-in user.
  ///
  /// Param [conversationId] The conversation ID.
  ///
  /// Param [type] The conversation type.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 删除指定会话的离线推送通知设置。
  ///
  /// 清除后，会话遵循当前登录用户的设置 [ChatPushManager.setSilentModeForAll]。
  ///
  /// Param [conversationId] 会话 ID。
  ///
  /// Param [type] 会话类型。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> removeConversationSilentMode({
    required String conversationId,
    required ChatConversationType type,
  }) async {
    try {
      Map req = {};
      req["convId"] = conversationId;
      req["conversationType"] = type.index;
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.removeConversationSilentMode, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
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
  /// **Throws** A description of the exception. See [ChatError].
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
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<ChatSilentModeResult> fetchConversationSilentMode({
    required String conversationId,
    required ChatConversationType type,
  }) async {
    try {
      Map req = {};
      req["convId"] = conversationId;
      req["conversationType"] = type.index;
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.fetchConversationSilentMode, req);
      ChatError.hasErrorFromResult(result);
      Map map = result[ChatMethodKeys.fetchConversationSilentMode];
      return ChatSilentModeResult.fromJson(map);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Sets the offline push settings at the app level for the current login user.
  ///
  /// Param [param] The offline push parameters.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 设置当前登录用户的 app 级别的推送设置。
  ///
  /// Param [param] 离线推送参数。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> setSilentModeForAll({
    required ChatSilentModeParam param,
  }) async {
    try {
      Map req = {};
      req["param"] = param.toJson();
      Map result = await platform_interface.Client.instance.pushManager.callNativeMethod(
        ChatMethodKeys.setSilentModeForAll,
        req,
      );
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the offline push settings at the app level for the current login user.
  ///
  /// **Return** The offline push settings settings.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取当前登录用户的 app 级别的推送通知设置。
  ///
  /// **Return** 推送通知设置。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<ChatSilentModeResult> fetchSilentModeForAll() async {
    try {
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.fetchSilentModeForAll);
      ChatError.hasErrorFromResult(result);
      return ChatSilentModeResult.fromJson(
        result[ChatMethodKeys.fetchSilentModeForAll],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the offline push settings of specified conversations.
  ///
  /// Param [conversations]  The conversation list.
  ///
  /// **Return** The key is the conversation ID and the value is offline push settings.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 批量获取指定会话的推送通知设置。
  ///
  /// Param [conversations] 会话列表。
  ///
  /// **Return** 键为会话 ID，值为离线推送设置。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<Map<String, ChatSilentModeResult>> fetchSilentModeForConversations(
    List<ChatConversation> conversations,
  ) async {
    try {
      Map<String, int> req = {};
      for (var item in conversations) {
        req[item.id] = item.type.index;
      }
      Map result = await platform_interface.Client.instance.pushManager.callNativeMethod(
        ChatMethodKeys.fetchSilentModeForConversations,
        req,
      );
      ChatError.hasErrorFromResult(result);
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
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Sets the preferred language for push notifications.
  ///
  /// Param [languageCode] The language code.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 设置用户推送翻译语言。
  ///
  /// Param [languageCode] 语言代码。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> setPreferredNotificationLanguage(String languageCode) async {
    try {
      Map req = {"code": languageCode};
      Map result = await platform_interface.Client.instance.pushManager.callNativeMethod(
        ChatMethodKeys.setPreferredNotificationLanguage,
        req,
      );
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the preferred language for push notifications.
  ///
  /// **Return** The language code.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取用户设置的推送翻译语言。
  ///
  /// **Return** 设置的语言代码。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<String?> fetchPreferredNotificationLanguage() async {
    try {
      Map result = await platform_interface.Client.instance.pushManager.callNativeMethod(
        ChatMethodKeys.fetchPreferredNotificationLanguage,
      );
      ChatError.hasErrorFromResult(result);
      String? ret = result[ChatMethodKeys.fetchPreferredNotificationLanguage];
      return ret;
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Sets the template for offline push notifications.
  ///
  /// Param [pushTemplateName] The push template name.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 设置离线推送模板。
  ///
  /// Param [pushTemplateName] 推送模板名称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> setPushTemplate(String pushTemplateName) async {
    try {
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.setPushTemplate, {
        "pushTemplateName": pushTemplateName,
      });
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  /// ~english
  /// Gets the template for offline push notifications.
  ///
  /// **Return** The push template name.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 获取推送模板名称。
  ///
  /// **Return** 推送模板名称。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<String?> getPushTemplate() async {
    try {
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.getPushTemplate);
      ChatError.hasErrorFromResult(result);
      String? ret = result[ChatMethodKeys.getPushTemplate];
      return ret;
    } catch (e) {
      rethrow;
    }
  }

  // 481

  /// ~english
  /// Get all conversations mute info from server.
  ///
  /// **Throws** A description of the exception. See [ChatError].
  /// ~end
  ///
  /// ~chinese
  /// 从服务器获取所有会话免打扰。
  ///
  /// 该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。回调`ChatError`为空则可以调用 [ChatManager.loadAllConversations] 方法重新获取会话列表刷新UI
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> syncConversationsSilentMode() async {
    try {
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.syncSilentModels);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }
}
