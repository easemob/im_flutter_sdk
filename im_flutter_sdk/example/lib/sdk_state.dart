import 'package:flutter/foundation.dart';

/// 全局 SDK 状态：已初始化 / 已登录 / 当前账号 + 初始化 JSON 快照。
class SdkState extends ChangeNotifier {
  SdkState._();
  static final SdkState instance = SdkState._();

  bool initialized = false;
  String? currentUser;
  String? initJsonSnapshot;

  bool get loggedIn => currentUser != null;

  String get statusText {
    if (!initialized) return '未初始化';
    if (!loggedIn) return '已初始化，未登录';
    return '已登录：$currentUser';
  }

  void markInitialized(String initJson) {
    initialized = true;
    initJsonSnapshot = initJson;
    notifyListeners();
  }

  void markLoggedIn(String userId) {
    currentUser = userId;
    notifyListeners();
  }

  void markLoggedOut() {
    currentUser = null;
    notifyListeners();
  }
}
