

typedef cursorResultCallback = Object Function(dynamic obj);

class EMCursorResult<T> {
  EMCursorResult._private();

  factory EMCursorResult.fromJson(Map<String, dynamic> map, {dataItemCallback: cursorResultCallback}) {
    EMCursorResult<T?> result = EMCursorResult<T?>._private()
      .._cursor = map['cursor']
      .._data = [];

    (map['list'] as List).forEach((element) => result._data!.add(dataItemCallback(element)));

    return result as EMCursorResult<T>;
  }

  String? _cursor;
  List<T>? _data;

  String? get cursor => _cursor;
  List<T>? get data => _data;
}
