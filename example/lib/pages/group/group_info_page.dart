import 'package:easeim_flutter_demo/pages/group/group_members_page.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class GroupInfoPage extends StatefulWidget {
  final EMGroup group;
  GroupInfoPage(this.group);
  @override
  State<StatefulWidget> createState() => GroupInfoPageState();
}

class GroupInfoPageState extends State<GroupInfoPage> {
  EMGroup? _group;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500))
        .then((value) => _fetchGroupInfo());
  }

  @override
  Widget build(BuildContext context) {
    bool needApproval = false;
    if (_group != null) {
      if (_group!.settings?.style == EMGroupStyle.PublicJoinNeedApproval) {
        needApproval = true;
      } else {
        needApproval = false;
      }
    }
    return Scaffold(
      appBar: DemoAppBar(
        '群组信息',
        rightWidgets: [
          TextButton(
            onPressed: () =>
                needApproval ? _approvalJoinPublicGroup() : _joinPublicGroup(),
            child: Builder(
              builder: (_) {
                String text = '';
                if (_group != null) {
                  text = needApproval ? '申请' : '加入';
                }
                return Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sFontSize(16),
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: Container(
        // margin: EdgeInsets.all(
        //   sWidth(10),
        // ),
        child: Column(
          children: [
            Card(
              // elevation: 5, //阴影
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              color: Colors.white, //颜色
              margin: EdgeInsets.all(sWidth(10)), //margin
              child: Container(
                margin: EdgeInsets.all(sWidth(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.group.name!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: sFontSize(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: sHeight(5),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.group.groupId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: sFontSize(13),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTapUp: (_) => _pushGroupMembersInfo(),
              child: Card(
                // elevation: 5, //阴影
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                color: Colors.white, //颜色
                margin: EdgeInsets.all(sWidth(10)), //margin
                child: Container(
                  margin: EdgeInsets.all(
                    sWidth(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('群主'),
                      ),
                      Text(_group?.owner ?? ''),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              // elevation: 5, //阴影
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              color: Colors.white, //颜色
              margin: EdgeInsets.all(sWidth(10)), //margin
              child: Container(
                margin: EdgeInsets.all(
                  sWidth(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('成员数'),
                    ),
                    Text(_group != null ? _group!.memberCount.toString() : ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _joinPublicGroup() async {
    try {
      SmartDialog.showLoading(msg: '加入中...');
      await EMClient.getInstance.groupManager.joinPublicGroup(_group!.groupId);
      SmartDialog.showToast('加入成功');
    } on EMError catch (e) {
      SmartDialog.showToast('加入失败: $e');
    } finally {
      SmartDialog.dismiss();
    }
  }

  _approvalJoinPublicGroup() async {
    try {
      SmartDialog.showLoading(msg: '申请中...');
      if (_group != null) {
        await EMClient.getInstance.groupManager.requestToJoinPublicGroup(
          _group!.groupId,
        );
      }
      SmartDialog.showToast('申请已发送');
    } on EMError catch (e) {
      SmartDialog.showToast('申请失败: $e');
    } finally {
      SmartDialog.dismiss();
    }
  }

  _fetchGroupInfo() async {
    try {
      SmartDialog.showLoading(msg: '获取中...');
      _group = await EMClient.getInstance.groupManager
          .getGroupSpecificationFromServer(
        widget.group.groupId,
      );

      SmartDialog.showToast('获取成功');
      if (mounted) {
        setState(() {});
      }
    } on EMError catch (e) {
      SmartDialog.showToast('获取失败: $e');
    } finally {
      SmartDialog.dismiss();
    }
  }

  _pushGroupMembersInfo() {
    Navigator.of(context).pushNamed('/groupMemberList', arguments: [
      _group,
      GroupMembersPageType.Admin,
    ]);
  }
}
