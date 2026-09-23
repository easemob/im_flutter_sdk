import 'dart:io';

import 'package:flutter/services.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk/src/tools/chat_log.dart';
import 'package:im_flutter_sdk_interface/im_flutter_sdk_interface.dart'
    as platform_interface;

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
    platform_interface.Client.instance.pushManager
        .updateNativeHandler((MethodCall call) async {
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

  /// ~english
  /// Binds the push token of the device.
  ///
  /// Param [deviceToken] The push token reported by the push service of the platform.
  ///
  /// Param [notifierName] The push credential of the platform. This parameter is required on
  /// Android and is ignored on iOS:
  /// - Android: the vendor push credential, for example the FCM Sender ID, the HUAWEI/Honor app
  ///   ID, the Xiaomi/Meizu app ID, the OPPO app key, or the vivo `appId#appKey`. It must not be
  ///   empty, otherwise the native SDK returns an invalid-parameter error;
  /// - iOS: not used. Set the APNs certificate name with [ChatOptions.apnsCertName] when the SDK
  ///   is initialized, because the certificate name cannot be changed at runtime.
  ///
  /// **Throws** A description of the issue that caused this exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 绑定设备的推送 token。
  ///
  /// Param [deviceToken] 平台推送服务返回的推送 token。
  ///
  /// Param [notifierName] 平台的推送凭据。Android 必填，iOS 忽略：
  /// - Android：厂商推送凭据，例如 FCM 的 Sender ID、华为/荣耀的 App ID、小米/魅族的 App ID、
  ///   OPPO 的 App Key、vivo 的 `appId#appKey`。不能为空，否则原生 SDK 返回参数非法错误；
  /// - iOS：不使用该参数。APNs 证书名称请在 SDK 初始化时通过 [ChatOptions.apnsCertName] 设置，
  ///   因为证书名称不支持运行时修改。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> bindDeviceToken(
      {required String deviceToken, String? notifierName}) async {
    try {
      Map req = {
        // Keep the key on every platform: iOS ignores it, and Android reports the native
        // invalid-parameter error instead of a missing-key error when it is empty.
        'notifierName': notifierName ?? '',
        'deviceToken': deviceToken,
      };
      Map result = await platform_interface.Client.instance.pushManager
          .callNativeMethod(ChatMethodKeys.bindDeviceToken, req);
      ChatError.hasErrorFromResult(result);
    } catch (e) {
      rethrow;
    }
  }

  // 5.0.0

  /// ~english
  /// Binds the Apple PushKit token, which is used for VoIP push notifications.
  ///
  /// This method is available on iOS only; on other platforms it does nothing.
  ///
  /// Param [deviceToken] The PushKit token reported by `PKPushRegistry`, in hexadecimal.
  ///
  /// The PushKit certificate name must be set with [ChatOptions.pushKitCertName] when the SDK is
  /// initialized, because the certificate name cannot be changed at runtime.
  ///
  /// The native SDK caches the token before binding it: if the current user is not logged in
  /// yet, this call fails with `ChatError`, but the token stays cached and is bound
  /// automatically after the next successful login. `ChatClient.logout` with
  /// `unbindDeviceToken: true` unbinds the PushKit token as well.
  ///
  /// **Throws** A description of the issue that caused this exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 绑定苹果 PushKit token，用于 VoIP 推送。
  ///
  /// 仅 iOS 平台有效，其他平台调用不做任何处理。
  ///
  /// Param [deviceToken] `PKPushRegistry` 回调返回的 PushKit token，十六进制字符串。
  ///
  /// PushKit 证书名称需要在 SDK 初始化时通过 [ChatOptions.pushKitCertName] 设置，
  /// 因为证书名称不支持运行时修改。
  ///
  /// 原生 SDK 会先缓存 token 再执行绑定：若此时当前用户尚未登录，本次调用会抛出 [ChatError]，
  /// 但 token 已缓存，下次登录成功后 SDK 会自动完成绑定。调用 `ChatClient.logout` 且
  /// `unbindDeviceToken` 为 `true` 时，会同时解绑 PushKit token。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> bindPushKitToken({required String deviceToken}) async {
    if (Platform.isIOS) {
      try {
        Map req = {'deviceToken': deviceToken};
        Map result = await platform_interface.Client.instance.pushManager
            .callNativeMethod(ChatMethodKeys.bindPushKitToken, req);
        ChatError.hasErrorFromResult(result);
      } catch (e) {
        rethrow;
      }
    } else {
      return;
    }
  }

  /// ~english
  /// Unbinds the Apple PushKit token bound by [bindPushKitToken].
  ///
  /// This method is available on iOS only; on other platforms it does nothing.
  ///
  /// `ChatClient.logout` with `unbindDeviceToken: true` already unbinds the PushKit token,
  /// so call this method only to unbind it while the current user stays logged in.
  ///
  /// **Throws** A description of the issue that caused this exception. See [ChatError]
  /// ~end
  ///
  /// ~chinese
  /// 解绑 [bindPushKitToken] 绑定的苹果 PushKit token。
  ///
  /// 仅 iOS 平台有效，其他平台调用不做任何处理。
  ///
  /// `ChatClient.logout` 且 `unbindDeviceToken` 为 `true` 时已经会同时解绑 PushKit token，
  /// 因此只有在当前用户保持登录状态、需要单独解绑时才需要调用本方法。
  ///
  /// **Throws** 如果有异常会在此抛出，包括错误码和错误信息，详见 [ChatError]。
  /// ~end

  Future<void> unbindPushKitToken() async {
    if (Platform.isIOS) {
      try {
        Map result = await platform_interface.Client.instance.pushManager
            .callNativeMethod(ChatMethodKeys.unbindPushKitToken);
        ChatError.hasErrorFromResult(result);
      } catch (e) {
        rethrow;
      }
    } else {
      return;
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
      Map result =
          await platform_interface.Client.instance.pushManager.callNativeMethod(
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
      Map result =
          await platform_interface.Client.instance.pushManager.callNativeMethod(
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
      Map result =
          await platform_interface.Client.instance.pushManager.callNativeMethod(
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
      Map result =
          await platform_interface.Client.instance.pushManager.callNativeMethod(
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
