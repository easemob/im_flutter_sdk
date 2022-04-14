import '../tools/em_extension.dart';

import 'em_file_message_body.dart';
import 'em_chat_enums.dart';

///
/// The voice message body class.
///
class EMVoiceMessageBody extends EMFileMessageBody {
  ///
  /// Creates a voice message.
  ///
  /// Param [localPath] The local path of the voice file.
  ///
  /// Param [displayName] The name of the voice file.
  ///
  /// Param [fileSize] The size of the voice file in bytes.
  ///
  /// Param [duration] The voice duration in seconds.
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

  /// The voice duration in seconds.
  late final int duration;
}
