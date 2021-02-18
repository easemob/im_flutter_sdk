import 'package:easeim_flutter_demo/unit/event_bus_manager.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class JoinedGroupsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JoinedGroupsPageState();
}

class JoinedGroupsPageState extends State<JoinedGroupsPage> {
  List<EMGroup> _groupsList = List();

  bool _isEnd = false;
  String _searchName = '';
  List<EMGroup> _searchdGroups = List();
  final _pageSize = 30;
  int _pageNumber = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  bool get _isSearch => _searchName.length > 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar('群聊'),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: sHeight(50),
              padding: EdgeInsets.only(
                left: sWidth(20),
                right: sWidth(20),
              ),
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
                      _searchGroupId(text);
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
                      hintText: '请输入群组id',
                      hintStyle: TextStyle(
                        fontSize: sFontSize(14),
                        color: Colors.grey,
                      ),
                    ),
                    onFieldSubmitted: (str) {
                      _searchGroupId(str);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: !_isEnd,
                onRefresh: () => _loadJoinedGroups(),
                onLoading: () => _loadJoinedGroups(true),
                controller: _refreshController,
                child: ListView.separated(
                  itemBuilder: ((_, index) {
                    if (_isSearch) {
                      EMGroup group = _searchdGroups[index];
                      return _groupItem(group);
                    } else {
                      EMGroup group = _groupsList[index];
                      return _groupItem(group);
                    }
                  }),
                  separatorBuilder: ((_, index) {
                    return Divider(
                      color: Colors.grey[300],
                      height: 0.3,
                    );
                  }),
                  itemCount:
                      _isSearch ? _searchdGroups.length : _groupsList.length,
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

  _groupItem(EMGroup group) {
    return Container(
      // color: Colors.red,
      height: sHeight(70),
      child: ListTile(
        onTap: () => _chat(group),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        enabled: true,
        title: Builder(
          builder: (_) {
            return _isSearch
                ? Text.rich(
                    TextSpan(
                      children: _groupItemText(
                        group.name,
                        fontSize: sFontSize(15),
                        defaultColor: Colors.black87,
                      ),
                    ),
                    maxLines: 1,
                  )
                : Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sFontSize(15),
                      color: Colors.black87,
                    ),
                  );
          },
        ),
        subtitle: Builder(builder: (_) {
          return _isSearch
              ? Text.rich(
                  TextSpan(
                    children: _groupItemText(
                      group.groupId,
                      fontSize: sFontSize(13),
                      defaultColor: Colors.grey,
                    ),
                  ),
                  maxLines: 1,
                )
              : Text(
                  group.groupId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: sFontSize(13),
                    color: Colors.grey,
                  ),
                );
        }),
      ),
    );
  }

  _groupItemText(
    String str, {
    Color searchColor = Colors.orange,
    Color defaultColor = Colors.grey,
    double fontSize = 10,
  }) {
    List<InlineSpan> stack = [];
    List<int> indexList = [];
    RegExp exp = new RegExp(_searchName);
    var expsList = exp.allMatches(str).toList();
    for (RegExpMatch r in expsList) {
      indexList.add(r.start);
      indexList.add(r.end);
    }
    int afterX = 0;
    for (int x = 0; x < indexList.length; x = x + 2) {
      int y = x + 1;
      var indexX = indexList[x];
      var indexY = indexList[y];

      var substring = str.substring(afterX, indexX);
      stack.add(TextSpan(
        text: substring,
        style: TextStyle(
          color: defaultColor,
          fontSize: sFontSize(fontSize),
        ),
      ));

      substring = str.substring(indexX, indexY);
      stack.add(TextSpan(
        text: substring,
        style: TextStyle(
          color: searchColor,
          fontSize: sFontSize(fontSize),
        ),
      ));
      afterX = indexY;
    }
    var lastStr = str.substring(afterX);
    stack.add(TextSpan(
      text: lastStr,
      style: TextStyle(
        color: defaultColor,
        fontSize: sFontSize(fontSize),
      ),
    ));
    return stack;
  }

  _loadJoinedGroups([bool isMore = false]) async {
    print('_loadJoinedGroups');
    try {
      if (!isMore) {
        _pageNumber = 0;
      }

      SmartDialog.showLoading(msg: '获取中...');
      List<EMGroup> groups =
          await EMClient.getInstance.groupManager.getJoinedGroupsFromServer(
        pageSize: _pageSize,
        pageNum: _pageNumber,
      );

      // 如果返回数量小于期望数量，则表示无更多数据。
      if (_pageSize > groups.length) {
        _isEnd = true;
      } else {
        _pageNumber++;
        _isEnd = false;
      }
      if (!isMore) {
        _groupsList.clear();
      }
      _groupsList.addAll(groups);
      setState(() {});
      SmartDialog.showToast('获取成功');
      isMore
          ? _refreshController.loadComplete()
          : _refreshController.refreshCompleted();
    } on EMError catch (e) {
      SmartDialog.showToast('获取失败$e');
      isMore
          ? _refreshController.loadFailed()
          : _refreshController.refreshFailed();
    } finally {
      SmartDialog.dismiss();
    }
  }

  _chat(EMGroup group) async {
    EMConversation con = await EMClient.getInstance.chatManager
        .getConversation(group.groupId, EMConversationType.GroupChat);
    con.name = group.name;
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: [con.name, con],
    ).then((value) {
      eventBus.fire(EventBusManager.updateConversations());
    });
  }

  _searchGroupId(String std) async {
    _searchName = std;
    if (std.length == 0) {
      _searchdGroups.clear();
      setState(() {});
      return;
    }
    _searchdGroups.clear();

    for (EMGroup group in _groupsList) {
      if (group.name.contains(std)) {
        _searchdGroups.add(group);
        continue;
      } else if (group.groupId.contains(std)) {
        _searchdGroups.add(group);
        continue;
      }
    }
    setState(() {});
  }
}
