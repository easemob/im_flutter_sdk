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
  List<EMGroup> _groupsList = List();
  String _cursor = '';
  bool _isEnd = false;
  String _searchName = '';
  final _pageSize = 30;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar.normal('公开群列表'),
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
                    onChanged: (text) {},
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
                      setState(() {
                        _searchName = str;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: !_isEnd,
                onRefresh: () => _loadPublicGroups(),
                onLoading: () => _loadMorePublicGroups(),
                controller: _refreshController,
                child: ListView.separated(
                    itemBuilder: ((_, index) {
                      return _groupItem(index);
                    }),
                    separatorBuilder: ((_, index) {
                      return Divider(
                        color: Colors.grey[300],
                      );
                    }),
                    itemCount: _groupsList.length),
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

  _groupItem(int index) {
    EMGroup group = _groupsList[index];
    return Container(
      padding: EdgeInsets.only(
        left: sWidth(20),
        right: sWidth(20),
      ),
      height: 40,
      child: GestureDetector(
        onTapUp: (_) => _fetchGroupInfo(group),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                group.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: sWidth(20),
            ),
            FlatButton(
              color: Colors.blue,
              highlightColor: Colors.blue[700],
              colorBrightness: Brightness.dark,
              splashColor: Colors.grey,
              child: Text("加入"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              onPressed: () => _joinPublicGroup(group),
            ),
          ],
        ),
      ),
    );
  }

  _loadMorePublicGroups() async {
    try {
      EMCursorResult<EMGroup> cursor = await EMClient.getInstance.groupManager
          .getPublicGroupsFromServer(pageSize: _pageSize, cursor: _cursor);
      _refreshController.loadComplete();
      _cursor = cursor.cursor;
      _groupsList.addAll(cursor.data);
      // 返回数据小于pageSize,说明是最后一页
      if (_pageSize > cursor.data.length) {
        _isEnd = true;
        setState(() {});
      }
    } on EMError catch (e) {
      SmartDialog.showToast('获取失败$e');
      _refreshController.loadFailed();
    } finally {}
  }

  _loadPublicGroups() async {
    try {
      _isEnd = false;
      SmartDialog.showLoading(msg: '获取中...');
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
      setState(() {});
      SmartDialog.showToast('获取成功');
    } on EMError catch (e) {
      SmartDialog.showToast('获取失败$e');
      _refreshController.refreshFailed();
    } finally {
      SmartDialog.dismiss();
    }
  }

  _joinPublicGroup(EMGroup group) {
    try {
      SmartDialog.showLoading(msg: '加入中...');
      EMClient.getInstance.groupManager.joinPublicGroup(group.groupId);
      SmartDialog.showToast('加入成功');
    } on EMError catch (e) {
      SmartDialog.showToast('加入失败: $e');
    } finally {
      SmartDialog.dismiss();
    }
  }

  _fetchGroupInfo(EMGroup group) {
    print('_fetchGroupInfo ${group.groupId}');
    Navigator.of(context)
        .pushNamed('/groupInfo', arguments: group)
        .then((value) {});
  }
}
