import '../internal/inner_headers.dart';

/// ~english
/// The group shared download callback.
/// ~end
///
/// ~chinese
/// 群文件下载回调。
/// ~end
class EMDownloadCallback {
  /// ~english
  /// Download success callback.
  /// ~end
  ///
  /// ~chinese
  /// 群文件下载成功回调。
  /// ~end
  final void Function(String fileId, String path)? onSuccess;

  /// ~english
  /// Download error callback.
  /// ~end
  ///
  /// ~chinese
  /// 群文件下载失败回调。
  /// ~end
  final void Function(String fileId, EMError error)? onError;

  /// ~english
  /// Download progress callback.
  /// ~end
  ///
  /// ~chinese
  /// 群文件下载进度。取值范围 [0,100]。
  /// ~end
  final void Function(String fileId, int progress)? onProgress;

  /// ~english
  /// Create a group shared file download callback.
  /// ~end
  ///
  /// ~chinese
  /// 创建文件下载对象。
  /// ~end
  EMDownloadCallback({
    this.onSuccess,
    this.onError,
    this.onProgress,
  });
}
