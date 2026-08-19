import 'api_entry.dart';
import 'apis/chat_apis.dart';
import 'apis/group_apis.dart';
import 'apis/presence_apis.dart';
import 'apis/user_info_apis.dart';

/// 第一期可搜索 API 全量注册表（init/login/logout 为页面专用，不进注册表）。
final List<ApiEntry> apiRegistry = [
  ...chatApis,
  ...groupApis,
  ...presenceApis,
  ...userInfoApis,
];

ApiEntry? findApi(String name) {
  for (final e in apiRegistry) {
    if (e.name == name) return e;
  }
  return null;
}
