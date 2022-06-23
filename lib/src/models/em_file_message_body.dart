import "../tools/em_extension.dart";
import '../internal/em_transform_tools.dart';

import 'em_chat_enums.dart';
import 'em_message_body.dart';

///
/// 文件类消息的基类。
///
class EMFileMessageBody extends EMMessageBody {
  /// 创建一条带文件附件的消息。
  ///
  /// Param [localPath] 图片文件路径。
  ///
  /// Param [displayName] 文件显示名称。
  ///
  /// Param [fileSize] 文件大小，单位是字节。
  ///
  /// Param [type] 文件类型。
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

  /// 附件的本地路径。
  late final String localPath;

  /// 获取附件的密钥。
  String? secret;

  /// 附件的服务器路径。
  String? remotePath;

  /// 附件的下载状态：
  DownloadStatus fileStatus = DownloadStatus.PENDING;

  /// 附件的大小，以字节为单位。
  int? fileSize;

  /// 附件的名称。
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
