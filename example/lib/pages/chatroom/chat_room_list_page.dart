import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatRoomsListPages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatRoomsListPagesState();
}

class ChatRoomsListPagesState extends State<ChatRoomsListPages> {
  List<EMChatRoom> _roomsList = [];
  int _pageCount = 0;
  bool _isEnd = false;
  String _searchName = '';
  EMChatRoom? _searchedRoom;
  final _pageSize = 30;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar('聊天室'),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: sHeight(50),
              padding: EdgeInsets.only(left: sWidth(20), right: sWidth(20)),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(sWidth(20)),
                  ),
                  child: TextFormField(
                    focusNode: null,
                    textInputAction: TextInputAction.search,
                    onChanged: (text) {
                      _searchName = text;
                      if (_searchName.length == 0) {
                        _searchedRoom = null;
                        if (mounted) {
                          setState(() {});
                        }
                      }
                    },
                    style: TextStyle(
                      fontSize: sFontSize(14),
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.multiline,
                    controller: null,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(
                        sWidth(16),
                        sHeight(8),
                        sWidth(16),
                        sHeight(6),
                      ),
                      hintText: '请输入聊天室id',
                      hintStyle: TextStyle(
                        fontSize: sFontSize(14),
                        color: Colors.grey,
                      ),
                    ),
                    onFieldSubmitted: (str) {
                      _searchId(str);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: !_isEnd,
                onRefresh: _loadMoreRooms,
                onLoading: () => _loadMoreRooms(true),
                controller: _refreshController,
                child: ListView.separated(
                  itemBuilder: ((_, index) {
                    if (_searchedRoom != null) {
                      return _chatRoomItem(_searchedRoom!);
                    } else {
                      EMChatRoom room = _roomsList[index];
                      return _chatRoomItem(room);
                    }
                  }),
                  separatorBuilder: ((_, index) {
                    return Divider(
                      color: Colors.grey[300],
                      height: 0.3,
                    );
                  }),
                  itemCount: _searchName.length != 0 && _searchedRoom != null
                      ? 1
                      : _roomsList.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  _chatRoomItem(EMChatRoom room) {
    return Container(
      height: sHeight(70),
      // height: sHeight(44),
      child: ListTile(
        onTap: () => _chatToRoom(room),
        title: Text(
          room.name ?? room.roomId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: sFontSize(16),
          ),
        ),
        subtitle: Text(
          room.roomId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: sFontSize(13),
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  _loadMoreRooms([bool isMore = false]) async {
    if (!isMore) {
      _pageCount = 0;
      _isEnd = false;
    }
    try {
      EMPageResult<EMChatRoom> result = await EMClient
          .getInstance.chatRoomManager
          .fetchPublicChatRoomsFromServer(pageSize: 30, pageNum: _pageCount);

      _pageCount = result.pageCount;
      if (!isMore) {
        _roomsList.clear();
      }
      if (result.data != null) {
        _roomsList.addAll(result.data!);
        if (_pageSize > result.data!.length) {
          _isEnd = true;
        } else {
          _isEnd = false;
        }
      }

      SmartDialog.showToast('获取成功');
      isMore
          ? _refreshController.loadComplete()
          : _refreshController.refreshCompleted();
      if (mounted) {
        setState(() {});
      }
    } on EMError catch (e) {
      SmartDialog.showToast('获取失败$e');
      isMore
          ? _refreshController.loadComplete()
          : _refreshController.refreshCompleted();
    } finally {}
  }

  _chatToRoom(EMChatRoom room) async {
    EMConversation? con =
        await EMClient.getInstance.chatManager.getConversation(
      room.roomId,
      EMConversationType.ChatRoom,
    );
    if (con == null) {
      SmartDialog.showToast('会话创建失败');
      return;
    }

    Navigator.of(context).pushNamed(
      '/chat',
      arguments: [con.id, con],
    ).then((value) =>
        EMClient.getInstance.chatRoomManager.leaveChatRoom(room.roomId));
  }

  _searchId(String std) async {
    if (std.length == 0) return;
    try {
      SmartDialog.showLoading(msg: '搜索中...');
      _searchedRoom = await EMClient.getInstance.chatRoomManager
          .fetchChatRoomInfoFromServer(std);
    } on EMError catch (e) {
      SmartDialog.showToast('搜索失败: $e');
    } finally {
      SmartDialog.dismiss();
      if (mounted) {
        setState(() {});
      }
    }
  }
}
