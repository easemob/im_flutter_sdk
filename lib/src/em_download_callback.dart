import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

class EMDownloadCallback {
  final VoidCallback? onSuccess;
  final void Function(EMError error)? onError;
  final void Function(int progress)? onProgress;

  EMDownloadCallback({
    this.onSuccess,
    this.onError,
    this.onProgress,
  });
}
