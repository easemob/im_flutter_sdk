import 'package:flutter/cupertino.dart';

/// EMOptions - options to initialize SDK context
class EMOptions {
  const EMOptions(
      {@required this.appKey,
      @required this.imServer,
      this.imPort = 8080,
      this.autoLogin = false});

  final String appKey;
  final String imServer;
  final int imPort;
  final bool autoLogin;
}

/// EMMessage - various types of message
class EMMessage {
  const EMMessage({
    @required this.msgId,
    @required this.from,
    @required this.to,
    @required this.type,
    @required this.body,
  });

  final String msgId, from, to;
  final Type type;
  final EMMessageBody body;
}

// EMMessageBody - body of message
class EMMessageBody {}

/// Type - EMMessage type enumeration
enum Type {
  TXT,
  IMAGE,
  VIDEO,
  LOCATION,
  VOICE,
  FILE,
  CMD,
}
