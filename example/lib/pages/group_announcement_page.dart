

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';
import 'package:im_flutter_sdk_example/widgets/progress_dialog.dart';

class EMGroupAnnouncementPage extends StatefulWidget{

  final String _groupId;
  final bool _isVisible;
  const EMGroupAnnouncementPage(this._groupId, this._isVisible);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMGroupAnnouncementPageState(this._groupId, this._isVisible);
  }
}

class _EMGroupAnnouncementPageState extends State<EMGroupAnnouncementPage>{

  String _groupId;
  bool _isVisible;
  String _announcement = '';
  bool _loading = true;
  TextEditingController _editTextController;

  _EMGroupAnnouncementPageState(this._groupId, this._isVisible);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchGroupAnnouncement();
  }

  void _fetchGroupAnnouncement(){
    EMClient.getInstance().groupManager().fetchGroupAnnouncement(_groupId,
    onSuccess: (announcement){
      _announcement = announcement;
      _editTextController = new TextEditingController(text: _announcement);
      _refreshUI(false);
    },
    onError: (code, desc){
      WidgetUtil.hintBoxWithDefault(code.toString()+':'+desc);
      _refreshUI(false);
    });
  }

  _refreshUI(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  Widget _buildAnnouncementView(){
    if(_isVisible) {
      return TextField(
        autofocus: false,
        controller: _editTextController,
        maxLines: 5,
        maxLength: 300,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      );
    }
    return Text(
      _announcement,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        appBar: WidgetUtil.buildAppBar(context, DemoLocalizations
            .of(context)
            .groupAnnouncement),
        body: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: _buildAnnouncementView(),
            ),
            ProgressDialog(loading: _loading, msg: DemoLocalizations
                .of(context)
                .loading,),
          ],
        ),
      ),
    );
  }

  Future<bool> _willPop () { //返回值必须是Future<bool>
    Navigator.of(context).pop( _isVisible? _editTextController.text : _announcement);
    return Future.value(false);
  }
}