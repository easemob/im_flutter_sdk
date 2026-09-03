import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'log_store.dart';

/// Floating log: inserted into Overlay after init; lifecycle independent of pages.
/// Default is a draggable ball; tapping opens a half-screen panel.
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
  /// null means never dragged; default position calculated from screen size (above bottom-right corner).
  Offset? _pos;
  bool _open = false;

  static const double _ballSize = 48;

  Offset _defaultPos(Size screen) =>
      Offset(screen.width - _ballSize - 24, screen.height * 0.6);

  void _drag(DragUpdateDetails d, Size screen) {
    final next = (_pos ?? _defaultPos(screen)) + d.delta;
    setState(() {
      _pos = Offset(
        next.dx.clamp(0.0, screen.width - _ballSize),
        next.dy.clamp(0.0, screen.height - _ballSize),
      );
    });
  }

  /// Long content in the panel is collapsed showing head and tail; copy still copies the full text.
  static String _fold(String line) {
    const limit = 400;
    if (line.length <= limit) return line;
    return '${line.substring(0, 250)} …[折叠 ${line.length - 340} 字符]… ${line.substring(line.length - 90)}';
  }

  /// Panel displays as "time | source | content"; copy-all still produces the original single-line JSON.
  static String _display(String line) {
    try {
      final m = jsonDecode(line) as Map<String, dynamic>;
      final ts = DateTime.fromMillisecondsSinceEpoch(m['ts'] as int);
      String two(int v) => v.toString().padLeft(2, '0');
      final time = '${two(ts.hour)}:${two(ts.minute)}:${two(ts.second)}.'
          '${ts.millisecond.toString().padLeft(3, '0')}';
      return '$time | ${m['source']} | ${jsonEncode(m['payload'])}';
    } catch (_) {
      return line;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    if (!_open) {
      final pos = _pos ?? _defaultPos(screen);
      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: GestureDetector(
          onPanUpdate: (d) => _drag(d, screen),
          onTap: () => setState(() => _open = true),
          child: const CircleAvatar(
            radius: _ballSize / 2,
            child: Icon(Icons.article_outlined),
          ),
        ),
      );
    }
    // Expanded as a full-screen panel; SafeArea ensures the top action bar avoids the notch.
    return Positioned.fill(
      child: Material(
        elevation: 16,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('日志',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                            _fold(_display(line)),
                            style: const TextStyle(
                                fontSize: 11, fontFamily: 'monospace'),
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
      ),
    );
  }
}
