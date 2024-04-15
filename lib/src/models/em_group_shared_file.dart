import '../internal/inner_headers.dart';

/// ~english
/// The EMGroupSharedFile class, which manages the chat group shared files.
///
/// To get the information of the chat group shared file, call [EMGroupManager.fetchGroupFileListFromServer].
///
/// ```dart
///   List<EMGroupSharedFile>? list = await EMClient.getInstance.groupManager.fetchGroupFileListFromServer(groupId);
/// ```
/// ~end
///
/// ~chinese
/// 群组共享文件类。
///
/// 可以通过 [EMGroupManager.fetchGroupFileListFromServer] 方法获取共享文件信息，示例如下：
///
/// ```dart
///   List<EMGroupSharedFile> list = await EMClient.getInstance.groupManager.fetchGroupFileListFromServer(groupId);
/// ```
/// ~end
class EMGroupSharedFile {
  EMGroupSharedFile._private();

  String? _fileId;
  String? _fileName;
  String? _fileOwner;
  int? _createTime;
  int? _fileSize;

  /// ~english
  /// Gets the shared file ID.
  ///
  /// **Return** The shared file ID.
  /// ~end
  ///
  /// ~chinese
  /// 共享文件 ID。
  /// ~end
  String? get fileId => _fileId;

  /// ~english
  /// Gets the shared file name.
  ///
  /// **Return** The shared file name.
  /// ~end
  ///
  /// ~chinese
  /// 共享文件名称。
  /// ~end
  String? get fileName => _fileName;

  /// ~english
  /// Gets the username that uploads the shared file.
  ///
  /// **Return** The username that uploads the shared file.
  /// ~end
  ///
  /// ~chinese
  /// 上传共享文件的成员用户 ID。
  /// ~end
  String? get fileOwner => _fileOwner;

  /// ~english
  /// Gets the Unix timestamp for uploading the shared file, in milliseconds.
  ///
  /// **Return** The Unix timestamp for uploading the shared file, in milliseconds.
  /// ~end
  ///
  /// ~chinese
  /// 共享文件的上传时间戳，单位为毫秒。
  /// ~end
  int? get createTime => _createTime;

  /// ~english
  /// Gets the data length of the shared file, in bytes.
  ///
  /// **Return** The data length of the shared file, in bytes.
  /// ~end
  ///
  /// ~chinese
  /// 共享文件大小，单位为字节。
  /// ~end
  int? get fileSize => _fileSize;

  factory EMGroupSharedFile.fromJson(Map? map) {
    return EMGroupSharedFile._private()
      .._fileId = map?["fileId"]
      .._fileName = map?["name"]
      .._fileOwner = map?["owner"]
      .._createTime = map?["createTime"]
      .._fileSize = map?["fileSize"];
  }

  Map toJson() {
    Map data = Map();
    data.putIfNotNull("fileId", _fileId);
    data.putIfNotNull("name", _fileName);
    data.putIfNotNull("owner", _fileOwner);
    data.putIfNotNull("createTime", _createTime);
    data.putIfNotNull("fileSize", _fileSize);
    return data;
  }
}
