import '../internal/em_transform_tools.dart';
import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_file_message_body.dart';

///
/// 视频消息体类。
///
class EMVideoMessageBody extends EMFileMessageBody {
  ///
  /// 创建一条视频消息。
  ///
  /// Param [localPath] 视频文件本地路径。
  ///
  EMVideoMessageBody({
    required String localPath,

    /// Param [displayName] 视频名称。
    String? displayName,

    /// Param [duration] 视频时长，单位为秒。
    this.duration = 0,

    /// Param [fileSize] 视频文件大小，单位是字节。
    int? fileSize,

    /// Param [thumbnailLocalPath] 视频缩略图本地路径。
    this.thumbnailLocalPath,

    /// Param [height] 视频高度，单位是像素。
    this.height,

    /// /// Param [width] 视频宽度，单位是像素。
    this.width,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: MessageType.VIDEO,
        );

  /// @nodoc
  EMVideoMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.VIDEO) {
    this.duration = map.getIntValue("duration", defaultValue: 0)!;
    this.thumbnailLocalPath = map.getStringValue("thumbnailLocalPath");
    this.thumbnailRemotePath = map.getStringValue("thumbnailRemotePath");
    this.thumbnailSecret = map.getStringValue("thumbnailSecret");
    this.height = map.getDoubleValue("height")?.toDouble();
    this.width = map.getDoubleValue("width")?.toDouble();
    this.thumbnailStatus = EMFileMessageBody.downloadStatusFromInt(
        map.getIntValue("thumbnailStatus"));
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("duration", duration);
    data.setValueWithOutNull("thumbnailLocalPath", thumbnailLocalPath);
    data.setValueWithOutNull("thumbnailRemotePath", thumbnailRemotePath);
    data.setValueWithOutNull("thumbnailSecret", thumbnailSecret);
    data.setValueWithOutNull("height", height);
    data.setValueWithOutNull("width", width);
    data.setValueWithOutNull(
        "thumbnailStatus", downloadStatusToInt(this.thumbnailStatus));

    return data;
  }

  /// 视频时长，单位是秒。
  int? duration;

  /// 视频缩略图的本地路径。
  String? thumbnailLocalPath;

  /// 视频缩略图的在服务器上的存储路径。
  String? thumbnailRemotePath;

  /// 视频缩略图的密钥。
  String? thumbnailSecret;

  /// 视频缩略图的下载状态。
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// 视频宽度，单位是像素。
  double? width;

  /// 视频高度，单位是像素。
  double? height;
}
