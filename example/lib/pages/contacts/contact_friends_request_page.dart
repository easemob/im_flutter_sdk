import 'package:easeim_flutter_demo/unit/share_preference_manager.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ContactFirendsRequestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactFirendsRequestPageState();
}

class ContactFirendsRequestPageState extends State<ContactFirendsRequestPage> {
  List<String> requestList = [];
  RegExp requestExp = RegExp(r' ');
  @override
  void initState() {
    super.initState();
    String currentUser = EMClient.getInstance.currentUsername;
    SharePreferenceManager.load(currentUser, callback: () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    SharePreferenceManager.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    requestList = SharePreferenceManager.loadAllRequests();

    return Scaffold(
      appBar: DemoAppBar('好友申请', rightWidgets: [
        TextButton(
          onPressed: () {
            SharePreferenceManager.removeAllRequest();
            setState(() {});
          },
          child: Text(
            '清空',
            style: TextStyle(
              color: Colors.white,
              fontSize: sFontSize(16),
            ),
          ),
        )
      ]),
      body: ListView.builder(
        itemCount: requestList.length,
        itemBuilder: (_, index) {
          bool isAlreadDone = false;
          String reqestId = requestList[index];
          if (requestExp.hasMatch(reqestId)) {
            isAlreadDone = true;
            reqestId = reqestId.substring(0, reqestId.length - 2);
          }
          return Card(
            elevation: 5, //阴影
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            color: Colors.white, //颜色
            margin: EdgeInsets.all(20), //margin
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      child: Text(
                        '$reqestId添加您为好友',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: !isAlreadDone
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                child: Text(
                                  '同意',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: sFontSize(17),
                                  ),
                                ),
                                onPressed: () {
                                  _acceptInvitation(reqestId);
                                  SharePreferenceManager.updateRequest(
                                    reqestId,
                                    true,
                                  );
                                  setState(() {});
                                },
                              ),
                              TextButton(
                                child: Text(
                                  '拒绝',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: sFontSize(17),
                                  ),
                                ),
                                onPressed: () {
                                  _declineInvitation(reqestId);
                                  SharePreferenceManager.updateRequest(
                                    reqestId,
                                    false,
                                  );
                                  setState(() {});
                                },
                              ),
                            ],
                          )
                        : Text(
                            '已处理',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _acceptInvitation(String username) async {
    try {
      SmartDialog.showLoading(msg: '发送中...');
      await EMClient.getInstance.contactManager.acceptInvitation(username);
      SmartDialog.showToast('发送成功');
    } on EMError {
      SmartDialog.showToast('发送失败');
    } finally {
      SmartDialog.dismiss();
    }
  }

  _declineInvitation(String username) async {
    try {
      SmartDialog.showLoading(msg: '发送中...');
      await EMClient.getInstance.contactManager.declineInvitation(username);
      SmartDialog.showToast('发送成功');
    } on EMError {
      SmartDialog.showToast('发送失败');
    } finally {
      SmartDialog.dismiss();
    }
  }
}
