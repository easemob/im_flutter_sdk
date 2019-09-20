import 'package:flutter/services.dart';

import 'em_log.dart';

class EMContactManager{
  static const MethodChannel _chatManagerChannel =
  const MethodChannel('em_contact_manager');

  EMContactManager({this.log});
  EMLog log;
}