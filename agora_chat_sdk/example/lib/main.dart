// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

class AgoraChatConfig {
  static const String appKey = "";
  static const String userId = "";
  static const String agoraToken = "";
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  String? _messageContent, _chatId;
  final List<String> _logText = [];

  @override
  void initState() {
    super.initState();
    _initSDK();
    _addChatListener();
  }

  @override
  void dispose() {
    ChatClient.getInstance.chatManager.removeEventHandler('UNIQUE_HANDLER_ID');
    ChatClient.getInstance.chatManager.removeMessageEvent('UNIQUE_HANDLER_ID');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10),
            const Text("login userId: ${AgoraChatConfig.userId}"),
            const Text("agoraToken: ${AgoraChatConfig.agoraToken}"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: _signIn,
                    child: const Text("SIGN IN"),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _signOut,
                    child: const Text("SIGN OUT"),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter recipient's userId",
              ),
              onChanged: (chatId) => _chatId = chatId,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Enter message"),
              onChanged: (msg) => _messageContent = msg,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _sendMessage,
              child: const Text("SEND TEXT"),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                controller: scrollController,
                itemBuilder: (_, index) {
                  return Text(_logText[index]);
                },
                itemCount: _logText.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initSDK() async {
    assert(AgoraChatConfig.appKey.isNotEmpty, "appKey is empty");
    ChatOptions options = ChatOptions(
      appKey: AgoraChatConfig.appKey,
      autoLogin: false,
      debugMode: true,
      requireDeliveryAck: true,
    );
    options.enableHWPush();
    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback();
  }

  void _addChatListener() {
    ChatClient.getInstance.addConnectionEventHandler(
      "CONNECTION_UNIQUE_HANDLER_ID",
      ConnectionEventHandler(
        onConnected: () {
          _addLogToConsole("onConnected");
        },
        onDisconnected: () {
          _addLogToConsole("onDisconnected");
        },
      ),
    );

    ChatClient.getInstance.chatManager.addEventHandler(
      'UNIQUE_HANDLER_ID',
      ChatEventHandler(
        onMessagesReceived: onMessagesReceived,
        onMessagesDelivered: (messages) {
          for (var msg in messages) {
            _addLogToConsole("message, from: ${msg.from} is delivered");
          }
        },
      ),
    );

    ChatClient.getInstance.chatManager.addMessageEvent(
      'UNIQUE_HANDLER_ID',
      ChatMessageEvent(
        onSuccess: (msgId, msg) {
          _addLogToConsole("send message: $_messageContent");
        },
        onError: (msgId, msg, error) {
          _addLogToConsole(
            "send message failed, code: ${error.code}, desc: ${error.description}",
          );
        },
      ),
    );

    ChatClient.getInstance.chatRoomManager.addEventHandler(
      'UNIQUE_HANDLER_ID',
      ChatRoomEventHandler(
        onMuteListAddedFromChatRoom: (roomId, mutes) {
          _addLogToConsole("add mute callback works");
        },
      ),
    );
  }

  void _signIn() async {
    try {
      _addLogToConsole("begin login...  userId: ${AgoraChatConfig.userId}");
      await ChatClient.getInstance.loginWithToken(
        AgoraChatConfig.userId,
        AgoraChatConfig.agoraToken,
      );
      _addLogToConsole("login succeed, userId: ${AgoraChatConfig.userId}");
    } on ChatError catch (e) {
      _addLogToConsole("login failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
    } on ChatError catch (e) {
      _addLogToConsole(
        "sign out failed, code: ${e.code}, desc: ${e.description}",
      );
    }
  }

  void _sendMessage() async {
    if (_chatId == null || _messageContent == null) {
      _addLogToConsole("single chat id or message content is null");
      return;
    }

    var msg = ChatMessage.createTxtSendMessage(
      targetId: _chatId!,
      content: _messageContent!,
    );

    ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  void onMessagesReceived(List<ChatMessage> messages) {
    for (var msg in messages) {
      switch (msg.body.type) {
        case MessageType.TXT:
          {
            ChatTextMessageBody body = msg.body as ChatTextMessageBody;
            _addLogToConsole(
              "receive text message: ${body.content}, from: ${msg.from}",
            );
          }
          break;
        case MessageType.IMAGE:
          {
            _addLogToConsole("receive image message, from: ${msg.from}");
          }
          break;
        case MessageType.VIDEO:
          {
            _addLogToConsole("receive video message, from: ${msg.from}");
          }
          break;
        case MessageType.LOCATION:
          {
            _addLogToConsole("receive location message, from: ${msg.from}");
          }
          break;
        case MessageType.VOICE:
          {
            _addLogToConsole("receive voice message, from: ${msg.from}");
          }
          break;
        case MessageType.FILE:
          {
            _addLogToConsole("receive image message, from: ${msg.from}");
          }
          break;
        case MessageType.CUSTOM:
          {
            _addLogToConsole("receive custom message, from: ${msg.from}");
          }
          break;
        case MessageType.CMD:
          {}
          break;
        case MessageType.COMBINE:
          {}
          break;
      }
    }
  }

  void _addLogToConsole(String log) {
    _logText.add(_timeString + ": " + log);
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }
}
