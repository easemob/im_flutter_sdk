import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('presence handlers can be registered, replaced, removed, and cleared',
      () {
    final manager = EMClient.getInstance.presenceManager;
    final first = EMPresenceEventHandler();
    final replacement = EMPresenceEventHandler();

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
