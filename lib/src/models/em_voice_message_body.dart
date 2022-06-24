import '../tools/em_extension.dart';

import 'em_file_message_body.dart';
import 'em_chat_enums.dart';

///
/// 语音消息体类。
///
class EMVoiceMessageBody extends EMFileMessageBody {
  ///
  /// 创建一条语音消息。
  ///
  /// Param [localPath] 语言消息本地路径。
  ///
  /// Param [displayName] 语音文件名。
  ///
  /// Param [duration] 语音时长，单位是秒。
  ///
  /// Param [fileSize] 语音文件大小，单位是字节。
  ///
  EMVoiceMessageBody({
    localPath,
    this.duration = 0,
    String? displayName,
    int? fileSize,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: MessageType.VOICE,
        );

  /// @nodoc
  EMVoiceMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.VOICE) {
    this.duration = map.getIntValue("duration", defaultValue: 0)!;
  }

  /// @nodoc
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("duration", duration);
    return data;
  }

  /// 语音时长，单位是秒。
  late final int duration;
}
