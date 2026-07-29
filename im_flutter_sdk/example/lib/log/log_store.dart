import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 全局日志存储：内存列表 + stdout（[APITEST] 前缀单行 JSON）+ 文档目录落盘。
/// seq 全局递增，供 AI 判断顺序与完整性。
class LogStore extends ChangeNotifier {
  LogStore._();
  static final LogStore instance = LogStore._();

  static const String stdoutPrefix = '[APITEST]';

  final List<String> lines = [];
  int _seq = 0;
  File? _file;

  String? get filePath => _file?.path;

  /// 启动时调用一次：确定落盘路径并打印 log.path。
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
    // ignore: avoid_print
    print('$stdoutPrefix $line');
    try {
      _file?.writeAsStringSync('$stdoutPrefix $line\n', mode: FileMode.append);
    } catch (_) {
      // 落盘失败不影响主流程
    }
    notifyListeners();
  }

  void clear() {
    lines.clear();
    notifyListeners();
  }

  String get fullText => lines.join('\n');
}
