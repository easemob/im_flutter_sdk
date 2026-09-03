import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Global log store: in-memory list + stdout ([APITEST] prefix single-line JSON) + file in documents directory.
/// seq increments globally for AI to determine order and completeness.
class LogStore extends ChangeNotifier {
  LogStore._();
  static final LogStore instance = LogStore._();

  static const String stdoutPrefix = '[APITEST]';

  /// In-memory log limit; oldest entries are dropped when exceeded; stdout and file output are always complete.
  static const int maxLines = 2000;

  final List<String> lines = [];
  int _seq = 0;
  File? _file;
  Future<void> _writeChain = Future.value();

  String? get filePath => _file?.path;

  /// Called once at startup: determines the file path and prints log.path.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/api_test.log');
    log('log.path', {'path': _file!.path});
  }

  void log(String source, Object? payload) {
    final line = jsonEncode({
      'ts': DateTime.now().millisecondsSinceEpoch,
      'seq': ++_seq,
      'source': source,
      'payload': payload,
    });
    lines.add(line);
    if (lines.length > maxLines) lines.removeAt(0);
    // ignore: avoid_print
    print('$stdoutPrefix $line');
    final file = _file;
    if (file != null) {
      // Serial async file write to avoid blocking UI; failures are silently ignored.
      _writeChain = _writeChain.then((_) async {
        try {
          await file.writeAsString('$stdoutPrefix $line\n',
              mode: FileMode.append, flush: true);
        } catch (_) {}
      });
    }
    notifyListeners();
  }

  void clear() {
    lines.clear();
    notifyListeners();
  }

  String get fullText => lines.join('\n');
}
