import 'package:easeim_flutter_demo/widgets/wx_expression.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class ConversationItem extends StatefulWidget {
  @override
  const ConversationItem({
    required this.conversation,
    this.onTap,
  });
  final EMConversation conversation;
  final VoidCallback? onTap;

  _ConversationItemState createState() => _ConversationItemState();
}

class _ConversationItemState extends State<ConversationItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.grey[300],
      onTap: () => this.widget.onTap?.call(),
      child: Container(
        height: sWidth(74),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                // 头像
                Positioned(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: sWidth(16),
                      top: sHeight(14),
                      bottom: sHeight(14),
                      right: sWidth(11),
                    ),
                    child: // 头像，可以替换为用户相关的头像url
                        Image.asset(
                      'images/contact_default_avatar.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // 未读数
                Positioned(
                  top: sHeight(10),
                  right: sWidth(5),
                  child: FutureBuilder<int>(
                    future: _unreadCount(),
                    builder: (context, snapshot) {
                      return unreadCountWidget(snapshot.data ?? 0);
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // 姓名
                        Container(
                          padding: EdgeInsets.only(top: sHeight(10)),
                          child: Text(
                            _showName(),
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: sFontSize(17),
                            ),
                          ),
                        ),
                        // 时间
                        Container(
                          margin: EdgeInsets.only(
                              left: sWidth(5), right: sWidth(12)),
                          child: FutureBuilder<String>(
                            future: _latestMessageTime(),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? "",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Color.fromRGBO(153, 153, 153, 1),
                                  fontSize: sFontSize(12),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 详情
                  Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.only(right: sWidth(10)),
                        child: FutureBuilder<String?>(
                          future: _showInfo(),
                          builder: (context, snapshot) {
                            return ExpressionText(
                              snapshot.data ?? "",
                              TextStyle(
                                color: Color.fromRGBO(153, 153, 153, 1),
                                fontSize: sFontSize(14),
                              ),
                              maxLine: 1,
                            );
                          },
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 消息详情
  Future<String> _showInfo() async {
    String showInfo = '';
    EMMessage? _latestMessage = await this.widget.conversation.latestMessage();
    if (_latestMessage == null) {
      return showInfo;
    }

    switch (_latestMessage.body.type) {
      case MessageType.TXT:
        var body = _latestMessage.body as EMTextMessageBody;
        showInfo = body.content;
        break;
      case MessageType.IMAGE:
        showInfo = '[图片]';
        break;
      case MessageType.VIDEO:
        showInfo = '[视频]';
        break;
      case MessageType.FILE:
        showInfo = '[文件]';
        break;
      case MessageType.VOICE:
        showInfo = '[语音]';
        break;
      case MessageType.LOCATION:
        showInfo = '[位置]';
        break;
      default:
        showInfo = '';
    }
    return showInfo;
  }

  /// 显示的名称
  String _showName() {
    return this.widget.conversation.id;
  }

  /// 未读数
  Future<int> _unreadCount() async {
    return this.widget.conversation.unreadCount();
  }

  /// 消息时间
  Future<String> _latestMessageTime() async {
    EMMessage? msg = await this.widget.conversation.latestMessage();
    return timeStrByMs(msg?.serverTime ?? 0);
  }
}
