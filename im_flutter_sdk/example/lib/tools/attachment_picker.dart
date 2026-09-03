import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Attachment kind.
enum AttachmentKind {
  image('图片', Icons.image),
  video('视频', Icons.videocam),
  audio('语音', Icons.mic),
  file('文档', Icons.insert_drive_file);

  final String label;
  final IconData icon;
  const AttachmentKind(this.label, this.icon);
}

/// A record of one attachment pick.
///
/// Fields come only from file_picker / Flutter framework built-in values:
/// Common fields are name/path/size/extension; images additionally have width/height (decoded via dart:ui).
class AttachmentRecord {
  final AttachmentKind kind;
  final String name;
  final String path;
  final int size;
  final String? extension;
  final int? width;
  final int? height;
  final DateTime pickedAt;

  const AttachmentRecord({
    required this.kind,
    required this.name,
    required this.path,
    required this.size,
    required this.pickedAt,
    this.extension,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() => {
        'type': kind.name,
        'name': name,
        'path': path,
        'size': size,
        if (extension != null && extension!.isNotEmpty) 'extension': extension,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        'pickedAt': pickedAt.toIso8601String(),
      };
}

/// Standalone attachment picker utility.
///
/// Output is a single [AttachmentRecord] (null on cancel), independent of any page/state,
/// can be called directly in any API validation scenario that needs attachments:
///
/// ```dart
/// final record = await AttachmentPicker.pick(AttachmentKind.image);
/// ```
class AttachmentPicker {
  AttachmentPicker._();

  /// Pick an attachment of the specified kind; returns the record.
  static Future<AttachmentRecord?> pick(AttachmentKind kind) async {
    final result = await FilePicker.platform.pickFiles(
      type: switch (kind) {
        AttachmentKind.image => FileType.image,
        AttachmentKind.video => FileType.video,
        AttachmentKind.audio => FileType.audio,
        AttachmentKind.file => FileType.any,
      },
    );
    final file = result?.files.single;
    final path = file?.path;
    if (file == null || path == null || path.isEmpty) return null;

    int? width;
    int? height;
    if (kind == AttachmentKind.image) {
      final size = await _imageSize(path);
      if (size != null) {
        width = size.$1;
        height = size.$2;
      }
    }

    return AttachmentRecord(
      kind: kind,
      name: file.name,
      path: path,
      size: file.size,
      extension: file.extension,
      width: width,
      height: height,
      pickedAt: DateTime.now(),
    );
  }

  /// Use framework built-in dart:ui decoding for image dimensions; returns null if it fails.
  static Future<(int, int)?> _imageSize(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final size = (frame.image.width, frame.image.height);
      frame.image.dispose();
      codec.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }
}
