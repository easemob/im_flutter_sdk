import 'package:flutter/services.dart';

abstract mixin class ManagerMixin {
  Future<dynamic> callNativeMethod(String method, [dynamic params]) async {
    throw UnimplementedError("not implemented.");
  }

  void updateNativeHandler(Future<dynamic> Function(MethodCall call)? handler) {
    throw UnimplementedError("not implemented.");
  }
}
