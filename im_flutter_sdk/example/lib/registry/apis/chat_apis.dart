import 'dart:async';

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
        '附件类 body（图片/视频/语音/文件）必须带 localPath；chatType/direction/status 及'
        ' fileStatus/thumbnailStatus 等状态字段可省略，缺省按默认值解析。'
        '发送后等待消息状态事件，输出结果的 data 是服务器改写 msgId 后的消息 JSON，'
        '填入 downloadBigImage / voiceMessageToText 的 message 字段即可串联。',
    paramsTemplate: '''{
  "to": "targetUserId",
  "chatType": 0,
  "direction": 0,
  "status": 0,
  "body": {"type": 0, "content": "hello"}
}''',
    invoke: (p) async {
      final msg = EMMessage.fromJson(p);
      final sent = await EMClient.getInstance.chatManager.sendMessage(msg);
      // sendMessage 返回的是发送前消息（本地 msgId）；发送成功后服务器会改写
      // msgId，本地 DB 以新 id 存储。downloadBigImage / voiceMessageToText 的
      // wrapper 按 msgId 查 DB，所以这里必须等消息状态事件拿到新 id 的消息，
      // 否则后续步骤查不到（Android 上直接 NPE / 500）。
      final localId = sent.msgId;
      const eventId = 'api_tester_send_message';
      final completer = Completer<EMMessage>();
      EMClient.getInstance.chatManager.addMessageEvent(
        eventId,
        ChatMessageEvent(
          onSuccess: (msgId, m) {
            if (msgId == localId && !completer.isCompleted) {
              completer.complete(m);
            }
          },
          onError: (msgId, m, err) {
            if (msgId == localId && !completer.isCompleted) {
              completer.completeError(err);
            }
          },
        ),
      );
      try {
        return await completer.future.timeout(const Duration(seconds: 30));
      } finally {
        EMClient.getInstance.chatManager.removeMessageEvent(eventId);
      }
    },
  ),
  ApiEntry(
    name: 'EMChatManager.downloadBigImage',
    group: 'ChatManager',
    description:
        '下载图片消息的大图（4.22 新增）。message 为完整图片消息 JSON（body.type=1），'
        '取 sendMessage 结果的 data 填入 message 字段即可（round-trip 成立）。'
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
        '取 sendMessage 结果的 data 填入 message 字段即可（round-trip 成立）。'
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
  ApiEntry(
    name: 'EMChatManager.translateMessage',
    group: 'ChatManager',
    description:
        '翻译文本消息，返回带翻译结果的 EMMessage。message 为完整消息 JSON（body.type=0），'
        'languages 为目标语言代码数组。'
        '传入不存在的 msgId 时预期返回错误而不是崩溃（复验测试反馈的崩溃问题）。',
    paramsTemplate: '''{
  "message": {
    "msgId": "not-exist-msg-id-000000",
    "to": "targetUserId",
    "chatType": 0,
    "direction": 0,
    "status": 2,
    "body": {"type": 0, "content": "hello"}
  },
  "languages": ["zh-Hans"]
}''',
    invoke: (p) async {
      final msg = EMMessage.fromJson(
        Map<String, dynamic>.from(p['message'] as Map),
      );
      return EMClient.getInstance.chatManager.translateMessage(
        msg: msg,
        languages: (p['languages'] as List).cast<String>(),
      );
    },
  ),
];
