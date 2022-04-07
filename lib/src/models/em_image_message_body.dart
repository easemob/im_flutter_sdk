import '../internal/em_transform_tools.dart';

import '../tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_file_message_body.dart';

///
/// The image message body class.
///
class EMImageMessageBody extends EMFileMessageBody {
  ///
  /// Creates an image message body with an image file.
  ///
  /// Param [localPath] The path of the image file.
  ///
  /// Param [displayName] The image name. like "img.jpeg"
  ///
  /// Param [thumbnailLocalPath] The local path of the image thumbnail.
  ///
  /// Param [sendOriginalImage] The original image when sending an image.
  ///
  /// Param [fileSize] The size of the image file in bytes.
  ///
  /// Param [width] The image width.
  ///
  /// Param [height] The image height.
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
  /// Sets whether to send the original image when sending an image.
  ///
  /// `false`: (default) Send the thumbnail(image with size larger than 100k will be compressed);
  /// `true`: Send the original image.
  ///
  bool sendOriginalImage = false;

  /// The local path or the URI of the thumbnail as a string.
  String? thumbnailLocalPath;

  /// The URL of the thumbnail on the server.
  String? thumbnailRemotePath;

  /// The secret to access the thumbnail. A secret is required for verification for thumbnail download.
  String? thumbnailSecret;

  /// The download status of the thumbnail.
  DownloadStatus thumbnailStatus = DownloadStatus.PENDING;

  /// The image width.
  double? width;

  /// The image height.
  double? height;
}
