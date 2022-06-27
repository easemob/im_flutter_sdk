import 'dart:async';
import 'package:flutter/services.dart';

import 'internal/inner_headers.dart';

///
/// 用户属性类，用于获取和更新用户属性。
///
class EMUserInfoManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_userInfo_manager', JSONMethodCodec());

  EMUserInfo? _ownUserInfo;

  Map<String, EMUserInfo> _effectiveUserInfoMap = Map();

  ///
  /// 修改当前用户的属性信息。
  ///
  /// Param [userInfo] 要修改的用户属性信息。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 {@link EMError}。
  ///
  Future<void> updateUserInfo(EMUserInfo userInfo) async {
    Map req = {'userInfo': userInfo.toJson()};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.updateOwnUserInfo, req);
    try {
      EMError.hasErrorFromResult(result);
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// 获取当前用户的属性信息。
  ///
  /// Param [expireTime] 获取的用户属性到期时间。如果在到期时间内再次调用该方法，则 SDK 直接返回上次获取到的缓存数据。例如，将该参数设为 120，即 2 分钟，则如果你在 2 分钟内再次调用该方法获取用户属性，SDK 仍将返回上次获取到的属性。否则需从服务器获取。
  ///
  /// **Return** 用户属性。请参见 {@link EMUserInfo}。
  ///
  /// **Throws**  如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 {@link EMError}。
  ///
  Future<EMUserInfo?> fetchOwnInfo({int expireTime = 0}) async {
    String? currentUser = await EMClient.getInstance.getCurrentUsername();
    if (currentUser != null) {
      try {
        Map<String, EMUserInfo> ret = await fetchUserInfoById(
          [currentUser],
          expireTime: expireTime,
        );
        _ownUserInfo = ret.values.first;
      } on EMError catch (e) {
        throw e;
      }
    }
    return _ownUserInfo;
  }

  ///
  /// 根据用户 ID，获取指定用户的用户属性。
  ///
  /// Param [userIds] 用户名数组。
  ///
  /// Param [expireTime] 获取的用户属性到期时间。如果在到期时间内再次调用该方法，则 SDK 直接返回上次获取到的缓存数据。例如，将该参数设为 120，即 2 分钟，则如果你在 2 分钟内再次调用该方法获取用户属性，SDK 仍将返回上次获取到的属性。否则需从服务器获取。
  ///
  /// **Return** 返回 key-value 格式的 Map 类型数据，key 为用户名，value 为用户属性。
  ///
  /// **Throws** 如果有方法调用的异常会在这里抛出，可以看到具体错误原因。请参见 {@link EMError}。
  ///
  Future<Map<String, EMUserInfo>> fetchUserInfoById(
    List<String> userIds, {
    int expireTime = 0,
  }) async {
    List<String> needReqIds = userIds
        .where((element) =>
            !_effectiveUserInfoMap.containsKey(element) ||
            (_effectiveUserInfoMap.containsKey(element) &&
                DateTime.now().millisecondsSinceEpoch -
                        _effectiveUserInfoMap[element]!.expireTime >
                    expireTime * 1000))
        .toList();
    Map<String, EMUserInfo> resultMap = Map();

    userIds.forEach((element) {
      if (_effectiveUserInfoMap.containsKey(element)) {
        resultMap[element] = _effectiveUserInfoMap[element]!;
      }
    });
    if (needReqIds.length == 0) {
      return resultMap;
    }

    Map req = {'userIds': needReqIds};
    Map result =
        await _channel.invokeMethod(ChatMethodKeys.fetchUserInfoById, req);

    try {
      EMError.hasErrorFromResult(result);
      result[ChatMethodKeys.fetchUserInfoById]?.forEach((key, value) {
        EMUserInfo eUserInfo = EMUserInfo.fromJson(value);
        resultMap[key] = eUserInfo;
        _effectiveUserInfoMap[key] = eUserInfo;
      });
      return resultMap;
    } on EMError catch (e) {
      throw e;
    }
  }

  /// 清理内存中的用户属性
  void clearUserInfoCache() {
    _ownUserInfo = null;
    _effectiveUserInfoMap.clear();
  }
}
