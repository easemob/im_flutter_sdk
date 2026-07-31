import 'package:flutter_test/flutter_test.dart';
import 'package:im_flutter_test/protocol/response_normalizer.dart';

void main() {
  test('normalizes native method result without changing the request envelope',
      () {
    final response = ResponseNormalizer.success(
      {
        'id': '1',
        'sequence': 2,
        'manager': 'ContactManager',
        'cmd': 'addContact',
        'device': 'deviceA',
        'info': {'userId': 'bob'},
      },
      {
        'addContact': 'bob',
      },
    );

    expect(response['result'], 'bob');
    expect(response['manager'], 'ContactManager');
    expect(response.containsKey('info'), isFalse);
  });

  test('keeps SDK business errors in the compatible result field', () {
    final response = ResponseNormalizer.success(
      {
        'manager': 'ContactManager',
        'cmd': 'addContact',
      },
      {
        'error': {'code': 204, 'description': 'User does not exist'},
      },
    );

    expect(response['result'], {
      'code': 204,
      'description': 'User does not exist',
    });
  });

  test('normalizes managed requests into exactly one response envelope', () {
    final response = ResponseNormalizer.success(
      {
        'type': 'request',
        'protocolVersion': 1,
        'runId': 'run-1',
        'caseId': 'case-1',
        'requestId': 'req-1',
        'id': 'req-1',
        'manager': 'Client',
        'cmd': 'login',
        'info': {'userId': 'alice'},
      },
      {'login': 'alice'},
    );

    expect(response['type'], 'response');
    expect(response['requestId'], 'req-1');
    expect(response['success'], isTrue);
    expect(response['result'], 'alice');
    expect(response.containsKey('info'), isFalse);
  });
}
