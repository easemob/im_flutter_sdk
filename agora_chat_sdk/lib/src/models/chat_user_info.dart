/// ~english
/// The ChatUserInfo class, which contains the user attributes, such as the nickname, description, and avatar.
/// ~end
///
/// ~chinese
/// 用户属性类。
/// ~end
class ChatUserInfo {
  /// ~english
  /// Creates a user attribute.
  /// ~end
  ///
  /// ~chinese
  /// 创建用户属性。
  /// ~end
  ChatUserInfo(
    this.userId, {
    this.nickName,
    this.avatarUrl,
    this.mail,
    this.phone,
    this.gender = 0,
    this.sign,
    this.birth,
    this.ext,
  });

  factory ChatUserInfo.fromJson(Map map) {
    ChatUserInfo info = ChatUserInfo(
      map["userId"],
      nickName: map["nickName"],
      avatarUrl: map["avatarUrl"],
      mail: map["mail"],
      phone: map["phone"],
      gender: map["gender"] ?? 0,
      sign: map["sign"],
      birth: map["birth"],
      ext: map["ext"],
    );
    return info;
  }

  Map toJson() {
    Map data = {};
    data['userId'] = userId;
    if (nickName != null) {
      data['nickName'] = nickName;
    }
    if (avatarUrl != null) {
      data['avatarUrl'] = avatarUrl;
    }
    if (mail != null) {
      data['mail'] = mail;
    }
    if (phone != null) {
      data['phone'] = phone;
    }
    data['gender'] = gender;
    if (sign != null) {
      data['sign'] = sign;
    }
    if (birth != null) {
      data['birth'] = birth;
    }
    if (ext != null) {
      data['ext'] = ext;
    }

    return data;
  }

  /// ~english
  /// Gets the userId.
  /// ~end
  ///
  /// ~chinese
  /// 用户 ID。
  /// ~end
  final String userId;

  /// ~english
  /// Gets the user's nickname.
  /// ~end
  ///
  /// ~chinese
  /// 用户昵称。
  /// ~end
  final String? nickName;

  /// ~english
  /// Gets the avatar URL of the user.
  /// ~end
  ///
  /// ~chinese
  /// 用户头像。
  /// ~end
  final String? avatarUrl;

  /// ~english
  /// Gets the email address of the user.
  /// ~end
  ///
  /// ~chinese
  /// 用户邮箱。
  /// ~end
  final String? mail;

  /// ~english
  /// Gets the mobile numbers of the user.
  /// ~end
  ///
  /// ~chinese
  /// 用户手机号。
  /// ~end
  final String? phone;

  /// ~english
  /// Gets the user's gender.
  ///
  /// The user's gender:
  /// - `0`: (Default) UnKnow;
  /// - `1`: Male;
  /// - `2`: Female.
  /// ~end
  ///
  /// ~chinese
  /// 用户性别。
  /// - (默认) `0`：未知；
  /// - `1`: 男；
  /// - `2`: 女。
  /// ~end
  final int gender;

  /// ~english
  /// Gets the user's signature.
  /// ~end
  ///
  /// ~chinese
  /// 用户签名。
  /// ~end
  final String? sign;

  /// ~english
  /// Gets the user's data of birth.
  /// ~end
  ///
  /// ~chinese
  /// 用户生日。
  /// ~end
  final String? birth;

  /// ~english
  /// Gets the user's extension information.
  /// ~end
  ///
  /// ~chinese
  /// 用户自定义属性字段。
  /// ~end
  final String? ext;

  /// ~english
  /// The Unix timestamp in milliseconds when this Dart user attribute object was created, used to check Dart cache validity.
  /// This differs from the `expireTime` parameter of user attribute retrieval methods, which is measured in seconds.
  /// ~end
  ///
  /// ~chinese
  /// 当前 Dart 用户属性对象创建时的 Unix 毫秒时间戳，供 Dart 层缓存有效性判断使用。
  /// 它不同于获取用户属性方法中以秒为单位的 `expireTime` 参数。
  /// ~end
  final int expireTime = DateTime.now().millisecondsSinceEpoch;
}
