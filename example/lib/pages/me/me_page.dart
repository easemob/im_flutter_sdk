import 'dart:math';

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MePageState();
}

class MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我"),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: [
            Container(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'flutter sdk version',
                  ),
                  Text(
                    EMClient.getInstance.flutterSDKVersion,
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
            Row(
              children: [
                Expanded(
                  child: FlatButton(
                    color: Colors.red,
                    onPressed: updateOwnUserInfo,
                    child: Text(
                      'updateOwnUserInfo',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FlatButton(
                    color: Colors.red,
                    onPressed: fetchUserInfoById,
                    child: Text(
                      'fetchUserInfoById',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FlatButton(
                    color: Colors.red,
                    onPressed: fetchUserInfoByIdWithType,
                    child: Text(
                      'fetchUserInfoByIdWithType',
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

  fetchUserInfoById() async {
    try {
      String userId = EMClient.getInstance.currentUsername;
      List<String> userIds = List();
      userIds.add(userId);
      userIds.add('liu003');
      userIds.add('liu004');

      int expireTime = DateTime.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch - 10000000)
          .millisecondsSinceEpoch;

      print('userIds: $userIds');
      Map userInfoMap = await EMClient.getInstance.userInfoManager
          .fetchUserInfoByIdWithExpireTime(userIds, expireTime: expireTime);

      print('userInfoMap: $userInfoMap');
      print('=====================');
      print('=====================');

      EMUserInfo userInfo = userInfoMap[userId];
      userInfo.description();
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
          EMClient.getInstance.userInfoManager.getOwnUserInfo();
      eUserInfo.nickName = '葫芦娃';
      String source = '123456789';
      String month = source[Random().nextInt(source.length)];
      String day = source[Random().nextInt(source.length)];

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
      EMUserInfoType infoType = EMUserInfoType.EMUserInfoTypeBirth;
      String updateValue = '2021.01.01';

      EMUserInfo updateUserInfo = await EMClient.getInstance.userInfoManager
          .updateOwnUserInfoWithType(infoType, updateValue);
      print('updateUserInfo: $updateUserInfo');
    } on EMError catch (e) {
      print('操作失败，原因是: $e');
    }
  }
}
