import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'attachment_picker.dart';

/// Attachment pick record store: singleton; records persist across panel toggles.
/// Newest record at the head; JSON array order matches visual list order (top to bottom).
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

  /// JSON array of the entire list (indented), order matches panel display.
  String get fullJson => const JsonEncoder.withIndent('  ')
      .convert(_records.map((r) => r.toJson()).toList());

  /// JSON of a single record (indented).
  static String recordJson(AttachmentRecord record) =>
      const JsonEncoder.withIndent('  ').convert(record.toJson());
}
