import '../tools/em_extension.dart';

import 'em_file_message_body.dart';
import 'em_chat_enums.dart';

///
/// The voice message body.
///
class EMVoiceMessageBody extends EMFileMessageBody {
  ///
  /// Creates a voice message body.
  ///
  /// Param [localPath] The path of the voice file.
  ///
  /// Param [displayName] The voice name. like "voice.mp3"
  ///
  /// Param [fileSize] The size of the voice file in bytes.
  ///
  /// Param [duration] The voice duration in seconds.
  ///
  EMVoiceMessageBody({
    localPath,
    String? displayName,
    int? fileSize,
    this.duration,
  }) : super(
          localPath: localPath,
          displayName: displayName,
          fileSize: fileSize,
          type: MessageType.VOICE,
        );

  EMVoiceMessageBody.fromJson({required Map map})
      : super.fromJson(map: map, type: MessageType.VOICE) {
    this.duration = map.getIntValue("duration");
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.setValueWithOutNull("duration", duration);
    return data;
  }

  /// The voice duration in seconds.
  int? duration;
}
