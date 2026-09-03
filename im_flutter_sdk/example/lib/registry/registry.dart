import 'api_entry.dart';
import 'apis/chat_apis.dart';
import 'apis/group_apis.dart';
import 'apis/presence_apis.dart';
import 'apis/user_info_apis.dart';

/// Phase-1 searchable API registry (init/login/logout are page-specific and not registered).
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
