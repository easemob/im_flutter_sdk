// 思考： 是否要把所有格式转换的部分都放到这个extension中？

extension MapExtension on Map {
  bool boolValue(String key) {
    return (this[key] == null ) || (this[key] != 0);
  }
}