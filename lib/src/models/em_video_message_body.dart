import '../internal/em_transform_tools.dart';
import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_file_message_body.dart';

///
/// The video message body.
///
class EMVideoMessageBody extends EMFileMessageBody {
  ///
  /// Creates a video message body.
  ///
  /// Param [localPath] The path of the video file.
  ///
  /// Param [displayName] The video name. like "video.mp4"
  ///
  /// Param [duration] The video duration in seconds.
  ///
  /// Param [fileSize] The size of the video file in bytes.
  ///
  /// Param [thumbnailLocalPath] The local path of the video thumbnail.
  ///
  /// Param [height] The video height.
  ///
  /// Param [width] The video width.
  ///
  EMVideoMessageBody({
    required String localPath,
    String? displayName,
    this.duration = 0,
    int? fileSize,
    this.thumbnailLocalPath,
    this.height,
    this.width,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: MessageType.VIDEO,
        );

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

  /// The video duration in seconds.
  late final int duration;

  ///  The local path of the video thumbnail.
  String? thumbnailLocalPath;

  /// The URL of the thumbnail on the server.
  String? thumbnailRemotePath;

  /// The secret key of the video thumbnail.
  String? thumbnailSecret;

  /// The download status of the video thumbnail.
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// The video width.
  double? width;

  /// The video height.
  double? height;
}
