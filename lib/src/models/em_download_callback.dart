import 'em_error.dart';

///
/// 群文件下载回调
///
class EMDownloadCallback {
  ///
  /// 群文件下载成功回调。
  ///
  final void Function(String fileId, String path)? onSuccess;

  ///
  /// 群文件下载失败回调。
  ///
  final void Function(String fileId, EMError error)? onError;

  ///
  /// 群文件下载进度。
  ///
  final void Function(String fileId, int progress)? onProgress;

  ///
  /// 创建文件下载对象
  ///
  EMDownloadCallback({
    this.onSuccess,
    this.onError,
    this.onProgress,
  });
}
