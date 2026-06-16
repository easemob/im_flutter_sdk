import 'dart:io';

import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import 'sdk_config_loader.dart';
import 'websocket_config_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EMOptions options = SdkConfigLoader.loadOptions();

  await EMClient.getInstance.init(options);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WebSocketConfigPage(),
      routes: {
        '/sdk_demo': (_) => const MyHomePage(title: 'Flutter SDK Demo'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  String _userId = "";
  String _password = "";
  String _messageContent = "";
  String _chatId = "";
  final List<String> _logText = [];

  @override
  void initState() {
    super.initState();
    _addChatListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: "Enter userId"),
              onChanged: (username) => _userId = username,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Enter password"),
              onChanged: (password) => _password = password,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: _signIn,
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                    child: const Text("SIGN IN"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _signOut,
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                    child: const Text("SIGN OUT"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _signUp,
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(
                        Colors.lightBlue,
                      ),
                    ),
                    child: const Text("SIGN UP"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter the username you want to send",
              ),
              onChanged: (chatId) => _chatId = chatId,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Enter content"),
              onChanged: (msg) => _messageContent = msg,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _sendMessage,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.all(Colors.lightBlue),
              ),
              child: const Text("SEND TEXT"),
            ),
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

  @override
  void dispose() {
    Platform.isAndroid
        ? EMClient.getInstance.chatManager.removeMessageEvent(
            "UNIQUE_HANDLER_ID",
          )
        : EMClient.getInstance.chatManager.removeMessageEvent(
            "UNIQUE_HANDLER_ID",
          );
    EMClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    super.dispose();
  }

  void _addChatListener() {
    EMClient.getInstance.addConnectionEventHandler(
      'identifier',
      EMConnectionEventHandler(
        onUserDidLoginFromOtherDevice: (info) {
          _addLogToConsole(
              "onUserDidLoginFromOtherDevice,info: ${info.deviceName}");
        },
        onConnected: () {
          _addLogToConsole("onConnected");
        },
        onDisconnected: () {
          _addLogToConsole("onDisconnected");
        },
        onUserDidRemoveFromServer: () {
          _addLogToConsole("onUserDidRemoveFromServer");
        },
        onUserDidForbidByServer: () {
          _addLogToConsole("onUserDidForbidByServer");
        },
      ),
    );

    EMClient.getInstance.chatManager.addMessageEvent(
      "UNIQUE_HANDLER_ID",
      ChatMessageEvent(
        onSuccess: (msgId, msg) {
          _addLogToConsole("on message succeed");
        },
        onProgress: (msgId, progress) {
          _addLogToConsole("on message progress");
        },
        onError: (msgId, msg, error) {
          _addLogToConsole(
            "on message failed, code: ${error.code}, desc: ${error.description}",
          );
        },
      ),
    );

    EMClient.getInstance.chatManager.addEventHandler(
      "UNIQUE_HANDLER_ID",
      EMChatEventHandler(
        onMessagesReceived: (messages) {
          for (var msg in messages) {
            switch (msg.body.type) {
              case MessageType.TXT:
                {
                  EMTextMessageBody body = msg.body as EMTextMessageBody;
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
                  _addLogToConsole(
                    "receive location message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.VOICE:
                {
                  _addLogToConsole("receive voice message, from: ${msg.from}");
                }
                break;
              case MessageType.FILE:
                {
                  EMClient.getInstance.chatManager.downloadAttachment(msg);
                  _addLogToConsole("receive file message, from: ${msg.from}");
                }
                break;
              case MessageType.CUSTOM:
                {
                  _addLogToConsole("receive custom message, from: ${msg.from}");
                }
                break;
              case MessageType.CMD:
                {
                  // 当前回调中不会有 CMD 类型消息，CMD 类型消息通过 [EMChatManagerEventHandle.onCmdMessagesReceived] 回调接收
                }
                break;
              case MessageType.COMBINE:
                {
                  _addLogToConsole(
                    "receive combine message, from: ${msg.from}",
                  );
                }
            }
          }
        },
      ),
    );
    EMClient.getInstance.groupManager.removeEventHandler('identifier');
  }

  void _signIn() async {
    if (_userId.isEmpty || _password.isEmpty) {
      _addLogToConsole("userId or password is null");
      return;
    }

    try {
      _addLogToConsole("sign in...");
      await EMClient.getInstance.loginWithPassword(_userId, _password);
      await EMClient.getInstance.startCallback();
      _addLogToConsole("sign in succeed, username: $_userId");
    } on EMError catch (e) {
      _addLogToConsole("sign in failed, e: ${e.code} , ${e.description}");
    }
  }

  void _signOut() async {
    try {
      _addLogToConsole("sign out...");
      await EMClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
    } on EMError catch (e) {
      _addLogToConsole(
        "sign out failed, code: ${e.code}, desc: ${e.description}",
      );
    }
  }

  void _signUp() async {
    try {
      _addLogToConsole("sign up...");
      await EMClient.getInstance.createAccount(_userId, _password);
      _addLogToConsole("sign up succeed, username: $_userId");
    } on EMError catch (e) {
      _addLogToConsole("sign up failed, e: ${e.code} , ${e.description}");
    }
  }

  void _sendMessage() async {
    if (_chatId.isEmpty || _messageContent.isEmpty) {
      _addLogToConsole("single chat id or message content is null");
      return;
    }

    await EMClient.getInstance.chatManager.sendTxtMessage(
      targetId: _chatId,
      content: _messageContent,
    );
  }

  void _addLogToConsole(String log) {
    _logText.add("$_timeString: $log");
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }
}
