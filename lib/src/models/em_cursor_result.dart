typedef CursorResultCallback = Object Function(dynamic obj);

///
/// This is a generic class with cursors and paging to get results.
/// Returns an instance with the list and the cursor.
///
/// For example:
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

  factory EMCursorResult.fromJson(Map<String, dynamic> map,
      {dataItemCallback: CursorResultCallback}) {
    List<T> list = [];
    (map['list'] as List)
        .forEach((element) => list.add(dataItemCallback(element)));
    EMCursorResult<T> result = EMCursorResult<T>._private(map['cursor'], list);

    return result;
  }

  /// The cursor.
  final String? cursor;

  /// The data;
  final List<T> data;
}
