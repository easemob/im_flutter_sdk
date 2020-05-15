import "dart:io";
import 'em_domain_terms.dart';

/// EMMessageBody class hierarchy.
/// 4 top-level message body:
/// * [EMTextMessageBody]
/// * [EMCmdMessageBody]
/// * [EMFileMessageBody]
/// * [EMLocationMessageBody]
/// Also, there's 4 sub-classes of [EMFileMessageBody]
/// * [EMImageMessageBody]
/// * [EMNormalFileMessageBody]
/// * [EMVoiceMessageBody]
/// * [EMVideoMessageBody]

/// EMTextMessageBody - text message body.
class EMTextMessageBody extends EMMessageBody {
  /// 初始化方法，[message]: 消息内容
  EMTextMessageBody(String message) : this.message = message;
  final String message;

  @override
  /// @nodoc
  String toString() => '[EMTextMessageBody], {message: $message}';

  @override
  /// @nodoc
  Map<String, dynamic> toDataMap() {
    var result = Map<String, dynamic>();
    result['message'] = message;
    return result;
  }

  /// @nodoc
  static EMMessageBody fromData(Map data) {
    return EMTextMessageBody(data['message']);
  }
}

/// EMCmdMessageBody - cmd message body.
class EMCmdMessageBody extends EMMessageBody {
  /// 初始化方法，[action]: 命令内容
  EMCmdMessageBody(String action)
      : this._action = action,
        this.deliverOnlineOnly = false;

  final String _action;

  /// 命令内容
  String get action => _action;

  /// 是否只发在线
  bool deliverOnlineOnly;

  @override
  /// @nodoc
  Map toDataMap() {
    var result = {};
    result['action'] = _action;
    result['deliverOnlineOnly'] = deliverOnlineOnly;
    return result;
  }

  /// @nodoc
  static EMMessageBody fromData(Map data) {
    var message = EMCmdMessageBody(data['action']);
    message.deliverOnlineOnly = data['deliverOnlineOnly'];
    return message;
  }
}

/// EMNormalFileMessageBody - file message body.
abstract class EMFileMessageBody extends EMMessageBody {
  /// 初始化方法, [localUrl]: 文件路径
  EMFileMessageBody(String localUrl)
      :
        this.localUrl = localUrl;

  /// @nodoc
  EMFileMessageBody.of(EMFileMessageBody body)
      : this.displayName = body.displayName,
        this.localUrl = body.localUrl,
        this.downloadStatus = body.downloadStatus,
        this.fileName = body.fileName,
        this.remoteUrl = body.remoteUrl,
        this.secret = body.secret,
        this._body = body;

  /// @nodoc
  EMFileMessageBody.ofData(Map data)
      : this.displayName = data['displayName'],
        this.localUrl = data['localUrl'],
        this.downloadStatus = fromEMDownloadStatus(data['downloadStatus']),
        this.fileName = data['fileName'],
        this.remoteUrl = data['remoteUrl'],
        this.secret = data['secret'];

  EMMessageBody _body;

  /// 文件名称
  String displayName;

  /// 文件下载状态
  EMDownloadStatus downloadStatus;

  /// 文件名称
  String fileName;

  /// 文件本地路径
  String localUrl;

  /// 文件服务器路径
  String remoteUrl;

  /// @nodoc secret
  String secret;

  @override
  /// @nodoc
  String toString() =>
      '[EMFileMessageBody], {displayName: $displayName, fileName: $fileName,'
      'localUrl: $localUrl, remoteUrl: $remoteUrl, secret: $secret,'
      'body: $_body}';


  @override
  /// @nodoc
  Map toDataMap() {
    var result = {};
    result['displayName'] = displayName;
    result['fileName'] = fileName;
    result['localUrl'] = localUrl;
    result['remoteUrl'] = remoteUrl;
    result['secret'] = secret;
    result['downloadStatus'] = toEMDownloadStatus(downloadStatus);
    return result;
  }
}

