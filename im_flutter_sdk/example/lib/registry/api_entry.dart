import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// API registry entry. Flutter has no runtime reflection; API name -> call must be manually registered.
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

/// Converts SDK return values to jsonEncode-compatible structures (models via toJson).
Object? toJsonSafe(Object? v) {
  if (v == null || v is num || v is bool || v is String) return v;
  if (v is Enum) return v.name;
  // ChatPresence does not implement toJson; serialized with special handling.
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

/// Unified error format: ChatError uses code/description, others use toString.
Map<String, dynamic> errorToJson(Object e) {
  if (e is ChatError) {
    return {'code': e.code, 'message': e.description};
  }
  return {'code': -1, 'message': e.toString()};
}

/// Calls the entry and wraps the result in a unified format:
/// Success: {"success": true, "data": ...} (void returns no data),
/// Failure: {"success": false, "error": {"code": ..., "message": ...}}.
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
