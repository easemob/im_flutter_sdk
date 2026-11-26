import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  runApp(const ExampleApp());
}

/// Minimal im_flutter_sdk example: init -> login -> send -> receive.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'im_flutter_sdk example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  static const String _handlerId = 'example_chat_handler';
  static const String _messageEventId = 'example_message_event';

  final TextEditingController _appKeyController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _peerIdController = TextEditingController();
  final TextEditingController _messageController = TextEditingController(
    text: 'Hello from im_flutter_sdk!',
  );

  final List<String> _logs = <String>[];
  bool _initialized = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    // Receive messages for the whole lifetime of the page.
    ChatClient.getInstance.chatManager.addEventHandler(
      _handlerId,
      ChatEventHandler(
        onMessagesReceived: (List<ChatMessage> messages) {
          for (final ChatMessage message in messages) {
            final ChatMessageBody body = message.body;
            if (body is ChatTextMessageBody) {
              _log('Received from ${message.from}: ${body.content}');
            } else {
              _log('Received a message of type ${body.type}');
            }
          }
        },
      ),
    );
    // Observe the delivery result of sent messages.
    ChatClient.getInstance.chatManager.addMessageEvent(
      _messageEventId,
      ChatMessageEvent(
        onSuccess: (String msgId, ChatMessage msg) {
          _log('Message $msgId sent');
        },
        onError: (String msgId, ChatMessage msg, ChatError error) {
          _log('Message $msgId failed: ${error.code} ${error.description}');
        },
        onProgress: (String msgId, int progress) {
          _log('Message $msgId progress: $progress%');
        },
      ),
    );
  }

  @override
  void dispose() {
    ChatClient.getInstance.chatManager.removeEventHandler(_handlerId);
    ChatClient.getInstance.chatManager.removeMessageEvent(_messageEventId);
    _appKeyController.dispose();
    _userIdController.dispose();
    _tokenController.dispose();
    _peerIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _log(String line) {
    setState(() => _logs.insert(0, line));
  }

  Future<void> _run(Future<void> Function() action, String name) async {
    try {
      await action();
      _log('$name: success');
    } on ChatError catch (e) {
      _log('$name: ChatError ${e.code} ${e.description}');
    } catch (e) {
      _log('$name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('im_flutter_sdk example')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _appKeyController,
                  decoration: const InputDecoration(labelText: 'App Key'),
                ),
                TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: 'User ID'),
                ),
                TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(labelText: 'Token'),
                ),
                TextField(
                  controller: _peerIdController,
                  decoration: const InputDecoration(labelText: 'Peer User ID'),
                ),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    FilledButton(
                      onPressed: _initialized
                          ? null
                          : () => _run(() async {
                                await ChatClient.getInstance.init(
                                  ChatOptions.withAppKey(
                                    _appKeyController.text,
                                  ),
                                );
                                setState(() => _initialized = true);
                              }, 'init'),
                      child: const Text('Init'),
                    ),
                    FilledButton(
                      onPressed: _initialized && !_loggedIn
                          ? () => _run(() async {
                                await ChatClient.getInstance.loginWithToken(
                                  _userIdController.text,
                                  _tokenController.text,
                                );
                                setState(() => _loggedIn = true);
                              }, 'login')
                          : null,
                      child: const Text('Login'),
                    ),
                    FilledButton(
                      onPressed: _loggedIn
                          ? () => _run(() async {
                                final ChatMessage message =
                                    ChatMessage.createTxtSendMessage(
                                  targetId: _peerIdController.text,
                                  content: _messageController.text,
                                );
                                await ChatClient.getInstance.chatManager
                                    .sendMessage(message);
                              }, 'sendMessage')
                          : null,
                      child: const Text('Send'),
                    ),
                    OutlinedButton(
                      onPressed: _loggedIn
                          ? () => _run(() async {
                                await ChatClient.getInstance.logout();
                                setState(() => _loggedIn = false);
                              }, 'logout')
                          : null,
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (BuildContext context, int index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Text(
                  _logs[index],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
