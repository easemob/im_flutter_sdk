import "../tools/em_extension.dart";
import '../internal/em_transform_tools.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// The base class of file messages.
///
class EMFileMessageBody extends EMMessageBody {
  /// Creates a message with an attachment.
  ///
  /// Param [localPath] The path of the image file.
  ///
  /// Param [displayName] The file name.
  ///
  /// Param [fileSize] The size of the file in bytes.
  ///
  /// Param [type] The file type.
  ///
  EMFileMessageBody({
    required this.localPath,
    this.displayName,
    this.fileSize,
    MessageType type = MessageType.FILE,
  }) : super(type: type);

  /// @nodoc
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

  /// @nodoc
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

  /// The local path of the attachment.
  late final String localPath;

  /// The token used to get the attachment.
  String? secret;

  /// The attachment path in the server.
  String? remotePath;

  /// The download status of the attachment.
  DownloadStatus fileStatus = DownloadStatus.PENDING;

  ///  The size of the attachment in bytes.
  int? fileSize;

  /// The attachment name.
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
