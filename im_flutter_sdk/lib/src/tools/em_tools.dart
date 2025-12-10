import 'dart:math';

class EMTools {
  static String get randomId =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(99999).toString();

  static int get millisecondsSinceEpoch =>
      DateTime.now().millisecondsSinceEpoch;
}
