// 思考： 是否要把所有格式转换的部分都放到这个extension中？
import '../models/em_group_shared_file.dart';

Type typeOf<T>() => T;

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
      if (typeOf<T>().toString() == "String") {
        List<String> strList = [];
        for (var item in obj) {
          strList.add(item);
        }
        return strList as List<T>;
      } else if (typeOf<T>().toString() == "EMGroupSharedFile") {
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

  void setValueWithOutNull<T>(String key, T? value,
      {Object Function(T object)? callback, T? defaultValue}) {
    if (value != null) {
      if (callback != null) {
        Object v = callback(value);
        this[key] = v;
      } else {
        this[key] = value;
      }
    } else {
      if (defaultValue != null) {
        this[key] = defaultValue;
      }
    }
  }

  T getValueWithOutNull<T>(String key, T defaultValue) {
    T ret = defaultValue;
    if (this.containsKey(key)) {
      dynamic value = this[key];
      if (value is T) {
        ret = value;
      }
    }
    return ret;
  }

  T? getValue<T>(String key) {
    T? ret;
    if (this.containsKey(key)) {
      dynamic value = this[key];
      if (value is T) {
        ret = value;
      } else {
        ret = null;
      }
    }
    return ret;
  }
}
