import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// ChatManager 相关条目。
final chatApis = <ApiEntry>[
  ApiEntry(
    name: 'EMChatManager.sendMessage',
    group: 'ChatManager',
    description:
        '接收完整消息 JSON（EMMessage.fromJson 解析）后发送。chatType：0 单聊/1 群聊/2 聊天室；'
        'direction：0 发送/1 接收；status：0 创建/1 发送中/2 成功/3 失败；'
        'body.type：0 文本/1 图片/2 视频/3 位置/4 语音/5 文件/6 命令/7 自定义/8 合并。'
        '输出 JSON 可直接作为 downloadBigImage / voiceMessageToText 的 message 输入。',
    paramsTemplate: '''{
  "to": "targetUserId",
  "chatType": 0,
  "direction": 0,
  "status": 0,
  "body": {"type": 0, "content": "hello"}
}''',
    invoke: (p) async {
      final msg = EMMessage.fromJson(p);
      return EMClient.getInstance.chatManager.sendMessage(msg);
    },
  ),
  ApiEntry(
    name: 'EMChatManager.downloadBigImage',
    group: 'ChatManager',
    description:
        '下载图片消息的大图（4.22 新增）。message 为完整图片消息 JSON（body.type=1），'
        '直接粘贴 sendMessage 的输出即可（round-trip 成立）。'
        '注意：图片 body 的 toJson 不输出 bigImageRemotePath / bigImageDownloadStatus（服务器只读字段），'
        '回贴输入不受影响，下载后新字段通过事件回调或重新取消息验证。',
    paramsTemplate: '''{
  "message": {
    "msgId": "",
    "to": "",
    "chatType": 0,
    "direction": 1,
    "status": 2,
    "body": {
      "type": 1,
      "localPath": "",
      "remotePath": "",
      "fileStatus": 3,
      "thumbnailStatus": 1
    }
  }
}''',
    invoke: (p) async {
      final msg = EMMessage.fromJson(
        Map<String, dynamic>.from(p['message'] as Map),
      );
      return EMClient.getInstance.chatManager.downloadBigImage(msg);
    },
  ),
  ApiEntry(
    name: 'EMChatManager.voiceMessageToText',
    group: 'ChatManager',
    description:
        '语音消息转文字（4.22 新增），返回转换文本。message 为完整语音消息 JSON（body.type=4），'
        '直接粘贴 sendMessage 的输出即可（round-trip 成立）。'
        '注意：语音 body 的 toJson 不输出 text 字段（服务器下发只读字段），回贴输入不受影响。',
    paramsTemplate: '''{
  "message": {
    "msgId": "",
    "to": "",
    "chatType": 0,
    "direction": 1,
    "status": 2,
    "body": {
      "type": 4,
      "localPath": "",
      "remotePath": "",
      "duration": 1,
      "fileStatus": 1
    }
  }
}''',
    invoke: (p) async {
      final msg = EMMessage.fromJson(
        Map<String, dynamic>.from(p['message'] as Map),
      );
      return EMClient.getInstance.chatManager.voiceMessageToText(msg);
    },
  ),
  ApiEntry(
    name: 'EMChatManager.voiceFileToText',
    group: 'ChatManager',
    description:
        '本地语音文件转文字（4.22 新增），返回转换文本。'
        '可选参数 voiceParam：{"format": "pcm|mp3|amr", "sampleRate": 16000, "bitsPerSample": 16, "channels": 1}。',
    paramsTemplate: '''{
  "filePath": "/path/to/voice.amr"
}''',
    invoke: (p) async {
      EMVoiceParam? vp;
      if (p['voiceParam'] is Map) {
        vp = EMVoiceParam.fromJson(p['voiceParam'] as Map);
      }
      return EMClient.getInstance.chatManager.voiceFileToText(
        p['filePath'] as String,
        voiceParam: vp,
      );
    },
  ),
];
