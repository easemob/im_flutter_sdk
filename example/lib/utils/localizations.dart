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
      'group_details' : 'Group Details',
      'group_files' : 'Group Files',
      'group_memebers' : 'Group Members',
      'in_operation' : 'In Operation',
      'remove_member' : 'Remove Member',
      'group_announcement' : 'Group Announcement',
      'group_management' : 'Group Management',
      'mute_management' : 'Mute Management',
      'blackList_management' : 'Black List Management',
      'admin_management' : 'Admin Management',
      'add_blackList' : 'Add Black List',
      'add_muteList' : 'Add Mute List',
      'add_adminList' : 'Add Admin List',
      'create_group' : 'Create Group',
      'group_head' : 'Group Head',
      'group_name' : 'Group Name',
      'change_group_name' : 'Change Group Name',
      'yes' : 'Yes',
      'no' : 'No',
      'exit_group' : 'Exit Group',
      'destroy_group' : 'Destroy Group',
      'pick_contact' : 'Pick Contact',
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
      'group_details' : '群组详情',
      'group_files' : '群文件',
      'group_memebers' : '群成员',
      'in_operation' : '正在操作...',
      'remove_member' : '移除成员',
      'group_announcement' : '群公告',
      'group_management' : '群组管理',
      'mute_management' : '禁言管理',
      'blackList_management' : '黑名单管理',
      'admin_management' : '管理员管理',
      'add_blackList' : '加入黑名单',
      'add_muteList' : '禁言',
      'add_adminList' : '添加管理员',
      'create_group' : '创建群组',
      'group_head' : '群头像',
      'group_name' : '群名称',
      'change_group_name' : '修改群名称',
      'yes' : '确定',
      'no' : '取消',
      'exit_group' : '退出群组',
      'destroy_group' : '解散群组',
      'pick_contact' : '选择好友',
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
  get groupDetails {
    return _localizedValues[locale.languageCode]['group_details'];
  }
  get groupFiles {
    return _localizedValues[locale.languageCode]['group_files'];
  }
  get groupMembers {
    return _localizedValues[locale.languageCode]['group_memebers'];
  }
  get inOperation {
    return _localizedValues[locale.languageCode]['in_operation'];
  }
  get removeMember {
    return _localizedValues[locale.languageCode]['remove_member'];
  }
  get groupAnnouncement {
    return _localizedValues[locale.languageCode]['group_announcement'];
  }
  get groupManagement {
    return _localizedValues[locale.languageCode]['group_management'];
  }
  get muteManagement {
    return _localizedValues[locale.languageCode]['mute_management'];
  }
  get blackListManagement {
    return _localizedValues[locale.languageCode]['blackList_management'];
  }
  get adminManagement {
    return _localizedValues[locale.languageCode]['admin_management'];
  }
  get addBlackList {
    return _localizedValues[locale.languageCode]['add_blackList'];
  }
  get addMuteList {
    return _localizedValues[locale.languageCode]['add_muteList'];
  }
  get addAdminList {
    return _localizedValues[locale.languageCode]['add_adminList'];
  }
  get createGroup {
    return _localizedValues[locale.languageCode]['create_group'];
  }
  get groupHead {
    return _localizedValues[locale.languageCode]['group_head'];
  }
  get groupName {
    return _localizedValues[locale.languageCode]['group_name'];
  }
  get changeGroupName {
    return _localizedValues[locale.languageCode]['change_group_name'];
  }
  get yes {
    return _localizedValues[locale.languageCode]['yes'];
  }
  get no {
    return _localizedValues[locale.languageCode]['no'];
  }
  get exitGroup {
    return _localizedValues[locale.languageCode]['exit_group'];
  }
  get destroyGroup {
    return _localizedValues[locale.languageCode]['destroy_group'];
  }
  get pickContact {
    return _localizedValues[locale.languageCode]['pick_contact'];
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