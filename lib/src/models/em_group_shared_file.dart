import '../internal/inner_headers.dart';

///
/// The EMGroupSharedFile class, which manages the chat group shared files.
///
/// To get the information of the chat group shared file, call [EMGroupManager.fetchGroupFileListFromServer].
///
/// ```dart
///   List<EMGroupSharedFile>? list = await EMClient.getInstance.groupManager.fetchGroupFileListFromServer(groupId);
/// ```
class EMGroupSharedFile {
  EMGroupSharedFile._private();

  String? _fileId;
  String? _fileName;
  String? _fileOwner;
  int? _createTime;
  int? _fileSize;

  ///
  /// Gets the shared file ID.
  ///
  /// **Return** The shared file ID.
  ///
  String? get fileId => _fileId;

  ///
  /// Gets the shared file name.
  ///
  /// **Return** The shared file name.
  ///
  String? get fileName => _fileName;

  ///
  /// Gets the username that uploads the shared file.
  ///
  /// **Return** The username that uploads the shared file.
  ///
  String? get fileOwner => _fileOwner;

  ///
  /// Gets the Unix timestamp for uploading the shared file, in milliseconds.
  ///
  /// **Return** The Unix timestamp for uploading the shared file, in milliseconds.
  ///
  int? get createTime => _createTime;

  ///
  /// Gets the data length of the shared file, in bytes.
  ///
  /// **Return** The data length of the shared file, in bytes.
  ///
  int? get fileSize => _fileSize;

  /// @nodoc
  factory EMGroupSharedFile.fromJson(Map? map) {
    return EMGroupSharedFile._private()
      .._fileId = map?["fileId"]
      .._fileName = map?["name"]
      .._fileOwner = map?["owner"]
      .._createTime = map?["createTime"]
      .._fileSize = map?["fileSize"];
  }

  /// @nodoc
  Map toJson() {
    Map data = Map();
    data.add("fileId", _fileId);
    data.add("name", _fileName);
    data.add("owner", _fileOwner);
    data.add("createTime", _createTime);
    data.add("fileSize", _fileSize);
    return data;
  }
}
