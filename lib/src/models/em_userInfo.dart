//用户属性类型
import 'dart:convert';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMUserInfo {
  EMUserInfo(String userId) {
    _userId = userId ?? '';
  }

  factory EMUserInfo.fromJson(Map map) {
    if (map == null) return null;

    return EMUserInfo._private()
      .._userId = map['userId']
      .._nickName = map['nickName']
      .._avatarUrl = map['avatarUrl']
      .._mail = map['mail']
      .._phone = map['phone']
      .._gender = map['gender']
      .._sign = map['sign']
      .._birth = map['birth']
      .._ext = map['ext'];
  }

  Map toJson() {
    Map data = Map();
    data['userId'] = _userId;
    data['nickName'] = _nickName;
    data['avatarUrl'] = _avatarUrl;
    data['mail'] = _mail;
    data['phone'] = _phone;
    data['gender'] = _gender;
    data['sign'] = _sign;
    data['birth'] = _birth;
    data['ext'] = _ext;
    return data;
  }

  void description() {
    print(
        '\n=======================\n$this\n userId:$userId\n nickName:$nickName\n avatarUrl:$avatarUrl\n mail:$mail\n phone:$phone\n gender:$gender\n sign:$sign\n birth:$birth\n sign:$ext\n =======================\n');
  }

  EMUserInfo._private([this._userId]);

  String _userId;
  String _nickName;
  String _avatarUrl = '';
  String _mail;
  String _phone;
  int _gender;
  String _sign;
  String _birth;
  String _ext;

  /// 用户环信Id
  String get userId => _userId;

  /// nickname
  String get nickName => _nickName;

  /// 头像地址
  String get avatarUrl => _avatarUrl;

  // 用户邮箱地址
  String get mail => _mail;

  // 用户联系方式
  String get phone => _phone;

  // 用户性别，0为未设置
  int get gender => _gender;

  // 用户签名
  String get sign => _sign;

  // 用户生日
  String get birth => _birth;

  // 扩展字段
  String get ext => _ext;
}
