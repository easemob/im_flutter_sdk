import 'em_error.dart';

///
/// The group shared download callback.
///
class EMDownloadCallback {
  ///
  /// Download success callback.
  ///
  /// Param [fileId] download file's fileId.
  ///
  /// Param [path] download file saved path.
  ///
  final void Function(String fileId, String path)? onSuccess;

  ///
  /// Download error callback.
  ///
  /// Param [fileId] download file's fileId.
  ///
  /// Param [error] error.
  ///
  final void Function(String fileId, EMError error)? onError;

  ///
  /// Download progress callback.
  ///
  /// Param [fileId] download file's fileId.
  ///
  /// Param [progress] download progress.
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
