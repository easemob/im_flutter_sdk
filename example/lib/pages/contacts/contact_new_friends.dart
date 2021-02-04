import 'package:easeim_flutter_demo/unit/share_preference_manager.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ContactNewFirends extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactNewFirendsState();
}

class ContactNewFirendsState extends State<ContactNewFirends> {
  List<String> requestList = List();
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
  Widget build(BuildContext context) {
    requestList = SharePreferenceManager.loadAllRequests();

    return Scaffold(
      appBar: DemoAppBar.normal('好友申请', actions: [
        FlatButton(
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
                              FlatButton(
                                child: Text(
                                  '同意',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: sFontSize(17),
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  EMClient.getInstance.contactManager
                                      .acceptInvitation(reqestId);
                                  SharePreferenceManager.updateRequest(
                                    reqestId,
                                    true,
                                  );
                                  setState(() {});
                                },
                              ),
                              FlatButton(
                                child: Text(
                                  '拒绝',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: sFontSize(17),
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  EMClient.getInstance.contactManager
                                      .declineInvitation(reqestId);
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
}
