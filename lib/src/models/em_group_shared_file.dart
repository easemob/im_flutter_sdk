import '../internal/inner_headers.dart';

///
/// 群组共享文件类。
///
/// 可以通过 {@link EMGroupManager#fetchGroupFileListFromServer(String, int?, int?)} 方法获取共享文件信息，示例如下：
///
/// ```dart
///   List<EMGroupSharedFile> list = await EMClient.getInstance.groupManager.fetchGroupFileListFromServer(groupId);
/// ```
class EMGroupSharedFile {
  EMGroupSharedFile._private();

  String? _fileId;
  String? _fileName;
  String? _fileOwner;
  int? _createTime;
  int? _fileSize;

  /// 共享文件 ID。
  String? get fileId => _fileId;

  /// 共享文件名称。
  String? get fileName => _fileName;

  /// 上传共享文件的成员用户 ID。
  String? get fileOwner => _fileOwner;

  /// 共享文件的上传时间戳，单位为毫秒。
  int? get createTime => _createTime;

  /// 共享文件大小，单位为字节。
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
