import 'dart:async';
import 'package:flutter/services.dart';

import 'internal/inner_headers.dart';

///
/// The user attribute manager class, which gets and sets the user attributes.
///
class EMUserInfoManager {
  static const _channelPrefix = 'com.chat.im';
  static const MethodChannel _channel = const MethodChannel(
      '$_channelPrefix/chat_userInfo_manager', JSONMethodCodec());

  // The map of effective contacts.
  Map<String, EMUserInfo> _effectiveUserInfoMap = Map();

  ///
  /// Modifies the user attributes of the current user.
  ///
  /// Param [nickname] The nickname of the user.
  ///
  /// Param [avatarUrl] The avatar URL of the user.
  ///
  /// Param [mail] The email address of the user.
  ///
  /// Param [phone] The phone number of the user.
  ///
  /// Param [gender] The gender of the user. The value can only be `0`, `1`, or `2`. Other values are invalid.
  /// - `0`: (Default) Unknown;
  /// - `1`: Male;
  /// - `2`: Female.
  /// Param [sign] The signature of the user.
  ///
  /// Param [birth] The birthday of the user.
  ///
  /// Param [ext] The custom extension information of the user. You can set it to an empty string or type custom information and encapsulate them as a JSON string.
  ///
  /// **Return** The user info.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMUserInfo> updateUserInfo({
    String? nickname,
    String? avatarUrl,
    String? mail,
    String? phone,
    int? gender,
    String? sign,
    String? birth,
    String? ext,
  }) async {
    Map req = {};
    req.setValueWithOutNull("nickName", nickname);
    req.setValueWithOutNull("avatarUrl", avatarUrl);
    req.setValueWithOutNull("mail", mail);
    req.setValueWithOutNull("phone", phone);
    req.setValueWithOutNull("gender", gender);
    req.setValueWithOutNull("sign", sign);
    req.setValueWithOutNull("birth", birth);
    req.setValueWithOutNull("ext", ext);

    try {
      Map result =
          await _channel.invokeMethod(ChatMethodKeys.updateOwnUserInfo, req);
      EMError.hasErrorFromResult(result);
      EMUserInfo info =
          EMUserInfo.fromJson(result[ChatMethodKeys.updateOwnUserInfo]);
      _effectiveUserInfoMap[info.userId] = info;
      return info;
    } on EMError catch (e) {
      throw e;
    }
  }

  ///
  /// Gets the current user's attributes from the server.
  ///
  /// Param [expireTime] The time period(seconds) when the user attributes in the cache expire. If the interval between two callers is less than or equal to the value you set in the parameter, user attributes are obtained directly from the local cache; otherwise, they are obtained from the server. For example, if you set this parameter to 120(2 minutes), once this method is called again within 2 minutes, the SDK returns the attributes obtained last time.
  ///
  /// **Return**  The user properties that are obtained. See {@link EMUserInfo}.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
  ///
  Future<EMUserInfo?> fetchOwnInfo({int expireTime = 0}) async {
    String? currentUser = await EMClient.getInstance.getCurrentUsername();
    if (currentUser != null) {
      try {
        Map<String, EMUserInfo> ret = await fetchUserInfoById(
          [currentUser],
          expireTime: expireTime,
        );
        _effectiveUserInfoMap[ret.values.first.userId] = ret.values.first;
        return ret.values.first;
      } on EMError catch (e) {
        throw e;
      }
    }
    return null;
  }

  ///
  /// Gets user attributes of the specified users.
  ///
  /// Param [userIds] The username array.
  ///
  /// Param [expireTime] The time period(seconds) when the user attributes in the cache expire. If the interval between two callers is less than or equal to the value you set in the parameter, user attributes are obtained directly from the local cache; otherwise, they are obtained from the server. For example, if you set this parameter to 120(2 minutes), once this method is called again within 2 minutes, the SDK returns the attributes obtained last time.
  ///
  /// **Return** A map that contains key-value pairs where the key is the user ID and the value is user attributes.
  ///
  /// **Throws**  A description of the exception. See {@link EMError}.
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

  void clearUserInfoCache() {
    _effectiveUserInfoMap.clear();
  }
}
