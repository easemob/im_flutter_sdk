import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'log_store.dart';

/// 悬浮日志：init 成功后插入 Overlay，生命周期独立于页面。
/// 常态为可拖动小球，点开为半屏面板。
class FloatingLog {
  static OverlayEntry? _entry;

  static void show(OverlayState overlay) {
    if (_entry != null) return;
    _entry = OverlayEntry(builder: (_) => const FloatingLogWidget());
    overlay.insert(_entry!);
  }
}

class FloatingLogWidget extends StatefulWidget {
  const FloatingLogWidget({super.key});

  @override
  State<FloatingLogWidget> createState() => _FloatingLogWidgetState();
}

class _FloatingLogWidgetState extends State<FloatingLogWidget> {
  Offset _pos = const Offset(300, 500);
  bool _open = false;

  /// 面板内超长内容折叠显示首尾，复制仍复制全文。
  static String _fold(String line) {
    const limit = 400;
    if (line.length <= limit) return line;
    return '${line.substring(0, 250)} …[折叠 ${line.length - 340} 字符]… ${line.substring(line.length - 90)}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_open) {
      return Positioned(
        left: _pos.dx,
        top: _pos.dy,
        child: GestureDetector(
          onPanUpdate: (d) => setState(() => _pos += d.delta),
          onTap: () => setState(() => _open = true),
          child: const CircleAvatar(
            radius: 24,
            child: Icon(Icons.article_outlined),
          ),
        ),
      );
    }
    final height = MediaQuery.of(context).size.height * 0.5;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: Material(
        elevation: 16,
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('日志', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => LogStore.instance.clear(),
                  child: const Text('清空'),
                ),
                TextButton(
                  onPressed: () => Clipboard.setData(
                    ClipboardData(text: LogStore.instance.fullText),
                  ),
                  child: const Text('复制全部'),
                ),
                TextButton(
                  onPressed: () => setState(() => _open = false),
                  child: const Text('关闭'),
                ),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: ListenableBuilder(
                listenable: LogStore.instance,
                builder: (context, _) {
                  final lines = LogStore.instance.lines;
                  return ListView.builder(
                    reverse: true,
                    itemCount: lines.length,
                    itemBuilder: (context, i) {
                      final line = lines[lines.length - 1 - i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          _fold(line),
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
