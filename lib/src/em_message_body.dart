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
  EMTextMessageBody(String message) : this.message = message;
  final String message;

  @override
  String toString() => '[EMTextMessageBody], {message: $message}';

  @override
  Map<String, dynamic> toDataMap() {
    var result = Map<String, dynamic>();
    result['message'] = message;
    return result;
  }

  static EMMessageBody fromData(Map<String, dynamic> data) {
    return EMTextMessageBody(data['message']);
  }
}

/// EMCmdMessageBody - cmd message body.
class EMCmdMessageBody extends EMMessageBody {
  EMCmdMessageBody(String action, [Map<String, String> params])
      : this._action = action,
        this._params = params,
        this.deliverOnlineOnly = false;

  final String _action;
  String get action => _action;
  final Map<String, String> _params;
  Map<String, String> get params => _params;

  bool deliverOnlineOnly;

  @override
  String toString() =>
      '[EMCmdMessageBody], {action: $_action, params: $_params}';

  @override
  Map<String, dynamic> toDataMap() {
    var result = Map<String, dynamic>();
    result['action'] = _action;
    result['deliverOnlineOnly'] = deliverOnlineOnly;
    result['params'] = _params;
    return result;
  }

  static EMMessageBody fromData(Map<String, dynamic> data) {
    var message = EMCmdMessageBody(data['action'], data['params']);
    message.deliverOnlineOnly = data['deliverOnlineOnly'];
    return message;
  }
}

/// EMFileMessageBody - file message body.
class EMFileMessageBody extends EMMessageBody {
  EMFileMessageBody(String localUrl)
      : this.displayName = '',
        this.localUrl = localUrl;
  EMFileMessageBody.of(EMFileMessageBody body)
      : this.displayName = body.displayName,
        this._fileLength = body._fileLength,
        this.localUrl = body.localUrl,
        this.downloadStatus = body.downloadStatus,
        this.fileName = body.fileName,
        this.remoteUrl = body.remoteUrl,
        this.secret = body.secret,
        this._body = body;
  EMFileMessageBody.ofData(Map<String, dynamic> data)
      : this.displayName = data['displayName'],
        this._fileLength = data['fileLength'],
        this.localUrl = data['localUrl'],
        this.downloadStatus = data['downloadStatus'],
        this.fileName = data['fileName'],
        this.remoteUrl = data['remoteUrl'],
        this.secret = data['secret'];

  int _fileLength;
  set fileLength(int length) => _fileLength = length;
  EMMessageBody _body;

  String displayName;
  EMDownloadStatus downloadStatus;
  String fileName;
  String localUrl;
  String remoteUrl;
  String secret;

  @override
  String toString() =>
      '[EMFileMessageBody], {displayName: $displayName, fileName: $fileName,'
      'localUrl: $localUrl, remoteUrl: $remoteUrl, secret: $secret,'
      'fileLength: $_fileLength,'
      'body: $_body}';

  @override
  Map<String, dynamic> toDataMap() {
    var result = Map<String, dynamic>();
    result['displayName'] = displayName;
    result['fileLength'] = _fileLength;
    result['fileName'] = fileName;
    result['localUrl'] = localUrl;
    result['remoteUrl'] = remoteUrl;
    result['secret'] = secret;
    result['status'] = downloadStatus;
    return result;
  }

  static EMMessageBody fromData(Map<String, dynamic> data) {
    var message = EMFileMessageBody(data['localUrl']);
    message
      ..displayName = data['displayName']
      ..downloadStatus = data['downloadStatus']
      ..fileName = data['fileName']
      ..remoteUrl = data['remoteUrl']
      ..secret = data['secret'];
    return message;
  }
}

/// EMLocationMessageBody - location message body.
class EMLocationMessageBody extends EMMessageBody {
  EMLocationMessageBody(String address, double latitude, double longitude,
      [EMLocationMessageBody body])
      : this.address = address,
        this.latitude = latitude,
        this.longitude = longitude,
        this._body = body;
  EMLocationMessageBody _body;
  final String address;
  final double latitude;
  final double longitude;

  @override
  String toString() =>
      '[EMLocationMessageBody], {address: $address, latitude: $latitude, longitude: $longitude, body: $_body}';

  @override
  Map<String, dynamic> toDataMap() {
    var result = Map<String, dynamic>();
    result['address'] = address;
    result['latitude'] = latitude;
    result['longitude'] = longitude;
    return result;
  }

