import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// 附件类型。
enum AttachmentKind {
  image('图片', Icons.image),
  video('视频', Icons.videocam),
  audio('语音', Icons.mic),
  file('文档', Icons.insert_drive_file);

  final String label;
  final IconData icon;
  const AttachmentKind(this.label, this.icon);
}

/// 一次附件选择的记录。
///
/// 字段只取 file_picker / Flutter 框架内置能拿到的：
/// 通用为 name/path/size/extension；图片额外带 width/height（dart:ui 解码）。
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

/// 独立的附件选择工具。
///
/// 输出只有一条 [AttachmentRecord]（取消返回 null），不依赖任何页面/状态，
/// 任何需要附件的 API 验证场景都可以直接调用：
///
/// ```dart
/// final record = await AttachmentPicker.pick(AttachmentKind.image);
/// ```
class AttachmentPicker {
  AttachmentPicker._();

  /// 选择指定类型的附件，返回记录。
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

  /// 用框架自带的 dart:ui 解码读图片宽高；读不出来就算了（返回 null）。
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