/// EMLocationMessageBody - location message body.
class EMLocationMessageBody extends EMMessageBody {
  /// 初始化方法, [address]: 地址名称; [latitude]: 维度; [longitude]: 经度
  EMLocationMessageBody(String address, double latitude, double longitude,
      [EMLocationMessageBody body])
      : this.address = address,
        this.latitude = latitude,
        this.longitude = longitude,
        this._body = body;


  EMLocationMessageBody _body;
  /// 地址
  final String address;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  @override
  /// @nodoc
  String toString() =>
      '[EMLocationMessageBody], {address: $address, latitude: $latitude, longitude: $longitude, body: $_body}';

  @override
  /// @nodoc
  Map toDataMap() {
    var result = {};
    result['address'] = address;
    result['latitude'] = latitude;
    result['longitude'] = longitude;
    return result;
  }

  /// @nodoc
  static EMMessageBody fromData(Map<String, dynamic> data) {
    var message = EMLocationMessageBody(
        data['address'], data['latitude'], data['longitude']);
    return message;
  }
}

/// Subclasses of EMFileMessageBody.
class EMImageMessageBody extends EMFileMessageBody {
  /// 创建方法， [imageFile]: 图片文件;  [sendOriginalImage]: 是否发送原图
  EMImageMessageBody(File imageFile,
      bool sendOriginalImage)
      : this._imageFile = imageFile,
        this.sendOriginalImage = sendOriginalImage,
        super(imageFile.path);

  /// @nodoc
  EMImageMessageBody.of(EMImageMessageBody body)
      : this._imageFile = body._imageFile,
        this._thumbnailFile = body._thumbnailFile,
        this.height = body.height,
        this.sendOriginalImage = body.sendOriginalImage,
        this.thumbnailLocalPath = body.thumbnailLocalPath,
        this.thumbnailSecret = body.thumbnailSecret,
        this.thumbnailUrl = body.thumbnailUrl,
        this.width = body.width,
        super.of(body);

  /// @nodoc
  EMImageMessageBody._internal(Map<String, dynamic> data)
      : this.height = data["height"],
        this.width = data["width"],
        this.sendOriginalImage = data["sendOriginalImage"],
        this.thumbnailLocalPath = data["thumbnailLocalPath"],
        this.thumbnailSecret = data["thumbnailSecret"],
        this.thumbnailUrl = data["thumbnailUrl"],
        super.ofData(data);

  /// 大图文件
  File _imageFile;

  /// 缩略图文件
  File _thumbnailFile;

  /// 高度
  int height;

  /// 宽度
  int width;

  /// @nodoc 是否发送原图
  bool sendOriginalImage;

  /// 缩略图路径
  String thumbnailLocalPath;

  /// @nodoc
  String thumbnailSecret;

  /// 缩略图远端地址
  String thumbnailUrl;

  /// @nodoc
  void setThumbnailSize(int width, int height) {
    this.width = width;
    this.height = height;
  }

  @override
  /// 文件名称
  String get fileName => _imageFile.path;

  @override
  /// @nodoc
  String toString() =>
      '[EMImageMessageBody], {fileName: $fileName, :$width, height: $height,'
      'thumbnailLocalPath: $thumbnailLocalPath, thumbnailSecret: $thumbnailSecret, thumbnailUrl: $thumbnailUrl,'
      'sendOriginalImage: $sendOriginalImage }';

  @override
  /// @nodoc
  Map toDataMap() {
    var result = Map.of(super.toDataMap());
    result["height"] = height;
    result["width"] = width;
    result["sendOriginalImage"] = sendOriginalImage;
    result["thumbnailLocalPath"] = thumbnailLocalPath;
    result["thumbnailSecret"] = thumbnailSecret;
    result["thumbnailUrl"] = thumbnailUrl;
    return result;
  }

  /// @nodoc
  static EMMessageBody fromData(Map<String, dynamic> data) {
    return EMImageMessageBody._internal(data);
  }
}

