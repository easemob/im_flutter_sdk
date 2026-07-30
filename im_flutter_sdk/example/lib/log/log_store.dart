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

  /// 内存日志上限，超出丢弃最旧；stdout 与落盘不受影响，始终完整。
  static const int maxLines = 2000;

  final List<String> lines = [];
  int _seq = 0;
  File? _file;
  Future<void> _writeChain = Future.value();

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
    if (lines.length > maxLines) lines.removeAt(0);
    // ignore: avoid_print
    print('$stdoutPrefix $line');
    final file = _file;
    if (file != null) {
      // 串行异步落盘，避免同步写阻塞 UI；失败静默不影响主流程。
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
