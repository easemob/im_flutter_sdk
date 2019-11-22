import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';

class EMChatGroupListItem extends StatefulWidget{

  final EMGroup emGroup;
  final EMChatGroupListItemDelegate delegate;
  const EMChatGroupListItem(this.emGroup, this.delegate);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMChatGroupListItemState(this.emGroup, this.delegate);
  }
}

class _EMChatGroupListItemState extends State<EMChatGroupListItem>{

  EMGroup emGroup;
  EMChatGroupListItemDelegate delegate;

  _EMChatGroupListItemState(this.emGroup, this.delegate);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _onTaped() {
    if(this.delegate != null) {
      this.delegate.onTapChatGroup(this.emGroup);
    }else {
      print("没有实现 EMChatGroupListItemDelegate");
    }
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

  Widget _buildContent(){
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
              Text(emGroup.getGroupName(), style: TextStyle(fontSize: EMFont.emConListTitleFont),),
            ],
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      child: InkWell(
        onTap: (){
          _onTaped();
        },
        child: Container(
          height: EMLayout.emContactListItemHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildPortrait(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class EMChatGroupListItemDelegate {
  void onTapChatGroup(EMGroup group);
}