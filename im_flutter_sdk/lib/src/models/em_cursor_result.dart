typedef CursorResultCallback = Object Function(dynamic obj);

/// ~english
/// The EMCursorResult class, which specifies the cursor from which to query results.
/// When querying using this class, the SDK returns the queried instance and the cursor.
///
///   ```dart
///     String? cursor;
///     EMCursorResult<EMGroup> result = await EMClient.getInstance.groupManager.fetchPublicGroupsFromServer(pageSize: 10, cursor: cursor);
///     List<EMGroup>? group = result.data;
///     cursor = result.cursor;
///   ```
/// ~end
///
/// ~chinese
/// 带游标及分页获取结果的泛型类。
/// 做为分页获取且含有游标的返回对象。
///
/// 示例代码如下：
///   ```dart
///     String? cursor;
///     EMCursorResult<EMGroup> result = await EMClient.getInstance.groupManager.getPublicGroupsFromServer(pageSize: 10, cursor: cursor);
///     List<EMGroup>? group = result.data;
///     cursor = result.cursor;
///   ```
/// ~end
class EMCursorResult<T> {
  EMCursorResult(
    this.cursor,
    this.data,
  );

  factory EMCursorResult.fromJson(Map<String, dynamic> map,
      {dataItemCallback = CursorResultCallback}) {
    List<T> list = [];
    for (var element in (map['list'] as List)) {
      list.add(dataItemCallback(element));
    }
    EMCursorResult<T> result = EMCursorResult<T>(map['cursor'], list);

    return result;
  }

  /// ~english
  /// Gets the cursor.
  /// ~end
  ///
  /// ~chinese
  /// 获取游标。
  /// ~end
  final String? cursor;

  /// ~english
  /// Gets the data list.
  /// ~end
  ///
  /// ~chinese
  /// 获取一页数据列表。
  /// ~end
  final List<T> data;

  Map toJson() {
    Map result = {};
    result["cursor"] = cursor;
    result["list"] = data.map((item) {
      if (item is Map) {
        return item;
      } else if (item is List) {
        return item;
      } else if (item is String || item is int || item is bool || item is double) {
        return item;
      } else if (item is dynamic && item.toJson != null) {
        return item.toJson();
      } else {
        return item.toString();
      }
    }).toList();
    return result;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
