import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

enum GroupMembersPageType {
  Member,
  Admin,
  Block,
}

class GroupMembersPage extends StatefulWidget {
  final EMGroup group;
  final GroupMembersPageType type;

  GroupMembersPage(
    this.group, [
    this.type = GroupMembersPageType.Member,
  ]);

  @override
  State<StatefulWidget> createState() => GroupMembersPageState();
}

class GroupMembersPageState extends State<GroupMembersPage> {
  @override
  Widget build(BuildContext context) {
    String title = '';
    switch (widget.type) {
      case GroupMembersPageType.Member:
        {
          title = '成员列表';
        }
        break;
      case GroupMembersPageType.Admin:
        {
          title = '管理员列表';
        }
        break;
      case GroupMembersPageType.Block:
        {
          title = '黑名单列表';
        }
        break;
      default:
    }
    return Scaffold(
      appBar: DemoAppBar.normal(title),
    );
  }
}
