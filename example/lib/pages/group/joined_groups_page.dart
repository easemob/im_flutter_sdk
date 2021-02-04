import 'package:easeim_flutter_demo/widgets/demo_app_bar.dart';
import 'package:flutter/material.dart';

class JoinedGroupsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JoinedGroupsPageState();
}

class JoinedGroupsPageState extends State<JoinedGroupsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DemoAppBar.normal('群组'),
    );
  }
}
