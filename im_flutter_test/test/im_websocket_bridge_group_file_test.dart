import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_test/bridge/im_websocket_bridge.dart';

void main() {
  test('group shared file upload prepares a device-local asset path', () async {
    final prepared = await prepareGroupSharedFileArgs(
      {'groupId': 'group-1'},
      ensureFile: (assetName) async {
        expect(assetName, 'bigPic.jpg');
        return '/data/user/0/im_flutter_test/cache/bigPic.jpg';
      },
    );

    expect(prepared, {
      'groupId': 'group-1',
      'filePath': '/data/user/0/im_flutter_test/cache/bigPic.jpg',
    });
  });

  test('group shared file upload preserves an explicit file path', () async {
    var ensureCalled = false;
    final prepared = await prepareGroupSharedFileArgs(
      {'groupId': 'group-1', 'filePath': '/sdcard/Download/shared.txt'},
      ensureFile: (_) async {
        ensureCalled = true;
        return '/unexpected';
      },
    );

    expect(prepared['filePath'], '/sdcard/Download/shared.txt');
    expect(ensureCalled, isFalse);
  });

  test('group shared file upload preserves an explicit non-string value',
      () async {
    var ensureCalled = false;
    final prepared = await prepareGroupSharedFileArgs(
      {'groupId': 'group-1', 'filePath': 123},
      ensureFile: (_) async {
        ensureCalled = true;
        return '/unexpected';
      },
    );

    expect(prepared['filePath'], 123);
    expect(ensureCalled, isFalse);
  });
}
