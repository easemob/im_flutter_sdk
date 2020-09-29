import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';

import 'chat_page.dart';

class PublicGroupListPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _PublicGroupListPageState();
  }
}

class _PublicGroupListPageState extends State<PublicGroupListPage>{

  var groupList = List();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getPublicGroups();
  }

  void _getPublicGroups() async{
    try {
      EMCursorResult result = await EMClient.getInstance().groupManager.getPublicGroupsFromServer();
      groupList = result.data;
    }catch(e){
      WidgetUtil.hintBoxWithDefault(e.toString());
    } finally {
      _loading = false;
      _refreshUI();
    }
  }

  _refreshUI(){
    setState(() {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildChatRoomListView(){
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: groupList.length,
        itemBuilder:(BuildContext context, int index){
          if(groupList.length <= 0){
            return WidgetUtil.buildEmptyWidget();
          }
          return InkWell(
              onTap: (){
                _onTap(index);
            },
            child: Container(
              height: EMLayout.emContactListItemHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildPortrait(),
                  _buildContent(groupList[index]),
                  ],
                ),
              ),
            );
        }
    );
  }

  Widget _buildPortrait(){
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 8,
            ),
            ClipOval(
              child: Container(
                height: EMLayout.emContactListPortraitSize,
                width: EMLayout.emContactListPortraitSize,
                child: Image.asset('images/group_icon.png'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(EMGroup group){
    return Expanded(
      child: Container(
          height: EMLayout.emContactListItemHeight,
          margin: EdgeInsets.only(left:10, right: 10),
          decoration:  BoxDecoration(
              border: Border(
                  bottom: BorderSide(width: 0.5, color: ThemeUtils.isDark(context) ? EMColor.darkBorderLine : EMColor.borderLine)
              )
          ),
          child: Row(
            children: <Widget>[
              Text(group.name, style: TextStyle(fontSize: EMFont.emConListTitleFont),),
            ],
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle : true,
        backgroundColor: ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
        title: Text(DemoLocalizations.of(context).publicGroups, style: TextStyle(color: ThemeUtils.isDark(context) ? EMColor.darkText : EMColor.text)),
      ),
      key: UniqueKey(),
      body: Stack(children: <Widget>[
        _buildChatRoomListView(),
        ProgressDialog(loading: _loading, msg: DemoLocalizations.of(context).loading,),
      ],
      ),
    );
  }

  void _onTap(int index) async {
    try{
      EMGroup tapGroup = groupList[index];
      EMGroup group = await EMClient.getInstance().groupManager.getGroupSpecificationFromServer(groupId: tapGroup.groupId);
      groupList[index] = group;
      if(group.settings.style == EMGroupStyle.PublicOpenJoin) {
        EMClient.getInstance().groupManager.joinPublicGroup(groupId: group.groupId);
        WidgetUtil.hintBoxWithDefault('加入成功');
      }else {
        EMClient.getInstance().groupManager.requestToJoinPublicGroup(groupId: group.groupId);
        WidgetUtil.hintBoxWithDefault('申请加入公开群成功，等待群主同意');
      }
    }catch(e){
        WidgetUtil.hintBoxWithDefault('请求失败' + e.toString());
    }
  }
}