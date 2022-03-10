import 'dart:convert';
import 'dart:io';
import 'package:ease_call_kit/ease_call_kit.dart';
import 'package:easeim_flutter_demo/pages/contacts/contacts_page.dart';
import 'package:easeim_flutter_demo/pages/conversations/conversations_page.dart';
import 'package:easeim_flutter_demo/pages/me/me_page.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:convert' as convert;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin
    implements EaseCallKitListener {
  num _selectedPageIndex = 0;
  ConversationPage _convPage;
  List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _setupCallKit();
    _convPage = ConversationPage();
    _pages = [
      _convPage,
      ContactsPage(),
      MePage(),
    ];
  }

  void _setupCallKit() async {
    // 初始化 EaseCallKit插件
    await EaseCallKit.initWithConfig(
      EaseCallConfig('15cb0d28b87b425ea613fc46f7c9f974'),
    );
    EaseCallKit.listener = this;
    _requestPermission();
  }

  @override
  Widget build(context) {
    super.build(context);

    return Scaffold(
      body: updatePages(),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Color.fromARGB(255, 4, 174, 240),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: _selectedPageIndex,
        items: [
          bottomItem(
            '会话',
            'images/home_tab_chat.png',
            'images/home_tab_selected_chat.png',
            true,
          ),
          bottomItem(
            '通讯录',
            'images/home_tab_contact.png',
            'images/home_tab_selected_contact.png',
          ),
          bottomItem(
            '我',
            'images/home_tab_me.png',
            'images/home_tab_selected_me.png',
          ),
        ],
        onTap: (value) {
          setState(() {
            _selectedPageIndex = value;
          });
        },
      ),
    );
  }

  BottomNavigationBarItem bottomItem(String title, String unSelectedImageName,
      [String selectedImageName, bool needUnreadCount = false]) {
    return BottomNavigationBarItem(
      activeIcon: SizedBox(
        child: Stack(
          children: [
            Positioned(
              left: sWidth(5),
              right: sWidth(5),
              top: sHeight(5),
              bottom: sHeight(5),
              child: Image.asset(
                selectedImageName ?? unSelectedImageName,
                fit: BoxFit.cover,
              ),
            ),
            needUnreadCount
                ? Positioned(
                    right: sWidth(0),
                    top: sHeight(2),
                    child: ChangeNotifierProvider<ConversationPage>(
                      create: (_) => _convPage,
                      child: Selector(
                        builder: (context, num data, Widget child) {
                          return unreadCoundWidget(data);
                        },
                        selector: (_, ConversationPage state) {
                          return state.totalUnreadCount;
                        },
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
        height: sWidth(45),
        width: sWidth(45),
      ),
      backgroundColor: Colors.black,
      icon: SizedBox(
        child: Stack(
          children: [
            Positioned(
              left: sWidth(5),
              right: sWidth(5),
              top: sHeight(5),
              bottom: sHeight(5),
              child: Image.asset(
                unSelectedImageName,
                fit: BoxFit.cover,
              ),
            ),
            needUnreadCount
                ? Positioned(
                    right: sWidth(0),
                    top: sHeight(2),
                    child: ChangeNotifierProvider<ConversationPage>(
                      create: (_) => _convPage,
                      child: Selector(
                        builder: (context, num data, Widget child) {
                          return unreadCoundWidget(data);
                        },
                        selector: (_, ConversationPage state) {
                          return state.totalUnreadCount;
                        },
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
        height: sWidth(45),
        width: sWidth(45),
      ),
      label: title,
    );
  }

  updatePages() {
    return IndexedStack(
      children: _pages,
      index: _selectedPageIndex,
    );
  }

  /// 获取麦克风权限
  _requestPermission() async {
    Future.delayed(Duration(seconds: 3)).then((value) {
      Permission.microphone.request();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void callDidEnd(String channelName, EaseCallEndReason reason, int time,
      EaseCallType callType) {}

  @override
  void callDidJoinChannel(String channelName, int uid) {}

  @override
  void callDidOccurError(EaseCallError error) {}

  @override
  void callDidReceive(EaseCallType callType, String inviter, Map ext) {}

  @override
  void callDidRequestRTCToken(
      String appId, String channelName, String eid) async {
    String emUsername = EMClient.getInstance.currentUsername;
    await fetchRTCToken(channelName, emUsername);
  }

  @override
  void multiCallDidInviting(List<String> excludeUsers, Map ext) {}

  Future<void> fetchRTCToken(String channelName, String username) async {
    String token = await EMClient.getInstance.getAccessToken();
    if (token == null) return null;
    var httpClient = new HttpClient();
    var uri = Uri.http("a1.easemob.com", "/token/rtcToken/v1", {
      "userAccount": username,
      "channelName": channelName,
      "appkey": EMClient.getInstance.options.appKey,
    });
    var request = await httpClient.getUrl(uri);
    request.headers.add("Authorization", "Bearer $token");
    HttpClientResponse response = await request.close();
    httpClient.close();
    if (response.statusCode == HttpStatus.ok) {
      var _content = await response.transform(Utf8Decoder()).join();
      debugPrint(_content);
      Map<String, dynamic> map = convert.jsonDecode(_content);
      if (map != null) {
        if (map["code"] == "RES_0K") {
          debugPrint("获取数据成功: $map");
          String rtcToken = map["accessToken"];
          int agoraUserId = map["agoraUserId"];
          await EaseCallKit.setRTCToken(rtcToken, channelName, agoraUserId);
        }
      }
    }
  }

  @override
  void remoteUserDidJoinChannel(String channelName, int uid, String eid) async {
    if (eid == null) return;
    try {
      Map<String, EMUserInfo> map = await EMClient.getInstance.userInfoManager
          .fetchUserInfoByIdWithExpireTime([eid]);
      for (MapEntry<String, EMUserInfo> entire in map.entries) {
        Map<String, EaseCallUser> infoMapper = {};
        infoMapper[entire.key] =
            EaseCallUser(entire.value.nickName ?? entire.key);
        await EaseCallKit.setUserInfoMapper(infoMapper);
      }
    } on EMError catch (e) {
      debugPrint(e.toString());
    }
  }
}
