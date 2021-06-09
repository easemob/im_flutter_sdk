import 'dart:math';

import 'package:easeim_flutter_demo/pages/me/userInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MePageState();
}

class MePageState extends State<MePage> {
  @override
  void initState() {
    super.initState();
  }

  String _nickName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我"),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 10,
          top: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: goUserInfoPage,
              child: Container(
                margin:
                    EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '个人信息',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Icon(Icons.keyboard_arrow_right),
                  ],
                ),
              ),
            ),
            Container(
              height: 30,
              margin: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'flutter sdk version',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    EMClient.getInstance.flutterSDKVersion,
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: FlatButton(
                    color: Colors.red,
                    onPressed: _loggout,
                    child: Text(
                      '退出[${EMClient.getInstance.currentUsername}]',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _loggout() async {
    try {
      await EMClient.getInstance.logout(true);
      Navigator.of(context).pushReplacementNamed(
        '/login',
      );
    } on EMError {}
  }

  goUserInfoPage() {
    Navigator.of(context).pushNamed('/userInfoPage').then((value) {});
  }

  fetchUserInfoById() async {
    try {
      String userId = EMClient.getInstance.currentUsername;
      List<String> userIds = List();
      userIds.add(userId);
      userIds.add('liu005');
      userIds.add('liu004');

      int expireTime = DateTime.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch - 10000000)
          .millisecondsSinceEpoch;

      print('userIds: $userIds');
      Map userInfoMap = await EMClient.getInstance.userInfoManager
          .fetchUserInfoByIdWithExpireTime(userIds, expireTime: expireTime);

      print('userInfoMap: $userInfoMap');
      print('fetchUserInfoById\n===============================');
      print('===============================');

      for (var key in userInfoMap.keys) {
        EMUserInfo us = userInfoMap[key];
        us.description();
      }

      print('===============================');
      print('===============================');
    } on EMError catch (e) {
      print('操作失败，原因是: $e');
    }
  }

  fetchUserInfoByIdWithType() async {
    try {
      String userId = EMClient.getInstance.currentUsername;
      List<String> userIds = List();
      userIds.add(userId);
      userIds.add('liu001');

      List<EMUserInfoType> types = List();
      types.add(EMUserInfoType.EMUserInfoTypeNickName);
      types.add(EMUserInfoType.EMUserInfoTypeBirth);
      types.add(EMUserInfoType.EMUserInfoTypeAvatarURL);

      print('userIds: $userIds');

      int expireTime = DateTime.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch - 10000000)
          .millisecondsSinceEpoch;

      Map userInfoMap = await EMClient.getInstance.userInfoManager
          .fetchUserInfoByIdWithType(userIds, types, expireTime: expireTime);
      EMUserInfo userInfo = userInfoMap[userId];
      print('userInfoMap: $userInfoMap');
      print('=====================');
      print('=====================');
      userInfo.description();
    } on EMError catch (e) {
      print('操作失败，原因是: $e');
    }
  }

  updateOwnUserInfo() async {
    try {
      String userId = EMClient.getInstance.currentUsername;
      print('userId: $userId');

      EMUserInfo eUserInfo =
          await EMClient.getInstance.userInfoManager.fetchOwnUserInfo();
      eUserInfo.nickName = '111';
      String source = '123456789';
      String month = source[Random().nextInt(source.length)];
      String day = source[Random().nextInt(source.length)];
      String urlString =
          'http://thirdqq.qlogo.cn/g?b=oidb&k=F3O4ZsbrmMjAwJRyAhmkaw&s=100&t=1556336302';
      eUserInfo.avatarUrl = urlString;

      eUserInfo.gender = 2;
      eUserInfo.birth = '2021-0$month-' + day;
      print('eUserInfo.birth:${eUserInfo.birth}');
      eUserInfo.description();

      EMUserInfo updateUserInfo = await EMClient.getInstance.userInfoManager
          .updateOwnUserInfo(eUserInfo);
      updateUserInfo.description();
    } on EMError catch (e) {
      print('操作失败，原因是: $e');
    }
  }

  updateOwnUserInfoWithType() async {
    try {
      EMUserInfoType infoType = EMUserInfoType.EMUserInfoTypePhone;

      String source = '123456789';
      String month = source[Random().nextInt(source.length)];
      String day = source[Random().nextInt(source.length)];

      String updateValue = '136112255$month$day';
      print("updateValue:$updateValue");

      EMUserInfo updateUserInfo = await EMClient.getInstance.userInfoManager
          .updateOwnUserInfoWithType(infoType, updateValue);
      print('updateOwnUserInfoWithType userInfo: $updateUserInfo');
      updateUserInfo.description();
    } on EMError catch (e) {
      print('操作失败，原因是: $e');
    }
  }
}
