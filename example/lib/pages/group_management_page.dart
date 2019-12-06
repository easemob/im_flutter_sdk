import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/common/common.dart';
import 'package:im_flutter_sdk_example/pages/group_black_list_page.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

class EMGroupManagementPage extends StatefulWidget{

  final String _groupId;
  final bool _isOwner;
//  var _blackList = List<String>();
//  var _muteList = List<String>();
  final List<String> _blackList;
  final List<String> _muteList;
  final List<String> _adminList;

  const EMGroupManagementPage(this._groupId, this._isOwner, this._blackList, this._muteList, this._adminList);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMGroupManagementPageState(this._groupId, this._isOwner, this._blackList, this._muteList, this._adminList);
  }
}

class _EMGroupManagementPageState extends State<EMGroupManagementPage> {
  String _groupId;
  bool _isOwner;
  var _blackList = List<String>();
  var _muteList = List<String>();
  var _adminList = List<String>();
  bool _isRefresh = false;

  _EMGroupManagementPageState(this._groupId, this._isOwner, this._blackList, this._muteList, this._adminList);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  _refreshUI(){
    setState(() {

    });
  }

  Widget _buildBlackManagement(){

    return InkWell(
      onTap: (){
        Navigator.push<List<String>>(context,
            new MaterialPageRoute(builder: (BuildContext context) {
              return EMGroupBlackListPage(this._groupId, this._blackList, Constant.blackList);
            })).then((List<String> _members){
              _blackList = _members;
              _isRefresh = true;
              _refreshUI();
              });
      },
      child: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 0.5,
                    color: ThemeUtils.isDark(context)
                        ? EMColor.darkBorderLine
                        : EMColor.borderLine))),
        height: EMLayout.emContactListItemHeight,
        child: Row(
          children: <Widget>[
            Text('黑名单管理'),
            Expanded(
              child: Text(''),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text(_blackList.length.toString() + '人'),
                  SizedBox(
                    width: 10.0,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuteManagement(){
    return InkWell(
      onTap: (){
        Navigator.push<List<String>>(context,
            new MaterialPageRoute(builder: (BuildContext context) {
              return EMGroupBlackListPage(this._groupId, this._muteList, Constant.muteList);
            })).then((List<String> _members){
              _muteList = _members;
              _isRefresh = true;
              _refreshUI();});
      },
      child: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 0.5,
                    color: ThemeUtils.isDark(context)
                        ? EMColor.darkBorderLine
                        : EMColor.borderLine))),
        height: EMLayout.emContactListItemHeight,
        child: Row(
          children: <Widget>[
            Text('禁言管理'),
            Expanded(
              child: Text(''),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text(_muteList.length.toString() + '人'),
                  SizedBox(
                    width: 10.0,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminManagement(){
    return Visibility(
      visible: _isOwner,
      child: InkWell(
        onTap: (){
          Navigator.push<List<String>>(context,
              new MaterialPageRoute(builder: (BuildContext context) {
                return EMGroupBlackListPage(this._groupId, this._adminList, Constant.adminList);
              })).then((List<String> _members){
                _adminList = _members;
                _isRefresh = true;
                _refreshUI();});
        },
        child: Container(
          margin: EdgeInsets.only(left: 20.0, right: 20.0),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 0.5,
                      color: ThemeUtils.isDark(context)
                          ? EMColor.darkBorderLine
                          : EMColor.borderLine))),
          height: EMLayout.emContactListItemHeight,
          child: Row(
            children: <Widget>[
              Text('管理员管理'),
              Expanded(
                child: Text(''),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Text(_adminList.length.toString() + '人'),
                    SizedBox(
                      width: 10.0,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        appBar: WidgetUtil.buildAppBar(context, DemoLocalizations.of(context).groupManagement),
        body: Column(
            children: <Widget>[
              _buildBlackManagement(),
              _buildMuteManagement(),
              _buildAdminManagement(),
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