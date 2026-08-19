import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'attachment_picker.dart';

/// 附件选择记录存储：单例，面板开关不丢记录。
/// 最新记录在列表头部；JSON 数组顺序与列表视觉顺序一致（从上到下）。
class AttachmentStore extends ChangeNotifier {
  AttachmentStore._();
  static final AttachmentStore instance = AttachmentStore._();

  final List<AttachmentRecord> _records = [];

  List<AttachmentRecord> get records => List.unmodifiable(_records);

  void add(AttachmentRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }

  void clear() {
    _records.clear();
    notifyListeners();
  }

  /// 整个列表的 JSON 数组（缩进格式），顺序与面板显示一致。
  String get fullJson => const JsonEncoder.withIndent('  ')
      .convert(_records.map((r) => r.toJson()).toList());

  /// 单条记录的 JSON（缩进格式）。
  static String recordJson(AttachmentRecord record) =>
      const JsonEncoder.withIndent('  ').convert(record.toJson());
}
