import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements EMConnectionListener,EMMessageListener{
  @override
  void initState() {
    //TODO: init sdk;
    EMOptions options = new EMOptions(appKey: "easemob-demo#chatdemoui");
    EMClient.getInstance().init(options);

    EMClient.getInstance().login(
        userName: "omg2",
        password: "1",
        onSuccess: () {
          print("login succes");
          EMALog.debugLog("main","login succes");
        },
        onError: (code, desc) {
          print("login error");
          EMALog.errorLog("main","login onError" + " code: " + code.toString() + "desc: " + desc);
        });

    EMClient.getInstance().addConnectionListener(this);
    EMClient.getInstance().chatManager().addMessageListener(this);
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
  @override
  void onMessageRecalled(List<EMMessage> messages) {
    // TODO: implement onMessageRecalled
  }
  @override
  void onMessageRead(List<EMMessage> messages) {
    // TODO: implement onMessageRead
  }
  @override
  void onMessageDelivered(List<EMMessage> messages) {
    // TODO: implement onMessageDelivered
  }
  @override
  void onMessageChanged(EMMessage message, Object change) {
    // TODO: implement onMessageChanged
  }
  @override
  void onCmdMessageReceived(List<EMMessage> messages) {
    // TODO: implement onCmdMessageReceived
    EMALog.errorLog('onCmdMessageReceived--->', messages.toString());
  }
  @override
  void onMessageReceived(List<EMMessage> messages) {
    // TODO: implement onMessageReceived
    EMALog.debugLog('onMessageReceived--->', messages.toString());
  }
}