  static EMMessageBody fromData(Map<String, dynamic> data) {
    var message = EMLocationMessageBody(
        data['address'], data['latitude'], data['longitude']);
    return message;
  }
}

/// Subclasses of EMFileMessageBody.
class EMImageMessageBody extends EMFileMessageBody {
  EMImageMessageBody(File imageFile,
      [File thumbnailFile, bool sendOriginalImage])
      : this._imageFile = imageFile,
        this._thumbnailFile = thumbnailFile,
        this.sendOriginalImage = sendOriginalImage,
        super(imageFile.path);
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
  EMImageMessageBody._internal(Map<String, dynamic> data)
      : this.height = data["height"],
        this.sendOriginalImage = data["sendOriginalImage"],
        this.thumbnailLocalPath = data["thumbnailLocalPath"],
        this.thumbnailSecret = data["thumbnailSecret"],
        this.thumbnailUrl = data["thumbnailUrl"],
        this.width = data["width"],
        super.ofData(data);
  File _imageFile;
  File _thumbnailFile;

  int height;
  bool sendOriginalImage;
  String thumbnailLocalPath;
  String thumbnailSecret;
  String thumbnailUrl;
  int width;

  void setThumbnailSize(int width, int height) {
    this.width = width;
    this.height = height;
  }

  @override
  String get fileName => _imageFile.path;

  @override
  String toString() =>
      '[EMImageMessageBody], {fileName: $fileName, :$width, height: $height,'
      'thumbnailLocalPath: $thumbnailLocalPath, thumbnailSecret: $thumbnailSecret, thumbnailUrl: $thumbnailUrl,'
      'sendOriginalImage: $sendOriginalImage }';

  @override
  Map<String, dynamic> toDataMap() {
    var result = Map<String, dynamic>();
    result["height"] = height;
    result["sendOriginalImage"] = sendOriginalImage;
    result["thumbnailLocalPath"] = thumbnailLocalPath;
    result["thumbnailSecret"] = thumbnailSecret;
    result["thumbnailUrl"] = thumbnailUrl;
    result["width"] = width;
    return result;
  }

  static EMMessageBody fromData(Map<String, dynamic> data) {
    return EMImageMessageBody._internal(data);
  }
}

class EMNormalFileMessageBody extends EMFileMessageBody {
  EMNormalFileMessageBody(File file)
      : this._file = file,
        super(file.path);
  EMNormalFileMessageBody._internal(Map<String, dynamic> data)
      : this._file = null,
        this._fileSize = data['fileSize'],
        super.ofData(data);
  final File _file;
  int _fileSize;
  Future<int> get fileSize async {
    //lazy load file size
    if (_fileSize == null) {
      _fileSize = await _file.length();
    }
    return _fileSize;
  }

  @override
  String toString() => '[EMNormalFileMessageBody], {fileSize: $fileSize}';

  @override
  Map<String, dynamic> toDataMap() {
    var result = Map.of(super.toDataMap());
    result["fileSize"] = _fileSize;
    return result;
  }

  static EMMessageBody fromData(Map<String, dynamic> data) {
    return EMNormalFileMessageBody._internal(data);
  }
}

class EMVoiceMessageBody extends EMFileMessageBody {
  EMVoiceMessageBody(File voiceFile, int duration)
      : this._file = voiceFile,
        this._length = duration,
        super(voiceFile.path);
  EMVoiceMessageBody.of(EMVoiceMessageBody body)
      : this._file = body._file,
        this._length = body._length,
        super.of(body);
  EMVoiceMessageBody._internal(Map<String, dynamic> data)
      : this._file = null,
        this._length = data['length'],
        super.ofData(data);
  final File _file;
  int _length;
  Future<int> get length async {
    if (_length == null) {
      _length = await _file.length();
    }
    return _length;
  }

  @override
  String toString() => '[EMVoiceMessageBody], {length: $length}';

  @override
  Map<String, dynamic> toDataMap() {
    var result = Map.of(super.toDataMap());
    result["length"] = _length;
    return result;
  }

  static EMMessageBody fromData(Map<String, dynamic> data) {
    return EMVoiceMessageBody._internal(data);
  }
}

/// TODO: class EMVideoMessageBody extends EMFileMessageBody {}
