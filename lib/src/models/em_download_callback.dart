import '../internal/inner_headers.dart';

///
/// The group shared download callback.
///
class EMDownloadCallback {
  ///
  /// Download success callback.
  ///
  final void Function(String fileId, String path)? onSuccess;

  ///
  /// Download error callback.
  ///
  final void Function(String fileId, EMError error)? onError;

  ///
  /// Download progress callback.
  ///
  final void Function(String fileId, int progress)? onProgress;

  ///
  /// Create a group shared file download callback.
  ///
  EMDownloadCallback({
    this.onSuccess,
    this.onError,
    this.onProgress,
  });
}
