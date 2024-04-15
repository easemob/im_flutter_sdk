/// ~english
/// The EMUserInfo class, which contains the user attributes, such as the nickname, description, and avatar.
/// ~end
///
/// ~chinese
/// 用户属性类。
/// ~end
class EMUserInfo {
  /// ~english
  /// Creates a user attribute.
  /// ~end
  ///
  /// ~chinese
  /// 创建用户属性。
  /// ~end
  EMUserInfo._private(
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

  factory EMUserInfo.fromJson(Map map) {
    EMUserInfo info = EMUserInfo._private(
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
    Map data = Map();
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
  /// Gets the time period(seconds) when the user attributes in the cache expire.
  /// If the interval between two callers is less than or equal to the value you set in the parameter,
  /// user attributes are obtained directly from the local cache; otherwise, they are obtained from the server.
  /// For example, if you set this parameter to 120(2 minutes), once this method is called again within 2 minutes,
  /// the SDK returns the attributes obtained last time.
  /// ~end
  ///
  /// ~chinese
  /// 获取缓存中的用户属性到期时的时间段(秒)。如果两个调用者之间的间隔小于或等于参数中设置的值，则直接从本地缓存获取用户属性;
  /// 否则，从服务器获取。例如，如果将该参数设置为120(2分钟)，则在2分钟内再次调用该方法，SDK将返回上次获取的属性。
  /// ~end
  final int expireTime = DateTime.now().millisecondsSinceEpoch;
}
