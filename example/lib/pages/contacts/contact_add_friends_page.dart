import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ContactAddFriendsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ContactAddFriendsPageState();
}

class ContactAddFriendsPageState extends State<ContactAddFriendsPage> {
  String _searchName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar('添加好友'),
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
                  hintText: '请输入ID',
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
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.blue[700];
                              }
                              return Colors.blue;
                            },
                          ),
                        ),
                        child: Text(
                          "添加",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => _addContact(),
                      ),
                    ],
                  )
                : Container(
                    margin: EdgeInsets.all(20),
                    child: Text(
                      '此处搜索是直接返回您输入的信息，请确保您搜索的环信id在环信存在。点击添加后对方会收到好友申请。正式环境中应该是从您的服务器所有好友之后添加。',
                      style: TextStyle(color: Colors.black38),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _addContact() async {
    try {
      SmartDialog.showLoading(msg: '发送中...');
      await EMClient.getInstance.contactManager.addContact(_searchName);
      SmartDialog.showToast('发送成功');
    } on EMError catch (e) {
      SmartDialog.showToast('发送失败$e');
    } finally {
      SmartDialog.dismiss();
    }
  }
}
