import '../tools/em_extension.dart';

///
/// The shared file info class.
///
/// For example:
/// You can use the following method to get information about the group shared file
/// through {@link EMGroupManager#getGroupFileListFromServer(String, int?, int?)}
///
/// ```dart
///   List<EMGroupSharedFile>? list = await EMClient.getInstance.groupManager.getGroupFileListFromServer(groupId);
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
  /// **return** The shared file ID.
  ///
  String? get fileId => _fileId;

  ///
  /// Gets the shared file name.
  ///
  /// **return** The shared file name.
  ///
  String? get fileName => _fileName;

  ///
  /// Gets the username who uploads the shared file.
  ///
  /// **return** The username who uploads the shared file.
  ///
  String? get fileOwner => _fileOwner;

  ///
  /// Gets the update Unix timestamp of the shared file, in ms.
  ///
  /// **return** The update Unix timestamp of the shared file, in ms.
  ///
  int? get createTime => _createTime;

  ///
  /// Gets the data length of the shared file, in bytes.
  ///
  /// **return** The data length of the shared file, in bytes.
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
    data.setValueWithOutNull("fileId", _fileId);
    data.setValueWithOutNull("name", _fileName);
    data.setValueWithOutNull("owner", _fileOwner);
    data.setValueWithOutNull("createTime", _createTime);
    data.setValueWithOutNull("fileSize", _fileSize);
    return data;
  }
}
