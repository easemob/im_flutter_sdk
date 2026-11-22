import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:integration_test/integration_test.dart';

import 'modules/push_cases.dart';
import 'modules/room_cases.dart';
import 'support/env.dart';
import 'support/login.dart';
import 'support/rest_fixture.dart';
import 'support/session.dart';

/// Special entry: chat-room conversation enabled, room and push edge cases.
///
/// The chat room itself is created through REST during setup, because the
/// 4.25 ohos line has no public create-chat-room API.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  requireCiEnvironment(requirePeer: true, requireRest: true);

  final client = ChatClient.getInstance;
  final rest = CiRestFixture(
    restApi: ciRestApi,
    appKey: ciAppKey,
    appToken: ciAppToken,
  );
  final roomFixture = CiRoomFixture(rest);

  setUpAll(() async {
    await initCiClient(enableChatroomConversation: true);
    await loginForCi(client);
    roomFixture.roomId = await rest.createChatRoom(
      owner: ciUserId,
      name: 'flutter_ci_room_${DateTime.now().microsecondsSinceEpoch}',
      description: 'flutter ci room',
      members: <String>[ciPeerId],
    );
  });

  tearDownAll(() async {
    await rest.deleteChatRoom(roomFixture.roomId);
    await logoutForCi(client);
  });

  group('logged in special', () {
    registerRoomCases(client, rest, roomFixture);
    registerPushSpecialCases(client);
  });
}
