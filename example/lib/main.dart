import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements EMConnectionListener{
  @override
  void initState() {
    //TODO: init sdk;
    EMOptions options = new EMOptions(appKey: "easemob-demo#chatdemoui");
    EMClient.getInstance().init(options);
    EMClient.getInstance().login(
        userName: "du001",
        password: "1",
        onSuccess: (String username) {
          print("login succes: " + username);
        },
        onError: (code, desc) {
          print("code :" + code.toString() + " " + "desc :" + desc);
        });

    EMClient.getInstance().addConnectionListener(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '环信即时通讯云',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('环信 Flutter'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('Running on:'),
        ),
      ),
    );
  }

  /// EMConnectionListener
  @override
  void onConnected() {
    // TODO: implement onConnected
    print("网络连接成功");
  }

  @override
  void onDisconnected() {
    // TODO: implement onDisconnected
    print("网络连接断开");
  }

}
