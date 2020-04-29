import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/common/common.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

import 'chat_page.dart';
import 'items/chatgroup_list_item.dart';


class EMChatGroupListPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMChatGroupListPageState();
  }
}

class _EMChatGroupListPageState extends State<EMChatGroupListPage> implements EMChatGroupListItemDelegate{

  var groupList = List<EMGroup>();
  bool _loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getJoinedGroups();
  }

  void getJoinedGroups() async{
    _loading = true;
    EMClient.getInstance().groupManager().getJoinedGroupsFromServer(
        onSuccess: (groups){
          groupList = groups;
          _refreshUI(false);
        },
        onError: (code, desc){
          WidgetUtil.hintBoxWithDefault(code.toString()+':'+desc);
          _refreshUI(false);
        }
    );
  }

  _refreshUI(bool loading){
    setState(() {
      _loading = loading;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _buildCreateGroupItem(){
    return InkWell(
      onTap: (){
        WidgetUtil.hintBoxWithDefault('默认创建可直接加入公开群');
        _refreshUI(true);
        EMClient.getInstance().groupManager().createGroup('可直接加入的公开群' + DateTime.now().millisecondsSinceEpoch.toString(), '', [], '', EMGroupOptions(maxUsers : 2000, style: EMGroupStyle.EMGroupStylePublicOpenJoin),
        onSuccess: (group){
          WidgetUtil.hintBoxWithDefault('创建群组成功');
          getJoinedGroups();
        },
        onError: (code, desc){
          WidgetUtil.hintBoxWithDefault(code.toString() +':'+ desc);
          _refreshUI(false);
        });
      },
      child : Container(
        height: 67,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 8.0),
              height: 67,
              child: Row(
                children: <Widget>[
                  ClipOval(
                    child: Image.asset('images/chatgroup@2x.png', width: EMLayout.emContactListPortraitSize,height: EMLayout.emContactListPortraitSize,),
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  Text(DemoLocalizations.of(context).createGroup, style: TextStyle(fontSize: 18.0),)
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 64.0,
              height: 1.0,
              color: Color(0xffe5e5e5),
              margin: EdgeInsets.fromLTRB(64.0, 66.0, 0.0, 0.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicGroupsItem(){
    return InkWell(
      onTap: (){
        Navigator.of(context).pushNamed(Constant.toPublicGroupListPage);
      },
      child : Container(
        height: 67,
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 8.0),
              height: 67,
              child: Row(
                children: <Widget>[
                  ClipOval(
                    child: Image.asset('images/chatgroup@2x.png', width: EMLayout.emContactListPortraitSize,height: EMLayout.emContactListPortraitSize,),
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  Text(DemoLocalizations.of(context).publicGroups, style: TextStyle(fontSize: 18.0),)
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 64.0,
              height: 1.0,
              color: Color(0xffe5e5e5),
              margin: EdgeInsets.fromLTRB(64.0, 66.0, 0.0, 0.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatGroupListView(){
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: groupList.length + 2,
        itemBuilder:(BuildContext context, int index){
          if(index == 0){
            return _buildCreateGroupItem();
          }
          if(index == 1){
            return _buildPublicGroupsItem();
          }
          return EMChatGroupListItem(groupList[index - 2], this);
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle : true,
        backgroundColor: ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
        title: Text(DemoLocalizations.of(context).chatGroup, style: TextStyle(color: ThemeUtils.isDark(context) ? EMColor.darkText : EMColor.text)),
      ),
      key: UniqueKey(),
      body: Stack(children: <Widget>[
        _buildChatGroupListView(),
        ProgressDialog(loading: _loading, msg: DemoLocalizations.of(context).loading,),
      ],
      ),
    );
  }

  void onTapChatGroup(EMGroup group){
    Navigator.push<bool>(context, new MaterialPageRoute(builder: (BuildContext context){
      return new ChatPage(arguments: {'mType': Constant.chatTypeGroup,'toChatUsername':group.getGroupId()});
    })).then((bool isRefresh){
      if(isRefresh){
        getJoinedGroups();
      }
    });
  }
}