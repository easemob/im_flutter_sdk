import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'chat_page.dart';
import 'items/conversation_list_item.dart';
import 'package:im_flutter_sdk_example/utils/style.dart';
import 'package:im_flutter_sdk_example/utils/localizations.dart';
import 'package:im_flutter_sdk_example/utils/theme_util.dart';
import 'package:im_flutter_sdk_example/common/common.dart';
import 'package:im_flutter_sdk_example/utils/widget_util.dart';

class EMConversationListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EMConversationListPageState();
  }
}

class _EMConversationListPageState extends State<EMConversationListPage>
    implements
        EMChatManagerListener,
        EMConnectionListener,
        EMConversationListItemDelegate {
  var conList = List<EMConversation>();
  var sortMap = Map<String, EMConversation>();
  bool _isConnected = EMClient.getInstance.connected;
  String errorText;

  @override
  void initState() {
    super.initState();
    EMClient.getInstance.chatManager.addListener(this);
    EMClient.getInstance.addConnectionListener(this);
    _loadConversationList();
  }

  @override
  void dispose() {
    super.dispose();
    EMClient.getInstance.chatManager.removeListener(this);
    EMClient.getInstance.removeConnectionListener(this);
  }

  void _loadConversationList() async {
    try{
      conList = await EMClient.getInstance.chatManager.loadAllConversations();

      EMImPushConfigs pushConfigs = await EMClient.getInstance.pushManager.getImPushConfigs();
      await pushConfigs.setNoDisturb(true);
      await pushConfigs.setPushStyle(EMImPushStyle.Simple);

    }on EMError catch(e) {

    }finally {
      _refreshUI();
    }
  }

  void _refreshUI() {
    setState(() {});


  }

  Widget _buildConversationListView() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: conList.length,
        itemBuilder: (BuildContext context, int index) {
          return EMConversationListItem(conList[index], this);
        });
  }

  Widget _buildErrorItem() {
    return Visibility(
        visible: !_isConnected,
        child: Container(
          height: 30.0,
          color: ThemeUtils.isDark(context) ? EMColor.darkRed : EMColor.red,
          child: Center(
              child: Text(
            DemoLocalizations.of(context).unableConnectToServer,
            style: TextStyle(
                color: ThemeUtils.isDark(context)
                    ? EMColor.darkText
                    : EMColor.text),
          )),
        ));
  }

  Widget _buildSearchBar() {
    return InkWell(
      onTap: () {
        print('search');
      },
      child: Stack(
        children: <Widget>[
          Container(
            height: EMLayout.emSearchBarHeight,
            color: ThemeUtils.isDark(context)
                ? EMColor.darkBgColor
                : EMColor.bgColor,
          ),
          Container(
            padding: EdgeInsets.only(left: 8.0),
            margin: EdgeInsets.only(right: 8.0, left: 8.0),
            height: EMLayout.emSearchBarHeight,
            decoration: BoxDecoration(
              color: ThemeUtils.isDark(context)
                  ? EMColor.darkBgSearchBar
                  : EMColor.bgSearchBar,
              borderRadius: BorderRadius.all(
                  Radius.circular(EMLayout.emSearchBarHeight / 2)),
              border: Border.all(
                  width: 1,
                  color: ThemeUtils.isDark(context)
                      ? EMColor.darkBgSearchBar
                      : EMColor.bgSearchBar),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.search),
                Text(
                  DemoLocalizations.of(context).search,
                  style: TextStyle(
                      color: ThemeUtils.isDark(context)
                          ? EMColor.darkText
                          : EMColor.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    _sortConversation();
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(DemoLocalizations.of(context).conversation,
            style: TextStyle(
                fontSize: EMFont.emAppBarTitleFont,
                color: ThemeUtils.isDark(context)
                    ? EMColor.darkText
                    : EMColor.text)),
        leading: Icon(null),
        elevation: 0,
        // 隐藏阴影
        backgroundColor:
            ThemeUtils.isDark(context) ? EMColor.darkAppMain : EMColor.appMain,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.add,
              ),
              onPressed: () {}),
          SizedBox(width: 12.0),
        ],
      ),
      key: UniqueKey(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSearchBar(),
            _buildConversationListView(),
          ],
        ),
      ),
    );
  }

  /// 连接监听
  void onConnected() {
    debugPrint('onConnected');
    _isConnected = true;
    _refreshUI();
  }

  void onDisconnected(int errorCode) {
    debugPrint('onDisconnected');
    _isConnected = false;
    _refreshUI();
  }

  /// 消息监听
  void onMessagesReceived(List<EMMessage> messages) {
    _loadConversationList();
  }

  void onCmdMessagesReceived(List<EMMessage> messages) {}

  void onMessagesRead(List<EMMessage> messages) {}

  void onMessagesDelivered(List<EMMessage> messages) {}

  void onMessagesRecalled(List<EMMessage> messages) {}

  void onMessageChanged(EMMessage message) {}

  void _deleteConversation(EMConversation conversation) async {
    try{
      await EMClient.getInstance.chatManager.deleteConversation(conversation.id);
      _loadConversationList();
    }catch(e){
      print(e.toString());
    }
  }

  void _clearConversationUnread(EMConversation conversation) {
    conversation.markAllMessagesAsRead();
    _loadConversationList();
  }

  /// 点击事件
  @override
  void onTapConversation(EMConversation conversation) {
    Navigator.push<bool>(context,
        new MaterialPageRoute(builder: (BuildContext context) {
      return new ChatPage(conversation: conversation);
    })).then((bool _isRefresh) {
      _loadConversationList();
    });
  }

  int getType(EMConversationType type) {
    switch (type) {
      case EMConversationType.Chat:
        return Constant.chatTypeSingle;
      case EMConversationType.GroupChat:
        return Constant.chatTypeGroup;
      case EMConversationType.ChatRoom:
        return Constant.chatTypeChatRoom;
      default:
        return Constant.chatTypeSingle;
    }
  }

  /// 长按事件
  @override
  void onLongPressConversation(EMConversation conversation, Offset tapPos) {
    Map<String, String> actionMap = {
      Constant.deleteConversationKey:
      DemoLocalizations.of(context).deleteConversation,
      Constant.clearUnreadKey: DemoLocalizations.of(context).clearUnread,
    };
    WidgetUtil.showLongPressMenu(context, tapPos, actionMap, (String key) {
      if (key == Constant.deleteConversationKey) {
        _deleteConversation(conversation);
      } else if (key == Constant.clearUnreadKey) {
        _clearConversationUnread(conversation);
      }
    });
  }
}