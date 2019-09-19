
import 'package:flutter_test/flutter_test.dart';

import '../lib/im_flutter_sdk.dart';

void main() {
  // setup EMClient
    EMOptions options = EMOptions(appKey: 'easemob#im_demo');
    EMClient client = EMClient.getInstance();
  
  setUp(() {
    client.init(options);
  });

  test('client listeners get called once migrate to 2x',
  () {
    
  });

  tearDown(() {
   
  });
}
