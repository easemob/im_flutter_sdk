import 'package:flutter/foundation.dart';

import '../auto/auto_mode.dart';

/// Agent (listening/interactive) mode entry — the third of three mutually
/// exclusive run modes:
///
/// | mode | enabled by | home |
/// |---|---|---|
/// | manual (default) | no dart-define | InitPage |
/// | script | `API_SCRIPT=<json>` | AutoHomePage |
/// | listening | `API_CONTROL=true` (Debug only) | AgentHomePage |
///
/// Only one mode may run per process: when both automated entry points are
/// set the app refuses to start either and shows a conflict page. Switching
/// modes is done by restarting the app.
class AgentMode {
  static const String _flag = String.fromEnvironment(
    'API_CONTROL',
    defaultValue: '',
  );

  /// Debug builds only: the control server never runs in release/profile.
  static bool get enabled => _flag == 'true' && kDebugMode;

  /// Both automated entry points set at once — refuse to start either.
  static bool get conflict => enabled && AutoMode.enabled;
}
