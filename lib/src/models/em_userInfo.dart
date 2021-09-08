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
      ..nickName = map['nickName']
      ..avatarUrl = map['avatarUrl']
      ..mail = map['mail']
      ..phone = map['phone']
      ..gender = map['gender']
      ..sign = map['sign']
      ..birth = map['birth']
      ..ext = map['ext'];
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
    return data;
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
}
