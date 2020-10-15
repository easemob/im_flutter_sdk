typedef pageResultCallback = Object Function(dynamic obj);

class EMPageResult{

  EMPageResult._private();

  factory EMPageResult.fromJson(Map map, {dataItemCallback: pageResultCallback}) {
    var result= EMPageResult._private();
    result.._pageCount = map['count'];
    result.._data = List();

    (map['list'] as List).forEach((element) => result._data.add(dataItemCallback(element)));

    return result;
  }

  int _pageCount;
  List _data;

  get data => _data;
  get pageCount => _pageCount;
}