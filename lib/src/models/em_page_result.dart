typedef PageResultCallback = Object Function(dynamic obj);

///
///This object instance is returned when calling the method of fetching by pages.
/// Returns the next page count and the data count of next page. If the pageCount is less than the count you set, there is no more data on server.
///
/// Param [T] Generics.
///
class EMPageResult<T> {
  EMPageResult._private();

  factory EMPageResult.fromJson(Map map,
      {dataItemCallback: PageResultCallback}) {
    EMPageResult<T> result = EMPageResult<T>._private();
    result.._pageCount = map['count'];
    result.._data = [];

    (map['list'] as List)
        .forEach((element) => result._data!.add(dataItemCallback(element)));

    return result;
  }

  int? _pageCount;
  List<T>? _data;

  /// The page count.
  get pageCount => _pageCount;

  /// The result data.
  List<T>? get data => _data;
}
