import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/common/common.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';

import 'chat_page.dart';

class PublicGroupListPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PublicGroupListPageState();
  }
}

class _PublicGroupListPageState extends State<PublicGroupListPage>{

  var groupList = List<EMGroupInfo>();
  bool _loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPublicGroups();
  }

  void _getPublicGroups(){
    EMClient.getInstance().groupManager().getPublicGroupsFromServer(20, '',
    onSuccess: (result){
      groupList = result.getData();
      _loading = false;
      _refreshUI();
    },
    onError: (code, desc){
      WidgetUtil.hintBoxWithDefault(code.toString()+':'+desc);
    });
  }

  _refreshUI(){
    setState(() {

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
                _onTap(groupList[index]);
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

  Widget _buildContent(groupInfo){
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
              Text(groupInfo.getGroupName(), style: TextStyle(fontSize: EMFont.emConListTitleFont),),
            ],
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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

  void _onTap(EMGroupInfo groupInfo){
    EMClient.getInstance().groupManager().getGroupFromServer(groupInfo.getGroupId(),
        onSuccess: (group){
          if(group.isMemberOnly()) {
            EMClient.getInstance().groupManager().applyJoinToGroup(group.getGroupId(), '',
              onSuccess: (){
                WidgetUtil.hintBoxWithDefault('申请加入公开群成功，等待群主同意');
              },
              onError: (code, desc){
                WidgetUtil.hintBoxWithDefault('申请加入公开群失败：'+desc);
              });
          }else{
            EMClient.getInstance().groupManager().joinGroup(group.getGroupId(),
            onSuccess: (){
              WidgetUtil.hintBoxWithDefault('加入公开群成功');
              Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
                return new ChatPage(arguments: {'mType': Constant.chatTypeGroup,'toChatUsername':group.getGroupId()});
              }));
            },
            onError: (code, desc){
              WidgetUtil.hintBoxWithDefault('加入公开群失败：'+desc);
            }
            );
          }
        },
        onError: (code, desc){
          WidgetUtil.hintBoxWithDefault('获取群组详情失败：'+desc);
        }
    );
  }
}