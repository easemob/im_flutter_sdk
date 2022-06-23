typedef CursorResultCallback = Object Function(dynamic obj);

///
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
///
class EMCursorResult<T> {
  EMCursorResult._private(
    this.cursor,
    this.data,
  );

  /// @nodoc
  factory EMCursorResult.fromJson(Map<String, dynamic> map,
      {dataItemCallback: CursorResultCallback}) {
    List<T> list = [];
    (map['list'] as List)
        .forEach((element) => list.add(dataItemCallback(element)));
    EMCursorResult<T> result = EMCursorResult<T>._private(map['cursor'], list);

    return result;
  }

  ///
  /// 获取游标。
  ///
  final String? cursor;

  ///
  /// 获取一页数据列表。
  ///
  final List<T> data;
}
