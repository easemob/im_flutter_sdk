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

  void putIfNotNull(String key, dynamic value) {
    if (value == null) {
      return;
    }
    this[key] = value;
  }

  Map? getMapValue(String key, {Map? defaultValue}) {
    Map? ret = {};
    if (this.containsKey(key)) {
      Map tmpMap = this[key];
      for (var tmpKey in tmpMap.keys) {
        dynamic value = tmpMap[tmpKey];
        if (value is String && (value.startsWith("{") && value.endsWith("}")) ||
            value is String && (value.startsWith("[") && value.endsWith("]"))) {
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

  List<T>? getList<T>(String key, {MapResultCallback? valueCallback}) {
    List<T>? ret;
    if (this.containsKey(key)) {
      List list = this[key];

      List<T> typeList = [];
      for (var item in list) {
        if (valueCallback != null) {
          typeList.add(valueCallback(item));
        } else {
          if (item is T) {
            typeList.add(item);
          }
        }
      }
      if (typeList.length > 0) {
        ret = typeList;
      }
    }
    return ret;
  }

  T? getValue<T>(
    String key, {
    required MapResultCallback callback,
  }) {
    if (!this.containsKey(key)) {
      return null;
    }
    return callback.call(this[key]);
  }
}
