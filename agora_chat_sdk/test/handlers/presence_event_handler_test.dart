import 'package:flutter_test/flutter_test.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('presence handlers can be registered, replaced, removed, and cleared',
      () {
    final manager = ChatClient.getInstance.presenceManager;
    final first = ChatPresenceEventHandler();
    final replacement = ChatPresenceEventHandler();

    manager.addEventHandler('case', first);
    expect(manager.getEventHandler('case'), same(first));

    manager.addEventHandler('case', replacement);
    expect(manager.getEventHandler('case'), same(replacement));

    manager.removeEventHandler('case');
    expect(manager.getEventHandler('case'), isNull);

    manager.addEventHandler('one', first);
    manager.addEventHandler('two', replacement);
    manager.clearEventHandlers();
    expect(manager.getEventHandler('one'), isNull);
    expect(manager.getEventHandler('two'), isNull);
  });
}
