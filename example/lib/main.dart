import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'utils/localizations.dart';
import 'pages/home_page.dart';
import 'login_page.dart';
import 'register_page.dart';

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
    EMClient.getInstance().addConnectionListener(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// 配置跳转路由
      routes: <String, WidgetBuilder>{
        'home': (BuildContext context) => new HomePage(),
        "register":(BuildContext context)=>new RegisterPage(),
        "login":(BuildContext context)=>new LoginPage(),
      },



      /// 配置国际化语言
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        DemoLocalizationsDelegate.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 美国英语
        const Locale('zh', 'CN'), // 中文简体
        // ... other locales the app supports
      ],


      title: '环信即时通讯云',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }

  /// EMConnectionListener
  @override
  void onConnected() {
    // TODO: implement onConnected
    print("网络连接成功");
  }

  @override
  void onDisconnected(int errorCode) {
    // TODO: implement onDisconnected
    print("网络连接断开");
  }

}
