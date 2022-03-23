import '../tools/em_extension.dart';

class EMGroupSharedFile {
  EMGroupSharedFile._private();

  String? _fileId;
  String? _fileName;
  String? _fileOwner;
  int? _createTime;
  int? _fileSize;

  String? get fileId => _fileId;
  String? get fileName => _fileName;
  String? get fileOwner => _fileOwner;
  int? get createTime => _createTime;
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
    data.setValueWithOutNull("fileId", _fileId);
    data.setValueWithOutNull("name", _fileName);
    data.setValueWithOutNull("owner", _fileOwner);
    data.setValueWithOutNull("createTime", _createTime);
    data.setValueWithOutNull("fileSize", _fileSize);
    return data;
  }
}
