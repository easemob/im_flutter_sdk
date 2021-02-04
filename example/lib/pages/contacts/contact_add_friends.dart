import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ContactAddFriends extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactAddFriendsState();
}

class ContactAddFriendsState extends State<ContactAddFriends> {
  String _searchName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar.normal('添加好友', actions: []),
      body: Padding(
        padding: EdgeInsets.only(
          top: sHeight(10),
          left: sWidth(20),
          right: sWidth(20),
        ),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                minHeight: sHeight(32),
              ),
              margin: EdgeInsets.only(
                bottom: sHeight(8),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Color.fromRGBO(242, 242, 242, 1),
              ),
              child: TextFormField(
                focusNode: null,
                textInputAction: TextInputAction.search,
                onChanged: (text) {},
                style: TextStyle(
                  fontSize: sFontSize(14),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: null,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(
                    sWidth(16),
                    sHeight(8),
                    sWidth(16),
                    sHeight(6),
                  ),
                  hintText: '请输入id',
                  hintStyle: TextStyle(
                    fontSize: sFontSize(14),
                    color: Colors.grey,
                  ),
                ),
                onFieldSubmitted: (str) {
                  setState(() {
                    _searchName = str;
                  });
                },
              ),
            ),
            _searchName.length > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          _searchName,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: sFontSize(18),
                          ),
                        ),
                      ),
                      FlatButton(
                        color: Colors.blue,
                        highlightColor: Colors.blue[700],
                        colorBrightness: Brightness.dark,
                        splashColor: Colors.grey,
                        child: Text("添加"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        onPressed: () => _addContact(),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  _addContact() async {
    try {
      SmartDialog.showLoading(msg: '发送中...');
      EMClient.getInstance.contactManager.addContact(_searchName);
      SmartDialog.showToast('发送成功');
    } on EMError {
      SmartDialog.showToast('发送失败');
    } finally {
      SmartDialog.dismiss();
    }
  }
}
