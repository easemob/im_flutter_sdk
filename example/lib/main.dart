import 'package:easeim_flutter_demo/pages/account/register_page.dart';
import 'package:easeim_flutter_demo/pages/call/video_call_page.dart';
import 'package:easeim_flutter_demo/pages/call/voice_call_page.dart';
import 'package:easeim_flutter_demo/pages/chat/chat_page.dart';
import 'package:easeim_flutter_demo/pages/index_page.dart';
import 'package:easeim_flutter_demo/pages/home_page.dart';
import 'package:easeim_flutter_demo/pages/account/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemUiOverlayStyle uiStyle = SystemUiOverlayStyle.light;
  SystemChrome.setSystemUIOverlayStyle(uiStyle);
  EMPushConfig config = EMPushConfig()..enableAPNs('chatdemoui');
  var options = EMOptions(appKey: 'easemob-demo#chatdemoui');
  options.pushConfig = config;
  EMClient.getInstance.init(options);
  return runApp(EaseIMDemo());
}

class EaseIMDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ScreenUtilInit(
      designSize: Size(375, 667),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: <String, WidgetBuilder>{
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => HomePage(),
          '/voicecall': (context) => VoiceCallPage(),
          '/videocall': (context) => VideoCallPage(),
        },
        onGenerateRoute: onGenerateRoute,
        theme: ThemeData(
            appBarTheme: AppBarTheme(elevation: 1),
            buttonTheme: ButtonThemeData(
                minWidth: 44.0,
                highlightColor: Color.fromRGBO(0, 0, 0, 0),
                splashColor: Color.fromRGBO(0, 0, 0, 0)),
            highlightColor: Color.fromRGBO(0, 0, 0, 0),
            splashColor: Color.fromRGBO(0, 0, 0, 0)),
        home: IndexPage(),
      ),
    );
  }
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  String routeName = settings.name;
  if (routeName == '/chat') {
    return MaterialPageRoute(builder: (context) {
      return ChatPage(settings.arguments);
    });
  } else {
    return null;
  }
}
