import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// API 注册表条目。Flutter 无运行时反射，API 名称 → 调用必须人工注册。
class ApiEntry {
  final String name; // 'ChatManager.downloadBigImage'
  final String group; // 'ChatManager'
  final String description;
  final String paramsTemplate; // 必填字段 JSON 模板
  final Future<Object?> Function(Map<String, dynamic> params) invoke;

  const ApiEntry({
    required this.name,
    required this.group,
    required this.description,
    required this.paramsTemplate,
    required this.invoke,
  });
}

/// 把 SDK 返回值转成可 jsonEncode 的结构（模型走 toJson）。
Object? toJsonSafe(Object? v) {
  if (v == null || v is num || v is bool || v is String) return v;
  if (v is Enum) return v.name;
  // ChatPresence 未实现 toJson，特判序列化。
  if (v is ChatPresence) {
    return {
      'publisher': v.publisher,
      'statusDescription': v.statusDescription,
      'lastTime': v.lastTime,
      'expiryTime': v.expiryTime,
      'statusDetails': v.statusDetails,
    };
  }
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), toJsonSafe(val)));
  }
  if (v is Iterable) return v.map(toJsonSafe).toList();
  try {
    final dynamic d = v;
    return toJsonSafe(d.toJson());
  } catch (_) {
    return v.toString();
  }
}

/// 统一错误格式：ChatError 取 code/description，其余取 toString。
Map<String, dynamic> errorToJson(Object e) {
  if (e is ChatError) {
    return {'code': e.code, 'message': e.description};
  }
  return {'code': -1, 'message': e.toString()};
}

/// 调用条目并包装为统一结果：
/// 成功 {"success": true, "data": ...}（void 返回无 data），
/// 失败 {"success": false, "error": {"code": ..., "message": ...}}。
Future<Map<String, dynamic>> runApi(
  ApiEntry entry,
  Map<String, dynamic> params,
) async {
  try {
    final r = await entry.invoke(params);
    final result = <String, dynamic>{'success': true};
    final data = toJsonSafe(r);
    if (data != null) result['data'] = data;
    return result;
  } catch (e) {
    return {'success': false, 'error': errorToJson(e)};
  }
}
