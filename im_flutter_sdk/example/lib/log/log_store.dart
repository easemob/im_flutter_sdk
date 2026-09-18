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

  /// Chunk marker for events longer than [stdoutChunkBytes]: `[APITEST+1/3] `.
  static const String stdoutChunkPrefix = '[APITEST+';

  /// Device consoles truncate long log lines (observed around 1 KB on both
  /// Android and iOS), which corrupts the JSON and silently loses the event.
  /// Longer events are therefore printed as ordered chunks marked with
  /// `[APITEST+<index>/<total>]`, and the auto-mode runner reassembles them. The
  /// budget is counted in UTF-8 bytes; the file copy always keeps the complete
  /// single-line record.
  static const int stdoutChunkBytes = 512;

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
    _printChunked(line);
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

  /// Prints one event, split into ordered chunks when it exceeds the console limit.
  void _printChunked(String line) {
    final chunks = _stdoutChunks(line);
    if (chunks.length <= 1) {
      // ignore: avoid_print
      print('$stdoutPrefix ${chunks.isEmpty ? line : chunks.single}');
      return;
    }
    for (var index = 0; index < chunks.length; index++) {
      // ignore: avoid_print
      print('$stdoutChunkPrefix${index + 1}/${chunks.length}] ${chunks[index]}');
    }
  }

  List<String> _stdoutChunks(String line) {
    final chunks = <String>[];
    final buffer = StringBuffer();
    var bytes = 0;
    for (final rune in line.runes) {
      final text = String.fromCharCode(rune);
      final size = utf8.encode(text).length;
      if (bytes + size > stdoutChunkBytes) {
        chunks.add(buffer.toString());
        buffer.clear();
        bytes = 0;
      }
      buffer.write(text);
      bytes += size;
    }
    if (buffer.isNotEmpty) chunks.add(buffer.toString());
    return chunks;
  }

  void clear() {
    lines.clear();
    notifyListeners();
  }

  String get fullText => lines.join('\n');
}
