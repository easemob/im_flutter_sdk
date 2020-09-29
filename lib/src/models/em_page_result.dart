typedef pageResultCallback = Object Function(dynamic obj);

class EMPageResult{

  EMPageResult();

  factory EMPageResult.fromJson(Map map, {dataItemCallback: pageResultCallback}) {
    var result= EMPageResult();
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