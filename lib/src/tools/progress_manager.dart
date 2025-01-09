import '../internal/inner_headers.dart';

class ProgressManager {
  ProgressManager() {
    ProgressChannel.setMethodCallHandler((call) async {
      Map? arg = call.arguments;
      if (arg != null) {
        if (call.method == "onSuccess") {
          _onSuccess(arg);
        } else if (call.method == "onProgress") {
          _onProgress(arg);
        } else if (call.method == "onError") {
          _onError(arg);
        }
      }
    });
  }

  Future<void> _onSuccess(Map map) async {
    String fileId = map["fileId"];
    String path = map["savePath"];
    Client.getInstance.groupManager.downloadCallback?.onSuccess
        ?.call(fileId, path);
  }

  Future<void>? _onProgress(Map map) async {
    String fileId = map["fileId"];
    int progress = map["progress"];
    Client.getInstance.groupManager.downloadCallback?.onProgress
        ?.call(fileId, progress);
  }

  Future<void>? _onError(Map map) async {
    String fileId = map["fileId"];
    Error err = Error.fromJson(map["error"]);
    Client.getInstance.groupManager.downloadCallback?.onError
        ?.call(fileId, err);
  }
}
