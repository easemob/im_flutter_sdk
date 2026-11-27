import 'package:agora_chat_sdk_interface/src/event_handler/channel_manager.dart';
import 'package:agora_chat_sdk_interface/src/interface/manager_mixin.dart';

class ProgressManager with ManagerMixin {
  // 5.1.0: wire the native file_progress_manager channel so group shared
  // file download events reach Dart.
  @override
  void updateNativeHandler(handler) {
    ProgressChannel.setMethodCallHandler(handler);
  }
}
