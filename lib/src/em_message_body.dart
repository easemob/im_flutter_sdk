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
}

/// EMFileMessageBody - file message body.
class EMFileMessageBody extends EMMessageBody {
  EMFileMessageBody(String localUrl)
      : this.displayName = '',
        this.localUrl = localUrl;
  EMFileMessageBody.of(EMFileMessageBody body)
      : this.displayName = body.displayName,
        this.localUrl = body.localUrl,
        this._body = body;
  int _fileLength;
  set fileLength(int length) => _fileLength = length;
  EMMessageBody _body;

  final String displayName;
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
}

/// Subclasses of EMFileMessageBody.
class EMImageMessageBody extends EMFileMessageBody {
  EMImageMessageBody(File imageFile, [File thumbnailFile, bool sendOriginalImage])
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
}

class EMNormalFileMessageBody extends EMFileMessageBody {
  EMNormalFileMessageBody(File file) : this._file = file,super(file.path);
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
}

/// TODO: class EMVideoMessageBody extends EMFileMessageBody {}
