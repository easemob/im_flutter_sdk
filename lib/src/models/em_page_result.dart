typedef PageResultCallback = Object Function(dynamic obj);

///
/// 分页类。
/// 该类包含下次查询的页码以及相应页面上的数据条数。
/// 该对象在分页获取数据时返回。
///
/// Param [T] 泛型类型 T。
///
class EMPageResult<T> {
  EMPageResult._private();

  /// @nodoc
  factory EMPageResult.fromJson(Map map,
      {dataItemCallback: PageResultCallback}) {
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

  /// 获取当前页面上的数据条数。若 `PageCount` 小于传入的每页要获取的数量，表示当前是最后一页。
  get pageCount => _pageCount;

  /// 获取 <T> 泛型数据。
  List<T>? get data => _data;
}
