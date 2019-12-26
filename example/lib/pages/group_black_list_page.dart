

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/common/common.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

class EMGroupBlackListPage extends StatefulWidget {

  final String _groupId;
//  var _members = List<String>();
  final List<String> _members;
  final int _type;

  const EMGroupBlackListPage(this._groupId, this._members, this._type);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMGroupBlackListPageState(this._groupId, this._members, this._type);
  }
}

class _EMGroupBlackListPageState extends State<EMGroupBlackListPage> {
  String _groupId;
  var _members = List<String>();
  int _type;
  bool _loading = false;

  _EMGroupBlackListPageState(this._groupId, this._members, this._type);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  _refreshUI(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  Widget _buildListView() {

    String _content;
    if(_type == Constant.blackList){
      _content = '是否要解除黑名单: ';
    }else if(_type == Constant.muteList){
      _content = '是否要解除禁言: ';
    }else if(_type == Constant.adminList){
      _content = '是否要解除管理员: ';
    }
    return ListView.builder(
        itemCount: _members.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text(_content + _members[index]),
                        actions: <Widget>[
                          FlatButton(
                            child: new Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: new Text('确定'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _refreshUI(true);
                              if(_type == Constant.blackList){
                                EMClient.getInstance().groupManager().unblockUser(_groupId, _members[index],
                                onSuccess: (){
                                  WidgetUtil.hintBoxWithDefault(_members[index] + '解除黑名单成功');
                                  _members.removeAt(index);
                                  _refreshUI(false);
                                },
                                onError: (code, desc){
                                  _refreshUI(false);
                                  WidgetUtil.hintBoxWithDefault(code.toString() +':'+desc);
                                });
                              }
                              if(_type == Constant.muteList){
                                EMClient.getInstance().groupManager().unMuteGroupMembers(_groupId, [_members[index]],
                                onSuccess: (group){
                                  WidgetUtil.hintBoxWithDefault(_members[index] + '解除禁言成功');
                                  _members.removeAt(index);
                                  _refreshUI(false);
                                },
                                onError: (code, desc){
                                  _refreshUI(false);
                                  WidgetUtil.hintBoxWithDefault(code.toString() +':'+desc);
                                });
                              }
                              if(_type == Constant.adminList){
                                EMClient.getInstance().groupManager().removeGroupAdmin(_groupId, _members[index],
                                    onSuccess: (group){
                                      WidgetUtil.hintBoxWithDefault(_members[index] + '解除管理员成功');
                                      _members.removeAt(index);
                                      _refreshUI(false);
                                    },
                                    onError: (code, desc){
                                      _refreshUI(false);
                                      WidgetUtil.hintBoxWithDefault(code.toString() +':'+desc);
                                    });
                              }
                            },
                          ),
                        ],
                      );
                    });
            },
            child: Container(
              height: EMLayout.emContactListItemHeight,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                    child: Container(
                      height: EMLayout.emContactListPortraitSize,
                      width: EMLayout.emContactListPortraitSize,
                      child: Image.asset('images/default_avatar.png'),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        height: EMLayout.emContactListItemHeight,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.5,
                                    color: ThemeUtils.isDark(context)
                                        ? EMColor.darkBorderLine
                                        : EMColor.borderLine))),
                        child: Row(
                          children: <Widget>[
                            Text(
                              _members[index],
                              style: TextStyle(
                                  fontSize: EMFont.emConListTitleFont),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String title;
    if (_type == Constant.blackList) {
      title = DemoLocalizations.of(context).blackListManagement;
    }
    if (_type == Constant.muteList) {
      title = DemoLocalizations.of(context).muteManagement;
    }
    if (_type == Constant.adminList) {
      title = DemoLocalizations.of(context).adminManagement;
    }

    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        appBar: WidgetUtil.buildAppBar(context, title),
        key: UniqueKey(),
        body: Stack(
          children: <Widget>[
            _buildListView(),
            ProgressDialog(
              loading: _loading,
              msg: DemoLocalizations.of(context).inOperation,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _willPop () { //返回值必须是Future<bool>
    Navigator.of(context).pop(_members);
    return Future.value(false);
  }
}
