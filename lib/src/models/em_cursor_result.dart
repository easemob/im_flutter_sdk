typedef CursorResultCallback = Object Function(dynamic obj);

///
/// The EMCursorResult class, which specifies the cursor from which to query results.
/// When querying using this class, the SDK returns the queried instance and the cursor.
///
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

  /// Gets the cursor.
  final String? cursor;

  /// Gets the data list.
  final List<T> data;
}
