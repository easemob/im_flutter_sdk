import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMDownloadCallback {
  final void Function(String fileId, String path)? onSuccess;
  final void Function(String fileId, EMError error)? onError;
  final void Function(String fileId, int progress)? onProgress;

  EMDownloadCallback({
    this.onSuccess,
    this.onError,
    this.onProgress,
  });
}
