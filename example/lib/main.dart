import 'package:easeim_flutter_demo/pages/account/register_page.dart';
import 'package:easeim_flutter_demo/pages/chat/chat_page.dart';
import 'package:easeim_flutter_demo/pages/chatroom/chat_room_list_page.dart';
import 'package:easeim_flutter_demo/pages/contacts/contact_add_friends_page.dart';
import 'package:easeim_flutter_demo/pages/contacts/contact_friends_request_page.dart';
import 'package:easeim_flutter_demo/pages/contacts/contact_select_page.dart';
import 'package:easeim_flutter_demo/pages/group/group_info_page.dart';
import 'package:easeim_flutter_demo/pages/group/group_members_page.dart';
import 'package:easeim_flutter_demo/pages/group/joined_groups_page.dart';
import 'package:easeim_flutter_demo/pages/group/public_groups_page.dart';
import 'package:easeim_flutter_demo/pages/index_page.dart';
import 'package:easeim_flutter_demo/pages/home_page.dart';
import 'package:easeim_flutter_demo/pages/account/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemUiOverlayStyle uiStyle = SystemUiOverlayStyle.light;
  SystemChrome.setSystemUIOverlayStyle(uiStyle);
  initSDK();
  return runApp(EaseIMDemo());
}

void initSDK() async {
  var options = EMOptions(
    appKey: 'easemob-demo#easeim',
    deleteMessagesAsExitGroup: false,
    deleteMessagesAsExitChatRoom: false,
    autoAcceptGroupInvitation: true,
    debugModel: true,
  );

  options.enableAPNs("EaseIM_APNS_Product");
  await EMClient.getInstance.init(options);
  debugPrint("has init");
}

class EaseIMDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ScreenUtilInit(
        designSize: Size(375, 667),
        builder: (context) {
          return MaterialApp(
            builder: (context, child) => FlutterSmartDialog(child: child),
            debugShowCheckedModeBanner: false,
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
          );
        },
      ),
    );
  }
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  var routes = <String, WidgetBuilder>{
    '/login': (context) => LoginPage(),
    '/register': (context) => RegisterPage(),
    '/home': (context) => HomePage(),
    '/friendsRequest': (context) => ContactFriendsRequestPage(),
    '/addFriends': (context) => ContactAddFriendsPage(),
    '/publicGroups': (context) => PublicGroupsPage(),
    '/joinedGroups': (context) => JoinedGroupsPage(),
    '/chat': (context) => ChatPage(
          (settings.arguments as List)[0],
          (settings.arguments as List)[1],
        ),
    '/groupInfo': (context) => GroupInfoPage(settings.arguments as Map),
    '/groupMemberList': (context) => GroupMembersPage(
          (settings.arguments as List)[0],
          (settings.arguments as List)[1],
        ),
    '/rooms': (context) => ChatRoomsListPages(),
    '/contactSelect': (context) => ContactSelectPage(),
  };

  WidgetBuilder? builder = routes[settings.name] as WidgetBuilder;
  return MaterialPageRoute(builder: (ctx) => builder(ctx));
}
