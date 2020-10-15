typedef cursorResultCallback = Object Function(dynamic obj);

class EMCursorResult {

  EMCursorResult._private();

  factory EMCursorResult.fromJson(Map<String, dynamic> map, {dataItemCallback: cursorResultCallback}) {
    var result = EMCursorResult._private()
      .._cursor = map['cursor']
      .._data = List();

    (map['list'] as List).forEach((element) => result._data.add(dataItemCallback(element)));

    return result;
  }

  String _cursor;
  List _data;

  String get cursor => _cursor;
  List get data => _data;
}