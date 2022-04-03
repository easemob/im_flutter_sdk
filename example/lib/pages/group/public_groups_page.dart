import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PublicGroupsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PublicGroupsPageState();
}

class PublicGroupsPageState extends State<PublicGroupsPage> {
  List<EMGroup> _groupsList = [];
  String? _cursor;
  bool _isEnd = false;
  String _searchName = '';
  EMGroup? _searchedGroup;
  final _pageSize = 30;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar('公开群列表'),
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
                        _searchedGroup = null;
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
                      hintText: '请输入公开群组ID',
                      hintStyle: TextStyle(
                        fontSize: sFontSize(14),
                        color: Colors.grey,
                      ),
                    ),
                    onFieldSubmitted: (str) {
                      _searchPublicId(str);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: !_isEnd,
                onRefresh: _loadPublicGroups,
                onLoading: _loadMorePublicGroups,
                controller: _refreshController,
                child: ListView.separated(
                  itemBuilder: ((_, index) {
                    if (_searchedGroup != null) {
                      return _groupItem(_searchedGroup!);
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
                  itemCount: _searchName.length != 0 && _searchedGroup != null
                      ? 1
                      : _groupsList.length,
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
      height: sHeight(70),
      // height: sHeight(44),
      child: ListTile(
        onTap: () => _fetchGroupInfo(group),
        title: Text(
          group.name!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: sFontSize(16),
          ),
        ),
        subtitle: Text(
          group.groupId,
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

  _loadMorePublicGroups() async {
    try {
      EMCursorResult<EMGroup> cursor =
          await EMClient.getInstance.groupManager.getPublicGroupsFromServer(
        pageSize: _pageSize,
        cursor: _cursor ?? "",
      );
      _refreshController.loadComplete();
      _cursor = cursor.cursor;
      _groupsList.addAll(cursor.data);
      // 返回数据小于pageSize,说明是最后一页
      if (_pageSize > cursor.data.length) {
        _isEnd = true;
        if (mounted) {
          setState(() {});
        }
      }
    } on EMError catch (e) {
      SmartDialog.showToast('获取失败$e');
      _refreshController.loadFailed();
    } finally {}
  }

  _loadPublicGroups() async {
    try {
      _isEnd = false;

      EMCursorResult<EMGroup> cursor =
          await EMClient.getInstance.groupManager.getPublicGroupsFromServer(
        pageSize: _pageSize,
      );
      _refreshController.refreshCompleted();
      if (_pageSize > cursor.data.length) {
        _isEnd = true;
      }
      _cursor = cursor.cursor;
      _groupsList.clear();
      _groupsList.addAll(cursor.data);
      SmartDialog.showToast('获取成功');
      if (mounted) {
        setState(() {});
      }
    } on EMError catch (e) {
      SmartDialog.showToast('获取失败$e');
      _refreshController.refreshFailed();
    } finally {}
  }

  _fetchGroupInfo(EMGroup group) {
    print('_fetchGroupInfo ${group.groupId}');
    Navigator.of(context)
        .pushNamed('/groupInfo', arguments: group)
        .then((value) {});
  }

  _searchPublicId(String std) async {
    if (std.length == 0) return;
    try {
      SmartDialog.showLoading(msg: '搜索中...');
      _searchedGroup = await EMClient.getInstance.groupManager
          .getGroupSpecificationFromServer(std);
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
