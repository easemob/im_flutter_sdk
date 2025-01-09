typedef CursorResultCallback = Object Function(dynamic obj);

/// ~english
/// The CursorResult class, which specifies the cursor from which to query results.
/// When querying using this class, the SDK returns the queried instance and the cursor.
///
///   ```dart
///     String? cursor;
///     CursorResult<Group> result = await Client.getInstance.groupManager.fetchPublicGroupsFromServer(pageSize: 10, cursor: cursor);
///     List<Group>? group = result.data;
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
///     CursorResult<Group> result = await Client.getInstance.groupManager.getPublicGroupsFromServer(pageSize: 10, cursor: cursor);
///     List<Group>? group = result.data;
///     cursor = result.cursor;
///   ```
/// ~end
class CursorResult<T> {
  CursorResult._private(
    this.cursor,
    this.data,
  );

  factory CursorResult.fromJson(Map<String, dynamic> map,
      {dataItemCallback = CursorResultCallback}) {
    List<T> list = [];
    (map['list'] as List)
        .forEach((element) => list.add(dataItemCallback(element)));
    CursorResult<T> result = CursorResult<T>._private(map['cursor'], list);

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
}
