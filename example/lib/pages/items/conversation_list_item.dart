import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/time_util.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';

class EMConversationListItem extends StatefulWidget {
  final EMConversation con;
  final EMConversationListItemDelegate delegate;
  const EMConversationListItem(this.con, this.delegate);
  @override
  State<StatefulWidget> createState() {
    return _EMConversationListItemState(this.con, this.delegate);
  }
}

class _EMConversationListItemState extends State<EMConversationListItem> {
  EMConversationListItemDelegate delegate;
  EMConversation con;
  EMMessage message;
  int underCount;
  String titleName;
  String content;
  Offset tapPos;
  bool _isDark;

  _EMConversationListItemState(
      EMConversation con, EMConversationListItemDelegate delegate) {
    this.con = con;
    this.delegate = delegate;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    message = await con.latestMessage;
    if (message == null) {
      return;
    }
    content = '';
    switch (message.body.type) {
      case EMMessageBodyType.TXT:
        var body = message.body as EMTextMessageBody;
        content = body.content;
        break;
      case EMMessageBodyType.IMAGE:
        content = '[图片]';
        break;
      case EMMessageBodyType.VIDEO:
        content = '[视频]';
        break;
      case EMMessageBodyType.FILE:
        content = '[文件]';
        break;
      case EMMessageBodyType.VOICE:
        content = '[语音]';
        break;
      case EMMessageBodyType.LOCATION:
        content = '[位置]';
        break;
      default:
        content = '';
    }

    underCount = await con.unreadCount;
    titleName = con.id;
    if (con.type != EMConversationType.Chat) {
      EMGroup group =
          await EMClient.getInstance.groupManager.getGroupWithId(con.id);
      if (group != null) {
        titleName = group.name;
      }
    }
    _refresh();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTaped() {
    if (this.delegate != null) {
      this.delegate.onTapConversation(this.con);
    } else {
      print("没有实现 EMConversationListItemDelegate");
    }
  }

  void _onLongPressed() {
    if (this.delegate != null) {
      this.delegate.onLongPressConversation(this.con, this.tapPos);
    } else {
      print("没有实现 EMConversationListItemDelegate");
    }
  }

  Widget _buildUserPortrait() {
    Widget protraitWidget = Image.asset('images/default_avatar.png');
    if (con.type != EMConversationType.Chat) {
      protraitWidget = Image.asset('images/group_icon.png');
    }

    return ClipOval(
      child: Container(
        height: EMLayout.emConListPortraitSize,
        width: EMLayout.emConListPortraitSize,
        child: protraitWidget,
      ),
    );
  }

  Widget _buildUnreadMark() {
    if (underCount > 0) {
      String count = underCount.toString();
      double width = EMLayout.emConListUnreadSize;
      if (underCount > 9) {
        width = EMLayout.emConListUnreadSize / 2 * 3;
      }
      if (underCount > 99) {
        count = '99+';
        width = EMLayout.emConListUnreadSize * 2;
      }
      return Positioned(
        right: 0.0,
        top: 0.0,
        child: Container(
            width: width,
            height: EMLayout.emConListUnreadSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(EMLayout.emConListUnreadSize / 2.0),
              color: _isDark ? EMColor.darkRed : EMColor.red,
            ),
            child: Text(count,
                style: TextStyle(
                  fontSize: EMFont.emConUnreadFont,
                  color:
                      _isDark ? EMColor.darkUnreadCount : EMColor.unreadCount,
                ))),
      );
    }
    return WidgetUtil.buildEmptyWidget();
  }

  Widget _buildPortrait() {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 8,
            ),
            _buildUserPortrait(),
          ],
        ),
        _buildUnreadMark(),
      ],
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Container(
        height: EMLayout.emConListItemHeight,
        margin: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 0.5,
                    color: _isDark
                        ? EMColor.darkBorderLine
                        : EMColor.borderLine))),
        child: Row(
          children: <Widget>[
            _buildTitle(),
            _buildTime(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titleName,
            style: TextStyle(
                fontSize: EMFont.emConListTitleFont,
                fontWeight: FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            content,
            style: TextStyle(
                fontSize: EMFont.emConListContentFont,
                color: _isDark ? EMColor.darkTextGray : EMColor.textGray),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildTime() {
    var time = TimeUtil.convertTime(message.serverTime);
    return Container(
      width: EMLayout.emConListItemHeight,
      margin: EdgeInsets.only(right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(time,
              style: TextStyle(
                  fontSize: EMFont.emConListTimeFont,
                  color: _isDark ? EMColor.darkTextGray : EMColor.textGray)),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isDark = ThemeUtils.isDark(context);
    if (!(message == null)) {
      return Material(
        color: _isDark ? EMColor.darkBgColor : EMColor.bgColor,
        child: InkWell(
          onTapDown: (TapDownDetails details) {
            tapPos = details.globalPosition;
          },
          onTap: () {
            _onTaped();
          },
          onLongPress: () {
            _onLongPressed();
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
    return WidgetUtil.buildEmptyWidget();
  }
}

abstract class EMConversationListItemDelegate {
  ///点击了会话 item
  void onTapConversation(EMConversation conversation);

  ///长按了会话 item
  void onLongPressConversation(EMConversation conversation, Offset tapPos);
}
