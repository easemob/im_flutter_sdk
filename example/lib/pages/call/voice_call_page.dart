import 'package:flutter/material.dart';

class VoiceCallPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Title(color: Colors.blue, child: Text('呼叫页面')),
      ),
    );
  }
}
