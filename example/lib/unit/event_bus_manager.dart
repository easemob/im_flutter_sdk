import 'package:event_bus/event_bus.dart';

EventBus eventBus = new EventBus();

class EventBusManager {
  static const String updateConversaitonsList = 'UpdateConversaitonsList';

  String eventKey;
  EventBusManager(this.eventKey);

  /// 更新会话通知
  EventBusManager.updateConversations() {
    eventKey = updateConversaitonsList;
  }
}
