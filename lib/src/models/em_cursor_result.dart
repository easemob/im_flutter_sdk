typedef cursorResultCallback = Object Function(dynamic obj);

class EMCursorResult {

  EMCursorResult();

  factory EMCursorResult.fromJson(Map<String, dynamic> map, {dataItemCallback: cursorResultCallback}) {
    var result = EMCursorResult()
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