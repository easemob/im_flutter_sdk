//用户属性类型

enum EMUserInfoType {
  EMUserInfoTypeNickName,
  EMUserInfoTypeAvatarURL,
  EMUserInfoTypePhone,
  EMUserInfoTypeMail,
  EMUserInfoTypeGender,
  EMUserInfoTypeSign,
  EMUserInfoTypeBirth,
  EMUserInfoTypeExt,
}

class EMUserInfo {
  EMUserInfo(
    String aUserId, {
    String aNickName = '',
    String aAvatarUrl = '',
    String aMail = '',
    String aPhone = '',
    int aGender = 0,
    String aSign = '',
    String aBirth = '',
    String aExt = '',
    int aExpireTime = 0,
  }) {
    userId = aUserId ?? '';
  }

  factory EMUserInfo.fromJson(Map map) {
    if (map == null) return null;

    return EMUserInfo.private()
      ..userId = map['userId']
      ..nickName = map['nickname']
      ..avatarUrl = map['avatarurl']
      ..mail = map['mail']
      ..phone = map['phone']
      ..gender = map['gender']
      ..sign = map['sign']
      ..birth = map['birth']
      ..ext = map['ext']
      ..expireTime = map['expireTime'];
  }

  Map toJson() {
    Map data = Map();
    data['userId'] = userId;
    data['nickName'] = nickName;
    data['avatarUrl'] = avatarUrl;
    data['mail'] = mail;
    data['phone'] = phone;
    data['gender'] = gender;
    data['sign'] = sign;
    data['birth'] = birth;
    data['ext'] = ext;
    data['expireTime'] = expireTime;
    return data;
  }

  void description() {
    print(
        '\n=======================\n$this\n userId:$userId\n nickName:$nickName\n avatarUrl:$avatarUrl\n mail:$mail\n phone:$phone\n gender:$gender\n sign:$sign\n birth:$birth\n ext:$ext\n expireTime:$expireTime\n =======================\n');
  }

  EMUserInfo.private([this.userId]);

  String userId = '';
  String nickName = '';
  String avatarUrl = '';
  String mail = '';
  String phone = '';
  int gender = 0;
  String sign = '';
  String birth = '';
  String ext = '';
  int expireTime = 0;

  // String userId;
  // String nickName;
  // String avatarUrl = '';
  // String mail;
  // String phone;
  // int gender;
  // String sign;
  // String birth;
  // String ext;
  // //过期时间
  // int expireTime;

  // /// 用户环信Id
  // String get userId => userId;

  // /// nickname
  // String get nickName => nickName;

  // /// 头像地址
  // String get avatarUrl => avatarUrl;

  // // 用户邮箱地址
  // String get mail => mail;

  // // 用户联系方式
  // String get phone => phone;

  // // 用户性别，0为未设置
  // int get gender => gender;

  // // 用户签名
  // String get sign => sign;

  // // 用户生日
  // String get birth => birth;

  // // 扩展字段
  // String get ext => ext;

  // //过期时间
  // int get expireTime => expireTime;
}
