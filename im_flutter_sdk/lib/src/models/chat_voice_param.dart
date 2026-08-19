import 'package:im_flutter_sdk/src/tools/chat_extension.dart';

/// ~english
/// The voice file format.
/// ~end
///
/// ~chinese
/// 语音文件格式。
/// ~end
enum ChatVoiceFormat {
  /// ~english
  /// The PCM format.
  /// ~end
  ///
  /// ~chinese
  /// PCM 格式。
  /// ~end
  pcm,

  /// ~english
  /// The MP3 format.
  /// ~end
  ///
  /// ~chinese
  /// MP3 格式。
  /// ~end
  mp3,

  /// ~english
  /// The AMR format.
  /// ~end
  ///
  /// ~chinese
  /// AMR 格式。
  /// ~end
  amr,
}

/// ~english
/// The voice file parameter class, which describes the format of the voice file to be converted to text.
/// ~end
///
/// ~chinese
/// 语音文件参数类，用于描述待转文字的语音文件的格式。
/// ~end
class ChatVoiceParam {
  /// ~english
  /// Creates a voice file parameter.
  /// ~end
  ///
  /// ~chinese
  /// 创建语音文件参数。
  /// ~end
  ChatVoiceParam({
    this.format = ChatVoiceFormat.pcm,
    this.sampleRate,
    this.bitsPerSample,
    this.channels,
  });

  factory ChatVoiceParam.fromJson(Map map) {
    return ChatVoiceParam(
      format:
          ChatVoiceFormat.values.asNameMap()[map["format"]] ?? ChatVoiceFormat.pcm,
      sampleRate: map["sampleRate"],
      bitsPerSample: map["bitsPerSample"],
      channels: map["channels"],
    );
  }

  Map toJson() {
    Map data = {};
    data["format"] = format.name;
    data.putIfNotNull("sampleRate", sampleRate);
    data.putIfNotNull("bitsPerSample", bitsPerSample);
    data.putIfNotNull("channels", channels);

    return data;
  }

  /// ~english
  /// The format of the voice file. The default value is [ChatVoiceFormat.pcm].
  /// ~end
  ///
  /// ~chinese
  /// 语音文件格式，默认为 [ChatVoiceFormat.pcm]。
  /// ~end
  final ChatVoiceFormat format;

  /// ~english
  /// The sample rate of the voice file, in Hz.
  /// ~end
  ///
  /// ~chinese
  /// 语音文件的采样率，单位为 Hz。
  /// ~end
  final int? sampleRate;

  /// ~english
  /// The number of bits per sample of the voice file.
  /// ~end
  ///
  /// ~chinese
  /// 语音文件的采样位数。
  /// ~end
  final int? bitsPerSample;

  /// ~english
  /// The number of channels of the voice file.
  /// ~end
  ///
  /// ~chinese
  /// 语音文件的声道数。
  /// ~end
  final int? channels;
}
