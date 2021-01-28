import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class MePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MePageState();
}

class MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我"),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: [
            Container(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'flutter sdk version',
                  ),
                  Text(
                    EMClient.getInstance.flutterSDKVersion(),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: FlatButton(
                    color: Colors.red,
                    onPressed: _loggout,
                    child: Text(
                      '退出',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _loggout() async {
    try {
      await EMClient.getInstance.logout(
        unbindDeviceToken: true,
      );
      Navigator.of(context).pushReplacementNamed(
        '/login',
      );
    } on EMError {}
  }
}
