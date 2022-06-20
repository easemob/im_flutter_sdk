import 'package:flutter/services.dart';

import '../internal/chat_method_keys.dart';
import '../tools/em_extension.dart';
import 'em_chat_enums.dart';
import 'em_error.dart';
import '../em_push_manager.dart';

/// The push configuration class.
class EMPushConfigs {
  EMPushConfigs._private({
    this.displayStyle = DisplayStyle.Simple,
    this.noDisturb = false,
    this.noDisturbStartHour = -1,
    this.noDisturbEndHour = -1,
  });

  ///
  /// The display type of push notifications.
  ///
  final DisplayStyle displayStyle;

  ///
  /// Whether to enable the do-not-disturb mode for push notifications.
  /// - `true`: Yes.
  /// - `false`: No.
  ///  Sets it by {@link EMPushManager#disableOfflinePush(int, int)}.
  ///
  final bool noDisturb;

  ///
  /// The start hour of the do-not-disturb mode for push notifications.
  ///
  final int noDisturbStartHour;

  ///
  /// The end hour of the do-not-disturb mode for push notifications.
  ///
  final int noDisturbEndHour;

  // ignore: unused_field
  DisplayStyle? _displayStyle;
  // ignore: unused_field
  bool? _noDisturb;
  // ignore: unused_field
  int? _noDisturbStartHour;
  // ignore: unused_field
  int? _noDisturbEndHour;
  // ignore: unused_field
  List<String>? _noDisturbGroups = [];

  /// @nodoc
  factory EMPushConfigs.fromJson(Map map) {
    return EMPushConfigs._private(
      displayStyle:
          map['pushStyle'] == 0 ? DisplayStyle.Simple : DisplayStyle.Summary,
      noDisturb: map.boolValue('noDisturb'),
      noDisturbStartHour: map['noDisturbStartHour'],
      noDisturbEndHour: map['noDisturbEndHour'],
    );
  }
}

/// @nodoc
extension EMPushConfigsExtension on EMPushConfigs {
  // channel的命名与pushManager中的channel一致，本质上还是一个channel。
  static const MethodChannel _channel =
      const MethodChannel('com.chat.im/chat_push_manager', JSONMethodCodec());

  @Deprecated(
      "Switch to using EMPushManager#enableOfflinePush and EMPushManager#disableOfflinePush instead")
  Future<void> setNoDisturb(
    bool isNoDisturb, {
    int startTime = 0,
    int endTime = 24,
  }) async {
    if (startTime < 0) startTime = 0;
    if (endTime > 24) endTime = 24;
    Map req = {
      'noDisturb': isNoDisturb,
      'startTime': startTime,
      'endTime': endTime
    };
    Map result = await _channel.invokeMethod("imPushNoDisturb", req);
    try {
      EMError.hasErrorFromResult(result);
      bool success = result.boolValue("imPushNoDisturb");
      if (success) {
        _noDisturb = isNoDisturb;
        _noDisturbStartHour = startTime;
        _noDisturbEndHour = endTime;
      }
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated("Switch to using EMPushManager#updatePushDisplayStyle instead")
  Future<void> setPushStyle(EMPushStyle pushStyle) async {
    Map req = {'pushStyle': pushStyle == EMPushStyle.Simple ? 0 : 1};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateImPushStyle, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated("Switch to using EMPushManager#updatePushServiceForGroup instead")
  Future<void> setGroupToDisturb(
    String groupId,
    bool isNoDisturb,
  ) async {
    Map req = {'noDisturb': isNoDisturb, 'group_id': groupId};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateGroupPushService, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  @Deprecated("Switch to using EMPushManager#getNoPushGroups instead")
  Future<List<String>> noDisturbGroupsFromServer() async {
    Map result = await _channel.invokeMethod("getNoDisturbGroups");
    try {
      EMError.hasErrorFromResult(result);
      List<String> list = [];
      result["getNoDisturbGroups"]?.forEach((element) {
        if (element is String) {
          list.add(element);
        }
      });
      return list;
    } on EMError catch (e) {
      throw e;
    }
  }
}
