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
    }
    return null;
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

  int? getIntValue(String key, {int? defaultValue}) {
    int? ret = defaultValue;
    if (this.containsKey(key)) {
      dynamic value = this[key];
      if (value is int) {
        ret = value;
      }
    }
    return ret;
  }

  bool? getBoolValue(String key, {bool? defaultValue}) {
    bool? ret = defaultValue;
    if (this.containsKey(key)) {
      dynamic value = this[key];
      if (value is bool) {
        ret = value;
      }
    }
    return ret;
  }

  String? getStringValue(String key, {String? defaultValue}) {
    String? ret = defaultValue;
    if (this.containsKey(key)) {
      dynamic value = this[key];
      if (value is String) {
        ret = value;
      }
    }
    return ret;
  }

  double? getDoubleValue(String key, {double? defaultValue}) {
    double? ret = defaultValue;
    if (this.containsKey(key)) {
      dynamic value = this[key];
      if (value is double) {
        ret = value;
      } else if (value is int) {
        ret = value.toDouble();
      }
    }
    return ret;
  }

  Map? getMapValue(String key, {Map? defaultValue}) {
    Map? ret = defaultValue;
    if (this.containsKey(key)) {
      Map? value = this[key];
      if (value is double) {
        ret = value;
      }
    }
    return ret;
  }
}
