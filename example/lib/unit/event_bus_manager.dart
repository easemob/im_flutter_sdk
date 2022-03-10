import 'package:event_bus/event_bus.dart';

EventBus eventBus = new EventBus();

class EventBusManager {
  static const String updateConversationsList = 'updateConversationsList';

  String eventKey;
  EventBusManager(this.eventKey);

  /// 更新会话通知
  static updateConversations() {
    EventBusManager(updateConversationsList);
  }
}
