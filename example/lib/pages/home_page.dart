import 'package:easeim_flutter_demo/pages/contacts/contacts_page.dart';
import 'package:easeim_flutter_demo/pages/conversations/conversations_page.dart';
import 'package:easeim_flutter_demo/pages/me/me_page.dart';
import 'package:easeim_flutter_demo/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  num _selectedPageIndex = 0;
  ConversationPage _convPage;
  List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _requestPermiss();
    _convPage = ConversationPage();
    _pages = [
      _convPage,
      ContactsPage(),
      MePage(),
    ];
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
  _requestPermiss() async {
    Future.delayed(Duration(seconds: 3)).then((value) {
      Permission.microphone.request();
    });
  }

  @override
  bool get wantKeepAlive => true;
}
