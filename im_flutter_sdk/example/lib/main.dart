import 'package:flutter/material.dart';

import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: ListView(
          children: [
            ListTile(onTap: init, title: const Text('init')),
            ListTile(onTap: login, title: const Text('login')),
            ListTile(onTap: logout, title: const Text('logout')),
            ListTile(onTap: sendMessage, title: const Text('sendMessage')),
            ListTile(onTap: loadMessage, title: const Text('loadMessage')),
            ListTile(onTap: modifyMessage, title: const Text('modifyMessage')),
          ],
        )),
      ),
    );
  }

  _addMessageListener() {
    EMClient.getInstance.chatManager.addMessageEvent(
      'identifier',
      ChatMessageEvent(
        onSuccess: (msgId, msg) {
          debugPrint('onSuccess');
        },
        onError: (msgId, msg, e) {
          debugPrint('onError');
        },
        onProgress: (msgId, progress) {},
      ),
    );

    EMClient.getInstance.chatManager.addEventHandler(
      'identifier',
      EMChatEventHandler(
        onMessagesReceived: (messages) {
          debugPrint('onMessagesReceived ${messages.first.body}');
        },
      ),
    );
  }

  init() async {
    await EMClient.getInstance.init(
      EMOptions.withAppKey('easemob#easeim', extSettings: {
        ExtSettings.kDisableIosEnterBackground: false,
      }),
    );
    _addMessageListener();
  }

  login() async {
    await EMClient.getInstance.loginWithPassword('du001', '1');
    debugPrint("login success");
  }

  logout() async {
    await EMClient.getInstance.logout(true);
  }

  sendMessage() async {
    EMMessage message = EMMessage.createTxtSendMessage(
      content: 'hello',
      targetId: 'du002',
    );

    await EMClient.getInstance.chatManager.sendMessage(message);
  }

  loadMessage() async {
    EMConversation? conv =
        await EMClient.getInstance.chatManager.getConversation('du002');
    if (conv != null) {
      List<EMMessage> messages = await conv.loadMessages();
      for (EMMessage message in messages) {
        debugPrint('message: ${message.body}');
      }
    }
  }

  modifyMessage() async {
    List cons = await EMClient.getInstance.chatManager.loadAllConversations();
    List<EMMessage> list = await cons.first.loadMessages();
    debugPrint('e: ${list.last.body}');
    await EMClient.getInstance.chatManager.modifyMessage(
      messageId: list.last.msgId,
      msgBody: EMCustomMessageBody(event: 'test', params: {'key1': 'sdasdas'}),
      attributes: {"key1": "value3"},
    );

    final msg =
        await EMClient.getInstance.chatManager.loadMessage(list.last.msgId);
    debugPrint('modifyMessage: ${msg?.body}, ${msg?.attributes}');
  }
}
