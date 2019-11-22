import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class DemoLocalizations {
  final Locale locale;
  DemoLocalizations(this.locale);

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'conversation': 'Conversation',
      'address_book': 'Address Book',
      'find': 'Find',
      'mine': 'Mine',
      'login': 'Login',
      'delete_conversation' : 'DeleteConversation',
      'delete_contact' : 'DeleteContact',
      'clear_unread' : 'ClearUnread',
      'chat_rooms' : 'ChatRooms',
      'search' : 'Search',
      'unable_connect_to_server' : 'Unable connect to server',
      'chat_groups' : 'ChatGroups',
      'public_groups' : 'PublicGroups',
      'loading' : 'loading...',
      'inLogin' : 'In the login...',
      'inRegister' : 'In the register...',
      'inLogout' : 'In the logout...',
    },
    'zh': {
      'conversation': '会话',
      'address_book': '通讯录',
      'find': '发现',
      'mine': '我的',
      'login': '登录',
      'delete_conversation' : '删除会话',
      'delete_contact' : '删除联系人',
      'clear_unread' : '清除未读',
      'chat_rooms' : '聊天室',
      'search' : '搜索',
      'unable_connect_to_server' : '无法连接到服务器',
      'chat_groups' : '群组',
      'public_groups' : '公开群组',
      'loading' : '正在加载...',
      'inLogin' : '正在登录...',
      'inRegister' : '正在注册...',
      'inLogout' : '正在退出...',
    }
  };

  get conversation {
    return _localizedValues[locale.languageCode]['conversation'];
  }
  get addressBook {
    return _localizedValues[locale.languageCode]['address_book'];
  }
  get find {
    return _localizedValues[locale.languageCode]['find'];
  }
  get mine {
    return _localizedValues[locale.languageCode]['mine'];
  }
  get login {
    return _localizedValues[locale.languageCode]['login'];
  }
  get deleteConversation {
    return _localizedValues[locale.languageCode]['delete_conversation'];
  }

  get deleteContact {
    return _localizedValues[locale.languageCode]['delete_contact'];
  }

  get clearUnread {
    return _localizedValues[locale.languageCode]['clear_unread'];
  }
  get chatRoom {
    return _localizedValues[locale.languageCode]['chat_rooms'];
  }
  get search {
    return _localizedValues[locale.languageCode]['search'];
  }
  get unableConnectToServer {
    return _localizedValues[locale.languageCode]['unable_connect_to_server'];
  }
  get chatGroup {
    return _localizedValues[locale.languageCode]['chat_groups'];
  }
  get publicGroups {
    return _localizedValues[locale.languageCode]['public_groups'];
  }
  get loading {
    return _localizedValues[locale.languageCode]['loading'];
  }
  get inLogin {
    return _localizedValues[locale.languageCode]['inLogin'];
  }
  get inRegister {
    return _localizedValues[locale.languageCode]['inRegister'];
  }
  get inLogout {
    return _localizedValues[locale.languageCode]['inLogout'];
  }

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of(context, DemoLocalizations);
  }
}

class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations>{
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en','zh'].contains(locale.languageCode);
  }

  @override
  Future<DemoLocalizations> load(Locale locale) {
    return new SynchronousFuture<DemoLocalizations>(new DemoLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<DemoLocalizations> old) {
    return false;
  }

  static DemoLocalizationsDelegate delegate = const DemoLocalizationsDelegate();
}