class EMNormalFileMessageBody extends EMFileMessageBody {
  /// 创建方法, [file] 要发送的文件
  EMNormalFileMessageBody(File file)
      : this._file = file,
        super(file.path);

  /// @nodoc
  EMNormalFileMessageBody._internal(Map<String, dynamic> data)
      : this._file = null,
        this._fileSize = data['fileSize'],
        super.ofData(data);

  final File _file;

  int _fileSize;

  /// 文件大小
  Future<int> get fileSize async {
    //lazy load file size
    if (_fileSize == null) {
      _fileSize = await _file.length();
    }
    return _fileSize;
  }

  @override
  /// @nodoc
  String toString() => '[EMNormalFileMessageBody], {fileSize: $fileSize}';

  @override
  /// @nodoc
  Map toDataMap() {
    var result = Map.of(super.toDataMap());
    result["fileSize"] = _fileSize;
    return result;
  }

  /// @nodoc
  static EMMessageBody fromData(Map<String, dynamic> data) {
    return EMNormalFileMessageBody._internal(data);
  }
}

class EMVoiceMessageBody extends EMFileMessageBody {
  /// 创建方法，[voiceFile]: 要发送的音频文件; [duration]: 文件时长
  EMVoiceMessageBody(File voiceFile, int voiceDuration)

      : this._file = voiceFile,
        this._voiceDuration = voiceDuration,
        super(voiceFile.path);

  EMVoiceMessageBody.of(EMVoiceMessageBody body)
      : this._file = body._file,
        this._fileLength = body._fileLength,
        super.of(body);

  EMVoiceMessageBody._internal(Map<String, dynamic> data)
      : this._file = null,
        this._voiceDuration = data['voiceDuration'],
        super.ofData(data);

  final File _file;
  /// 文件大小
  int _fileLength;
  /// 音频文件时长
  int _voiceDuration;

  /// 获取音频时长，秒为单位
  int getVoiceDuration(){
    return _voiceDuration;
  }

  /// 文件大小
  Future<int> get getFileLength async {
    if (_fileLength == null) {
      _fileLength = await _file.length();
    }
    return _fileLength;
  }

  @override
  /// @nodoc
  String toString() => '[EMVoiceMessageBody], {fileLength: $_fileLength},{voiceDuration: $_voiceDuration}';

  @override

  /// @nodoc
  Map toDataMap() {
    var result = Map.of(super.toDataMap());
    result["voiceDuration"] = _voiceDuration;
    return result;
  }

  /// @nodoc
  static EMMessageBody fromData(Map<String, dynamic> data) {
    return EMVoiceMessageBody._internal(data);
  }
}

class EMVideoMessageBody extends EMFileMessageBody {
  /// 创建方法，[videoFilePath]: 要发送的文件路径; [duration]: 文件时长
  EMVideoMessageBody(File videoFilePath, int videoDuration)
      : this._file = videoFilePath,
        this._videoDuration = videoDuration,
        super(videoFilePath.path);

  /// @nodoc
  EMVideoMessageBody.of(EMVideoMessageBody body)
      : this._file = body._file,
        this._fileLength = body._fileLength,
        super.of(body);

  /// @nodoc
  EMVideoMessageBody._internal(Map data)
      : this._file = null,
        this._videoDuration = data['videoDuration'],
        super.ofData(data);

  var _file;
  var _fileLength;
  int _videoDuration;

  /// 获取视频时长，秒为单位
  int getVoiceDuration(){
    return _videoDuration;
  }

  /// 文件大小
  Future<int> get getFileLength async {
    if (_fileLength == null) {
      _fileLength = await _file.length();
    }
    return _fileLength;
  }

  /// @nodoc
  static EMMessageBody fromData(Map data) {
    return EMVideoMessageBody._internal(data);
  }

  @override
  /// @nodoc
  Map toDataMap() {
    var result = Map.of(super.toDataMap());
    result["videoDuration"] = _videoDuration;
    return result;
  }

}