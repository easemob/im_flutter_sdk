import '../internal/em_transform_tools.dart';

import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_file_message_body.dart';

///
/// 图片消息体类。
///
class EMImageMessageBody extends EMFileMessageBody {
  ///
  /// 用图片文件创建一个图片消息体。
  ///
  /// Param [localPath] 图片文件本地路径。
  ///
  /// Param [displayName] 文件名。
  ///
  /// Param [thumbnailLocalPath] 图片缩略图本地路径。
  ///
  /// Param [sendOriginalImage] 发送图片消息时的原始图片文件。
  ///
  /// Param [fileSize] 图片文件大小，单位是字节。
  ///
  /// Param [width] 图片宽度，单位为像素。
  ///
  /// Param [height] 图片高度，单位为像素。
  ///
  EMImageMessageBody({
    required String localPath,
    String? displayName,
    this.thumbnailLocalPath,
    this.sendOriginalImage = false,
    int? fileSize,
    this.width,
    this.height,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: MessageType.IMAGE,
        );

  /// @nodoc
  EMImageMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.IMAGE) {
    this.thumbnailLocalPath = map.getStringValue("thumbnailLocalPath");
    this.thumbnailRemotePath = map.getStringValue("thumbnailRemotePath");
    this.thumbnailSecret = map.getStringValue("thumbnailSecret");
    this.sendOriginalImage = map.getBoolValue(
      "sendOriginalImage",
      defaultValue: false,
    )!;
    this.height = map.getDoubleValue("height");
    this.width = map.getDoubleValue("width");
    this.thumbnailStatus = EMFileMessageBody.downloadStatusFromInt(
      map.getIntValue("thumbnailStatus"),
    );
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("thumbnailLocalPath", thumbnailLocalPath);
    data.setValueWithOutNull("thumbnailRemotePath", thumbnailRemotePath);
    data.setValueWithOutNull("thumbnailSecret", thumbnailSecret);
    data.setValueWithOutNull("sendOriginalImage", sendOriginalImage);
    data.setValueWithOutNull("height", height);
    data.setValueWithOutNull("width", width);
    data.setValueWithOutNull(
        "thumbnailStatus", downloadStatusToInt(this.thumbnailStatus));
    return data;
  }

  ///
  /// 设置发送图片时，是否发送原图。
  /// - （默认）`false`：发送缩略图，图片超过 100 KB 会被压缩。
  ///  - `true`：发送原图。
  ///
  bool sendOriginalImage = false;

  /// 缩略图的本地路径或者字符串形式的资源标识符。
  String? thumbnailLocalPath;

  /// 缩略图的服务器路径。
  String? thumbnailRemotePath;

  /// 设置访问缩略图的密钥。下载缩略图时用户需要提供密钥进行校验。
  String? thumbnailSecret;

  /// 缩略图的下载状态。
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// 图片宽度，单位为像素。
  double? width;

  /// 图片高度，单位为像素。
  double? height;
}
