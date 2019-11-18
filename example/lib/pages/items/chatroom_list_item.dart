import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';

class EMChatRoomListItem extends StatefulWidget{

  final EMChatRoom emChatRoom;
  final EMChatRoomListItemDelegate delegate;
  const EMChatRoomListItem(this.emChatRoom, this.delegate);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMChatRoomListItemState(this.emChatRoom, this.delegate);
  }
}

class _EMChatRoomListItemState extends State<EMChatRoomListItem>{

  EMChatRoom emChatRoom;
  EMChatRoomListItemDelegate delegate;

  _EMChatRoomListItemState(this.emChatRoom, this.delegate);

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
      this.delegate.onTapChatRoom(this.emChatRoom);
    }else {
      print("没有实现 EMChatRoomListItemDelegate");
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
                height: EMLayout.emConListPortraitSize,
                width: EMLayout.emConListPortraitSize,
                child: Image.asset('images/chatroom_icon.png'),
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
        height: EMLayout.emConListItemHeight,
        margin: EdgeInsets.only(left:10, right: 10),
        decoration:  BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 0.5, color: ThemeUtils.isDark(context) ? EMColor.darkBorderLine : EMColor.borderLine)
            )
        ),
        child: Row(
          children: <Widget>[
            Text(emChatRoom.getName(), style: TextStyle(fontSize: EMFont.emConListTitleFont),),
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
         height: EMLayout.emConListItemHeight,
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

abstract class EMChatRoomListItemDelegate {
  void onTapChatRoom(EMChatRoom room);
}