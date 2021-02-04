import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class GroupInfoPage extends StatefulWidget {
  final EMGroup group;
  GroupInfoPage(this.group);
  @override
  State<StatefulWidget> createState() => GroupInfoPageState();
}

class GroupInfoPageState extends State<GroupInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar.normal(widget.group.name),
    );
  }
}
