import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

import 'items/group_pick_contacts_item.dart';

class EMGroupPickContactsPage extends StatefulWidget{

  final String _groupId;

  const EMGroupPickContactsPage(this._groupId);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMGroupPickContactsPageState(this._groupId);
  }
}

class _EMGroupPickContactsPageState extends State<EMGroupPickContactsPage> implements EMGroupPickContactsItemDelegate{

  String _groupId;
  var _contactList = List<String>();
  var _groupMemberList = List<String>();
  var _addContacts = List<String>();
  bool _loading = true;

  _EMGroupPickContactsPageState(this._groupId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchContactData();
  }

  void _fetchContactData() async{
    EMGroup emGroup = await EMClient.getInstance().groupManager().getGroup(_groupId);
    _groupMemberList.add(emGroup.getOwner());
    emGroup.getAdminList().forEach((admin) => _groupMemberList.add(admin));
    emGroup.getMembers().forEach((member) => _groupMemberList.add(member));
    emGroup.getBlackList().forEach((member) => _groupMemberList.add(member));
    EMClient.getInstance().contactManager().getAllContactsFromServer(
      onSuccess: (contacts){
        _contactList = contacts;
        _groupMemberList.forEach((member){
          if(_contactList.contains(member)){
            _contactList.remove(member);
          }
        });
        _refreshUI(false);
      },
      onError: (code, desc){
        WidgetUtil.hintBoxWithDefault(code.toString() +':'+ desc);
        _refreshUI(false);
      }
    );
  }

  _refreshUI(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  Widget _buildListView(){
    return ListView.builder(
        itemCount: _contactList.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index){

          return EMGroupPickContactsItem(_contactList[index], this);
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        appBar: WidgetUtil.buildAppBar(context, DemoLocalizations.of(context).pickContact),
        body: Stack(
          children: <Widget>[
            _buildListView(),
            ProgressDialog(loading: _loading, msg: DemoLocalizations.of(context).loading,),
          ],
        ),
      ),
    );
  }

  Future<bool> _willPop () { //返回值必须是Future<bool>
    Navigator.of(context).pop(_addContacts);
    return Future.value(false);
  }

  @override
  void onTapContact(String contact, bool isSelected) {
    // TODO: implement onTapContact
    if(isSelected){
      _addContacts.add(contact);
    }else{
      _addContacts.remove(contact);
    }
  }
}

