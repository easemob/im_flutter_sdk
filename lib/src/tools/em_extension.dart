// 思考： 是否要把所有格式转换的部分都放到这个extension中？
import '../models/em_group_shared_file.dart';

extension MapExtension on Map {
  bool boolValue(String key) {
    if (!containsKey(key)) {
      return false;
    } else if (this[key] is int) {
      return this[key] == 0 ? false : true;
    } else if (this[key] is String) {
      return this[key].toString().length == 0 ? false : true;
    } else if (this[key] is bool) {
      return this[key];
    } else {
      return false;
    }
  }

  int? intValue(String key) {
    if (this.containsKey(key)) {
      return this[key];
    } else {
      return null;
    }
  }

  String? stringValue(String key) {
    if (this.containsKey(key)) {
      return this[key];
    } else {
      return null;
    }
  }

  List<T>? listValue<T>(String key) {
    if (this.containsKey(key)) {
      List obj = this[key];
      if (T is String) {
        List<String> strList = [];
        for (var item in obj) {
          strList.add(item);
        }
        return strList as List<T>;
      } else if (T is EMGroupSharedFile) {
        List<EMGroupSharedFile> fileList = [];
        for (var item in obj) {
          var file = EMGroupSharedFile.fromJson(item);
          fileList.add(file);
        }
        return fileList as List<T>;
      }
    } else {
      return null;
    }
  }
}

extension MapWithoutNull on Map {
  setValueWithOutNull<T>(String key, T? value,
      [Object Function(T object)? callback]) {
    if (value != null) {
      if (callback != null) {
        Object v = callback(value);
        this[key] = v;
      } else {
        this[key] = value;
      }
    }
  }
}
