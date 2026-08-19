import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'attachment_picker.dart';
import 'attachment_store.dart';

/// 悬浮附件选择器：init 成功后插入 Overlay，生命周期独立于页面。
/// 常态为可拖动小球，点开为独立面板；选择结果只在面板内展示和复制，
/// 不侵入任何 API 页面。
class FloatingAttachment {
  static OverlayEntry? _entry;

  static void show(OverlayState overlay) {
    if (_entry != null) return;
    _entry = OverlayEntry(builder: (_) => const FloatingAttachmentWidget());
    overlay.insert(_entry!);
  }
}

class FloatingAttachmentWidget extends StatefulWidget {
  const FloatingAttachmentWidget({super.key});

  @override
  State<FloatingAttachmentWidget> createState() =>
      _FloatingAttachmentWidgetState();
}

class _FloatingAttachmentWidgetState extends State<FloatingAttachmentWidget> {
  /// null 表示未拖动过，用屏幕尺寸算默认位（日志球上方）。
  Offset? _pos;
  bool _open = false;

  static const double _ballSize = 48;

  Offset _defaultPos(Size screen) =>
      Offset(screen.width - _ballSize - 24, screen.height * 0.45);

  void _drag(DragUpdateDetails d, Size screen) {
    final next = (_pos ?? _defaultPos(screen)) + d.delta;
    setState(() {
      _pos = Offset(
        next.dx.clamp(0.0, screen.width - _ballSize),
        next.dy.clamp(0.0, screen.height - _ballSize),
      );
    });
  }

  Future<void> _pick(AttachmentKind kind) async {
    final record = await AttachmentPicker.pick(kind);
    if (record != null) AttachmentStore.instance.add(record);
  }

  static String _fmtSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
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
            child: Icon(Icons.attach_file),
          ),
        ),
      );
    }
    // 展开即为全屏面板；SafeArea 保证顶部操作栏避开刘海。
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
                    child: Text('附件',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => AttachmentStore.instance.clear(),
                    child: const Text('清空'),
                  ),
                  TextButton(
                    onPressed: () => Clipboard.setData(
                      ClipboardData(text: AttachmentStore.instance.fullJson),
                    ),
                    child: const Text('复制全部'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _open = false),
                    child: const Text('关闭'),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    for (final kind in AttachmentKind.values) ...[
                      if (kind != AttachmentKind.values.first)
                        const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pick(kind),
                          icon: Icon(kind.icon, size: 18),
                          label: Text(kind.label),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListenableBuilder(
                  listenable: AttachmentStore.instance,
                  builder: (context, _) {
                    final records = AttachmentStore.instance.records;
                    if (records.isEmpty) {
                      return const Center(child: Text('尚未选择附件'));
                    }
                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, i) {
                        final r = records[i];
                        return ListTile(
                          dense: true,
                          leading: Icon(r.kind.icon),
                          title: Text(
                            '${r.kind.label} · ${r.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${r.path}\n'
                            '${_fmtSize(r.size)}'
                            '${r.width != null ? ' · ${r.width}×${r.height}' : ''}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, fontFamily: 'monospace'),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: '复制该条 JSON',
                            onPressed: () => Clipboard.setData(
                              ClipboardData(
                                  text: AttachmentStore.recordJson(r)),
                            ),
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
