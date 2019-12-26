import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/common/common.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

class EMGroupMembersPage extends StatefulWidget {
  final String _groupId;
//  var _members = List<String>();
  final List<String> _members;
  final String _cursor;
  final String _currentUser;
//  var _blackList = List<String>();
//  var _muteList = List<String>();
//  var _admins = List<String>();
  final List<String> _blackList;
  final List<String> _muteList;
  final List<String> _admins;
  final String _owner;
  final int _type;

  const EMGroupMembersPage(this._groupId, this._members, this._cursor,
      this._currentUser, this._blackList, this._muteList, this._admins, this._owner, this._type);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMGroupMembersPageState(this._groupId, this._members, this._cursor,
        this._currentUser, this._blackList, this._muteList, this._admins, this._owner, this._type);
  }
}

class _EMGroupMembersPageState extends State<EMGroupMembersPage> {
  String _groupId;
  var _members = List<String>();
  String _cursor;
  var _blackList = List<String>();
  var _muteList = List<String>();
  var _admins = List<String>();
  String _owner;
  int _type;
  String _currentUser;
  bool _loading = false;
  bool _isRefresh = false;

  _EMGroupMembersPageState(this._groupId, this._members, this._cursor,
      this._currentUser, this._blackList, this._muteList, this._admins, this._owner, this._type);

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
    return ListView.builder(
        itemCount: _members.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          Offset tapPos;
          return InkWell(
            onTapDown: (TapDownDetails details) {
              tapPos = details.globalPosition;
            },
            onLongPress: (){
              if(_type == Constant.defaultGroupMember && (_owner == _currentUser || _admins.contains(_currentUser))){
                if(!(_members[index] == _owner)){
                  if(!(_admins.contains(_members[index]) && _admins.contains(_currentUser))){
                    Map<String,String>  actionMap = {
                      Constant.addBlackListKey:DemoLocalizations.of(context).addBlackList,
                      Constant.addMuteListKey:DemoLocalizations.of(context).addMuteList,
                    };
                    if(_owner == _currentUser){
                      actionMap = {
                        Constant.addBlackListKey:DemoLocalizations.of(context).addBlackList,
                        Constant.addMuteListKey:DemoLocalizations.of(context).addMuteList,
                        Constant.addAdminListKey:DemoLocalizations.of(context).addAdminList,
                      };
                      if(_blackList.contains(_members[index])){
                        actionMap.remove(Constant.addBlackListKey);
                      }
                      if(_muteList.contains(_members[index])){
                        actionMap.remove(Constant.addMuteListKey);
                      }
                      if(_admins.contains(_members[index])){
                        actionMap.remove(Constant.addAdminListKey);
                      }
                    }else{
                      if(_blackList.contains(_members[index])){
                        actionMap.remove(Constant.addBlackListKey);
                      }
                      if(_muteList.contains(_members[index])){
                        actionMap.remove(Constant.addMuteListKey);
                      }
                    }

                    WidgetUtil.showLongPressMenu(context, tapPos,actionMap,(String key){
                      if(key == Constant.addBlackListKey) {
                        _refreshUI(true);
                        EMClient.getInstance().groupManager().blockUser(_groupId, _members[index],
                        onSuccess: (){
                          WidgetUtil.hintBoxWithDefault(_members[index].toString() + '加入黑名单成功');
                          _members.removeAt(index);
                          _isRefresh = true;
                          _refreshUI(false);
                        },
                        onError: (code, desc){
                          WidgetUtil.hintBoxWithDefault(code.toString() +':'+desc);
                          _refreshUI(false);
                        });
                      }else if(key == Constant.addMuteListKey) {
                        _refreshUI(true);
                        EMClient.getInstance().groupManager().muteGroupMembers(_groupId, [_members[index]], '86400000',
                        onSuccess: (group){
                          _muteList.add(_members[index]);
                          WidgetUtil.hintBoxWithDefault(_members[index].toString() + '禁言成功');
                          _isRefresh = true;
                          _refreshUI(false);
                        },
                        onError: (code, desc){
                          WidgetUtil.hintBoxWithDefault(code.toString() +':'+ desc);
                          _refreshUI(false);
                        });

                      }else if(key == Constant.addAdminListKey) {
                        _refreshUI(true);
                        EMClient.getInstance().groupManager().addGroupAdmin(_groupId, _members[index],
                        onSuccess: (group){
                          _admins.add(_members[index]);
                          WidgetUtil.hintBoxWithDefault(_members[index].toString() + '添加管理员成功');
                          _isRefresh = true;
                          _refreshUI(false);
                        },
                        onError: (code, desc){
                          WidgetUtil.hintBoxWithDefault(code.toString() +':'+ desc);
                          _refreshUI(false);
                        });
                      }
                    });
                  }
                }
              }
            },
            onTap: () {
              if (_type == Constant.removeGroupMember) {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('是否要移除成员' + _members[index]),
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
                              EMClient.getInstance()
                                  .groupManager()
                                  .removeUserFromGroup(
                                      _groupId,
                                      _members[index],
                                      onSuccess: () {
                                        _isRefresh = true;
                                        WidgetUtil.hintBoxWithDefault('移除成员成功');
                                        _members.removeAt(index);
                                        _refreshUI(false);
                                      },
                                      onError: (code, desc) {
                                        WidgetUtil.hintBoxWithDefault(
                                            code.toString() + ':' + desc);
                                        _refreshUI(false);
                                      });
                            },
                          ),
                        ],
                      );
                    });
              }
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
                        margin: EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.5,
                                    color: ThemeUtils.isDark(context)
                                        ? EMColor.darkBorderLine
                                        : EMColor.borderLine))),
                        child: Row(
                          children: <Widget>[
                            Expanded(child:
                            Text(
                              _members[index],
                              style: TextStyle(
                                  fontSize: EMFont.emConListTitleFont),
                            ),),
                            Visibility(
                              visible: _type == Constant.defaultGroupMember,
                              child:
                              Row(children: <Widget>[
                                Visibility(
                                  visible: _members[index] == _owner,
                                  child: Text('群主'),),
                                Visibility(
                                  visible: _admins.contains(_members[index]),
                                  child: Text('管理员'),),
                                Visibility(
                                  visible: _blackList.contains(_members[index]),
                                  child: Text('黑名单'),),
                                Visibility(
                                  visible: _muteList.contains(_members[index]),
                                  child: Text('禁言'),),
                              ],),),

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
    if (_type == Constant.defaultGroupMember) {
      title = DemoLocalizations.of(context).groupMembers;
    }
    if (_type == Constant.removeGroupMember) {
      title = DemoLocalizations.of(context).removeMember;
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
    Navigator.of(context).pop(_isRefresh);
    return Future.value(false);
  }
}
