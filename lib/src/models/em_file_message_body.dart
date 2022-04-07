import 'package:im_flutter_sdk/src/internal/em_transform_tools.dart';
import 'package:im_flutter_sdk/src/tools/em_extension.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// The file message.
///
class EMFileMessageBody extends EMMessageBody {
  /// Creates an file message body with an file.
  ///
  /// Param [localPath] The path of the image file.
  ///
  /// Param [displayName] The file name. like "file.doc"
  ///
  /// Param [fileSize] The size of the file in bytes.
  ///
  /// Param [type] The body type.
  ///
  EMFileMessageBody({
    required this.localPath,
    this.displayName,
    this.fileSize,
    MessageType type = MessageType.FILE,
  }) : super(type: type);

  EMFileMessageBody.fromJson(
      {required Map map, MessageType type = MessageType.FILE})
      : super.fromJson(map: map, type: type) {
    this.secret = map.getStringValue("secret");
    this.remotePath = map.getStringValue("remotePath");
    this.fileSize = map.getIntValue("fileSize");
    this.localPath = map.getStringValue("localPath", defaultValue: "")!;
    this.displayName = map.getStringValue("displayName");
    this.fileStatus = EMFileMessageBody.downloadStatusFromInt(
      map.getIntValue("fileStatus"),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("secret", this.secret);
    data.setValueWithOutNull("remotePath", this.remotePath);
    data.setValueWithOutNull("fileSize", this.fileSize);
    data.setValueWithOutNull("localPath", this.localPath);
    data.setValueWithOutNull("displayName", this.displayName);
    data.setValueWithOutNull(
        "fileStatus", downloadStatusToInt(this.fileStatus));

    return data;
  }

  /// The localPath of the attachment file.
  late final String localPath;

  /// The file's token.
  String? secret;

  /// The path of the attachment file in the server.
  String? remotePath;

  /// The download status of the attachment file .
  DownloadStatus fileStatus = DownloadStatus.PENDING;

  ///  The size of the file in bytes.
  int? fileSize;

  /// The file name. like "file.doc"
  String? displayName;

  static DownloadStatus downloadStatusFromInt(int? status) {
    if (status == 0) {
      return DownloadStatus.DOWNLOADING;
    } else if (status == 1) {
      return DownloadStatus.SUCCESS;
    } else if (status == 2) {
      return DownloadStatus.FAILED;
    } else {
      return DownloadStatus.PENDING;
    }
  }
}
