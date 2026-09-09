import 'dart:async';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../api_entry.dart';

/// ChatManager related entries.
final chatApis = <ApiEntry>[
  ApiEntry(
    name: 'ChatManager.sendMessage',
    group: 'ChatManager',
    description:
        '接收完整消息 JSON（ChatMessage.fromJson 解析）后发送。chatType：0 单聊/1 群聊/2 聊天室；'
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
      final msg = ChatMessage.fromJson(p);
      final sent = await ChatClient.getInstance.chatManager.sendMessage(msg);
      // sendMessage returns the pre-send message (local msgId); on success the server rewrites
      // the msgId, and the local DB stores it with the new id. downloadBigImage / voiceMessageToText
      // wrappers look up DB by msgId, so we must wait for the message status event to get the new id,
      // otherwise subsequent steps cannot find it (direct NPE / 500 on Android).
      final localId = sent.msgId;
      const eventId = 'api_tester_send_message';
      final completer = Completer<ChatMessage>();
      ChatClient.getInstance.chatManager.addMessageEvent(
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
        ChatClient.getInstance.chatManager.removeMessageEvent(eventId);
      }
    },
  ),
  ApiEntry(
    name: 'ChatManager.downloadBigImage',
    group: 'ChatManager',
    description: '下载图片消息的大图（4.22 新增）。message 为完整图片消息 JSON（body.type=1），'
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
      final msg = ChatMessage.fromJson(
        Map<String, dynamic>.from(p['message'] as Map),
      );
      return ChatClient.getInstance.chatManager.downloadBigImage(msg);
    },
  ),
  ApiEntry(
    name: 'ChatManager.searchMessagesFromServer',
    group: 'ChatManager',
    description: '服务端消息搜索（4.24 新增，需 Console 开通「消息搜索」增值服务，未开通时调用报错）。'
        'option.keywordList 为关键词列表（≤5 个，每个 1-120 字符、总共最大 120 字符）；keywordMatchType：0 OR/1 AND；'
        'msgTypes 为消息类型 index 列表（0 文本/1 图片/2 视频/3 位置/5 文件/7 自定义/8 合并，不支持 cmd/voice）；'
        'startTime/endTime 为毫秒时间戳，须成对出现；searchScope：0 内容/1 扩展属性/2 内容+扩展。'
        'pageNum 从 1 开始，结果按相关性排序。返回 {"count": n, "list": [...]}，'
        'list 元素含 msgId/body/attributes/from/to/convId/chatType/timestamp/highlightTexts。',
    paramsTemplate: '''{
  "option": {
    "keywordList": ["keyword"],
    "keywordMatchType": 0,
    "searchScope": 0
  },
  "pageSize": 20,
  "pageNum": 1
}''',
    invoke: (p) async {
      final option = ChatMessageSearchOption.fromJson(
        Map<String, dynamic>.from(p['option'] as Map),
      );
      final pageSize = p['pageSize'] as int? ?? 20;
      final pageNum = p['pageNum'] as int? ?? 1;
      final result =
          await ChatClient.getInstance.chatManager.searchMessagesFromServer(
        option: option,
        pageSize: pageSize,
        pageNum: pageNum,
      );
      return {
        'count': result.pageCount,
        'list': result.data.map((e) => e.toJson()).toList(),
      };
    },
  ),
  ApiEntry(
    name: 'ChatManager.voiceMessageToText',
    group: 'ChatManager',
    description: '语音消息转文字（4.22 新增），返回转换文本。message 为完整语音消息 JSON（body.type=4），'
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
      final msg = ChatMessage.fromJson(
        Map<String, dynamic>.from(p['message'] as Map),
      );
      return ChatClient.getInstance.chatManager.voiceMessageToText(msg);
    },
  ),
  ApiEntry(
    name: 'ChatManager.voiceFileToText',
    group: 'ChatManager',
    description: '本地语音文件转文字（4.22 新增），返回转换文本。'
        '可选参数 voiceParam：{"format": "pcm|mp3|amr", "sampleRate": 16000, "bitsPerSample": 16, "channels": 1}。',
    paramsTemplate: '''{
  "filePath": "/path/to/voice.amr"
}''',
    invoke: (p) async {
      ChatVoiceParam? vp;
      if (p['voiceParam'] is Map) {
        vp = ChatVoiceParam.fromJson(p['voiceParam'] as Map);
      }
      return ChatClient.getInstance.chatManager.voiceFileToText(
        p['filePath'] as String,
        voiceParam: vp,
      );
    },
  ),
  ApiEntry(
    name: 'ChatManager.translateMessage',
    group: 'ChatManager',
    description: '翻译文本消息，返回带翻译结果的 ChatMessage。message 为完整消息 JSON（body.type=0），'
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
      final msg = ChatMessage.fromJson(
        Map<String, dynamic>.from(p['message'] as Map),
      );
      return ChatClient.getInstance.chatManager.translateMessage(
        msg: msg,
        languages: (p['languages'] as List).cast<String>(),
      );
    },
  ),
];
