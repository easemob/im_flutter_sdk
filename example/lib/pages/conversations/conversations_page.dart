import 'package:easeim_flutter_demo/pages/conversations/conversation_item.dart';
import 'package:easeim_flutter_demo/unit/event_bus_manager.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:easeim_flutter_demo/widgets/pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

// ignore: must_be_immutable
class ConversationPage extends StatefulWidget with ChangeNotifier {
  int totalUnreadCount = 0;

  updateCount(int count) {
    totalUnreadCount = count;
    notifyListeners();
  }

  @override
  State<StatefulWidget> createState() => ConversationPageState();
}

class ConversationPageState extends State<ConversationPage>
    implements EMChatManagerListener {
  List<EMConversation> _conversationsList = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  var notifier;
  @override
  void initState() {
    super.initState();
    // 添加环信回调监听
    EMClient.getInstance.chatManager.addListener(this);
    notifier = eventBus.on<EventBusManager>().listen((event) {
      if (event.eventKey == EventBusManager.updateConversationsList) {
        _reLoadAllConversations();
      }
    });
  }

  void dispose() {
    _refreshController.dispose();
    // 移除环信回调监听
    EMClient.getInstance.chatManager.removeListener(this);
    notifier.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar(
        '会话',
        rightWidgets: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => PopMenu.show(
              context,
              [
                PopMenuItem('创建群组'),
                PopMenuItem('添加好友'),
                PopMenuItem('多人通话'),
              ],
              callback: (index) {
                if (index == 0) {
                } else if (index == 1) {
                  Navigator.of(context)
                      .pushNamed('/addFriends')
                      .then((value) {});
                } else if (index == 2) {
                  Navigator.of(context).pushNamed('/contactSelect').then(
                    (value) async {
                      List<String> users = value as List<String>;
                      if (users.length > 0) {}
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        onRefresh: () => _reLoadAllConversations(),
        controller: _refreshController,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.transparent,
              titleSpacing: 0,
              floating: false,
              centerTitle: true,
              title: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    EdgeInsets.zero,
                  ),
                ),
                onPressed: () {
                  print('search');
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: sWidth(16),
                    right: sWidth(16),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),
                  height: sWidth(36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: sWidth(16),
                      ),
                      Icon(
                        Icons.search,
                        color: Color.fromRGBO(204, 204, 204, 1),
                      ),
                      Text(
                        '请输入会话名称',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: sFontSize(16),
                          color: Color.fromRGBO(204, 204, 204, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return conversationWidgetForIndex(index);
                },
                childCount: _conversationsList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 更新会话列表
  void _reLoadAllConversations() async {
    try {
      List<EMConversation> list =
          await EMClient.getInstance.chatManager.loadAllConversations();
      _conversationsList.clear();
      _conversationsList.addAll(list);
      _refreshController.refreshCompleted();
      int count = 0;
      for (var conversation in _conversationsList) {
        count += conversation.unreadCount;
      }
      widget.updateCount(count);
    } on Error {
      _refreshController.refreshFailed();
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 获取会话列表widget
  Widget conversationWidgetForIndex(int index) {
    return slidableItem(
      child: ConversationItem(
        conversation: _conversationsList[index],
        onTap: () => {_conversationItemOnPress(index)},
      ),
      // 侧滑事件，有必要可以加上置顶之类的
      actions: [slidableDeleteAction(onTap: () => _deleteConversation(index))],
    );
  }

  /// 侧滑删除按钮点击
  _deleteConversation(int index) async {
    try {
      await EMClient.getInstance.chatManager.deleteConversation(
        _conversationsList[index].id,
      );
      _conversationsList.removeAt(index);
    } on Error {
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 会话被点击
  _conversationItemOnPress(int index) async {
    EMConversation con = _conversationsList[index];
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: [con.name, con],
    ).then((value) {
      // 返回时刷新页面
      _reLoadAllConversations();
    });
  }

  @override
  void onCmdMessagesReceived(List<EMMessage> messages) {}

  @override
  void onMessagesDelivered(List<EMMessage> messages) {}

  @override
  void onMessagesRead(List<EMMessage> messages) {
    bool needReload = false;
    for (var msg in messages) {
      if (msg.to == EMClient.getInstance.currentUsername) {
        needReload = true;
        break;
      }
    }
    if (needReload) {
      _reLoadAllConversations();
    }
  }

  @override
  void onMessagesRecalled(List<EMMessage> messages) {}

  @override
  void onMessagesReceived(List<EMMessage> messages) {
    _reLoadAllConversations();
  }

  @override
  void onConversationRead(String from, String to) {}

  @override
  void onConversationsUpdate() {}

  @override
  void onGroupMessageRead(List<EMGroupMessageAck> groupMessageAcks) {}
}
