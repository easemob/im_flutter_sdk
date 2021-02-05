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
  EMGroup _group;

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
      if (_group.settings?.style == EMGroupStyle.PublicJoinNeedApproval) {
        needApproval = true;
      } else {
        needApproval = false;
      }
    }
    return Scaffold(
      appBar: DemoAppBar.normal(
        '群组信息',
        actions: [
          FlatButton(
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
      body: ListView(
        children: [
          Row(
            children: [
              Text('id: ${widget.group.groupId}'),
            ],
          )
        ],
      ),
    );
  }

  _joinPublicGroup() {
    try {
      SmartDialog.showLoading(msg: '加入中...');
      EMClient.getInstance.groupManager.joinPublicGroup(_group.groupId);
      SmartDialog.showToast('加入成功');
    } on EMError catch (e) {
      SmartDialog.showToast('加入失败: $e');
    } finally {
      SmartDialog.dismiss();
    }
  }

  _approvalJoinPublicGroup() {
    try {
      SmartDialog.showLoading(msg: '申请中...');
      EMClient.getInstance.groupManager
          .requestToJoinPublicGroup(_group.groupId);
      SmartDialog.showToast('申请已发送');
    } on EMError catch (e) {
      SmartDialog.showToast('申请失败: $e');
    } finally {
      SmartDialog.dismiss();
    }
    EMClient.getInstance.groupManager.requestToJoinPublicGroup(_group.groupId);
  }

  _fetchGroupInfo() async {
    try {
      SmartDialog.showLoading(msg: '获取中...');
      _group = await EMClient.getInstance.groupManager
          .getGroupSpecificationFromServer(widget.group.groupId);
      setState(() {});
      SmartDialog.showToast('获取成功');
    } on EMError catch (e) {
      SmartDialog.showToast('获取失败: $e');
    } finally {
      SmartDialog.dismiss();
    }
  }
}
