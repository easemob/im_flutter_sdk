

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';

import '../../ease_user_info.dart';
import 'message_item_factory.dart';


// ignore: must_be_immutable
class ChatItem extends StatefulWidget {
  EMMessage message ;
  ChatItemDelegate delegate;
  bool showTime;

  ChatItem(ChatItemDelegate delegate,EMMessage msg,bool showTime) {
    this.message = msg;
    this.delegate = delegate;
    this.showTime = showTime;
  }

  @override
  State<StatefulWidget> createState() {
    return new _ChatItemState(this.delegate,this.message,this.showTime);
  }

}

class _ChatItemState extends State<ChatItem> {
  EMMessage message ;
  ChatItemDelegate delegate;
  bool showTime;
  UserInfo user;
  Offset tapPos;

  _ChatItemState(ChatItemDelegate delegate,EMMessage msg,bool showTime) {
    this.message = msg;
    this.delegate = delegate;
    this.showTime = showTime;
    this.user = UserInfoDataSource.getUserInfo(msg.from);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child:Column(
        children: <Widget>[
          this.showTime? WidgetUtil.buildMessageTimeWidget(message.msgTime):WidgetUtil.buildEmptyWidget(),
          Row(
            children: <Widget>[subContent()],
          )
        ],
      ),
    );
  }

  Widget subContent() {
    if (message.direction == Direction.SEND) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: Text(this.user.userId,style: TextStyle(fontSize: 13,color: Color(0xff9B9B9B))),
                  ),
                  buildMessageWidget(),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                __onTapedUserPortrait();
              },
              child: WidgetUtil.buildUserPortrait(this.user.portraitUrl),
            ),
          ],
        ),
      );
    } else if (message.direction == Direction.RECEIVE) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                __onTapedUserPortrait();
              },
              child: WidgetUtil.buildUserPortrait(this.user.portraitUrl),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Text(this.user.userId,style: TextStyle(color: Color(0xff9B9B9B)),),
                  ),
                  buildMessageWidget(),
                ],
              ),
            ),
          ],
        ),
      );
    }else {
      return WidgetUtil.buildEmptyWidget();
    }
  }

  Widget buildMessageWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              padding: EdgeInsets.fromLTRB(15, 6, 15, 10),
              alignment: message.direction == Direction.SEND
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (TapDownDetails details) {
                  this.tapPos = details.globalPosition;
                },
                onTap: () {
                  __onTapedMesssage();
                },
                onLongPress: () {
                  __onLongPressMessage(this.tapPos);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MessageItemFactory(message: message) ,
                ) ,
              )
          ),
        )
      ],
    );
  }

  void __onTapedMesssage() {
    if(delegate != null) {
      delegate.onTapMessageItem(message);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

  void __onLongPressMessage(Offset tapPos) {
    if(delegate != null) {
      delegate.onLongPressMessageItem(message,tapPos);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

  void __onTapedUserPortrait() {
    if(delegate != null) {
      delegate.onTapUserPortrait(message.userName);
    }else {
      print("没有实现 ConversationItemDelegate");
    }
  }

}

abstract class ChatItemDelegate {
  //点击消息
  void onTapMessageItem(EMMessage message);
  //长按消息
  void onLongPressMessageItem(EMMessage message,Offset tapPos);
  //点击用户头像
  void onTapUserPortrait(String userId);
}