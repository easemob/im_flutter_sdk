typedef PageResultCallback = Object Function(dynamic obj);

/// ~english
/// The EMPageResult class, which is returned when calling the methods that fetch data by pagination.
/// The SDK also returns the number of remaining pages and the data count of the next page. If the dada count is less than the count you set, there is no more data on server.
///
/// Param [T] Generics.
/// ~end
///
/// ~chinese
/// 分页类。
/// 该类包含下次查询的页码以及相应页面上的数据条数。
/// 该对象在分页获取数据时返回。
///
/// Param [T] 泛型类型 T。
/// ~end
class EMPageResult<T> {
  EMPageResult._private();

  factory EMPageResult.fromJson(Map map,
      {dataItemCallback = PageResultCallback}) {
    EMPageResult<T> result = EMPageResult<T>._private();
    result.._pageCount = map['count'];
    result.._data = [];

    (map['list'] as List).forEach(
      (element) => result._data.add(
        dataItemCallback(element),
      ),
    );

    return result;
  }

  int? _pageCount;
  List<T> _data = [];

  /// ~english
  /// The page count.
  /// ~end
  ///
  /// ~chinese
  /// 当前页面上的数据条数。若 `PageCount` 小于传入的每页要获取的数量，表示当前是最后一页。
  /// ~end
  get pageCount => _pageCount;

  /// ~english
  /// The result data.
  /// ~end
  ///
  /// ~chinese
  /// 获取 <T> 泛型数据。
  /// ~end
  List<T>? get data => _data;
}
