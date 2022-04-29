import 'package:flutter/material.dart';

import '../models/em_group_shared_file.dart';
import 'dart:convert' as convert;

Type typeOf<T>() => T;

typedef MapResultCallback<T> = T Function(dynamic obj);

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

  ///
  /// 如果给的value是null则不设置到map中。
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
    Map? ret = {};
    if (this.containsKey(key)) {
      Map tmpMap = this[key];
      for (var tmpKey in tmpMap.keys) {
        dynamic value = tmpMap[tmpKey];
        if (value is String) {
          do {
            try {
              dynamic data = convert.jsonDecode(value);
              value = data;
              break;
            } on FormatException {}
          } while (false);
          ret[tmpKey] = value;
        } else {
          ret[tmpKey] = value;
        }
      }
    }
    if (ret.length == 0) {
      ret = defaultValue;
    }
    return ret;
  }

  List<T>? getList<T>(String key, {valueCallback: MapResultCallback}) {
    List<String> list = this[key];
    List<T>? ret;
    List<T> typeList = [];
    for (var item in list) {
      typeList.add(valueCallback(item));
    }
    if (typeList.length > 0) {
      ret = typeList;
    }
    return ret;
  }
}
