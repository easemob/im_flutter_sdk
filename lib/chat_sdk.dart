// ignore_for_file: deprecated_member_use_from_same_package

library chat_sdk;

export 'src/client.dart';

export 'src/chat_manager.dart' hide MessageCallBackManager;
export 'src/thread_manager.dart';
export 'src/contact_manager.dart';
export 'src/group_manager.dart';
export 'src/room_manager.dart';
export 'src/push_manager.dart';
export 'src/userInfo_manager.dart';
export 'src/presence_manager.dart';

export 'src/models/group_message_ack.dart';
export 'src/models/chat_room.dart';
export 'src/models/conversation.dart';
export 'src/models/cursor_result.dart';
export 'src/models/contact.dart';
export 'src/models/deviceInfo.dart';
export 'src/models/error.dart';
export 'src/models/group.dart';
export 'src/models/translate_language.dart';
export 'src/models/presence.dart';
export 'src/models/login_extension_info.dart';
export 'src/models/message_search_options.dart';

export 'src/models/options.dart';
export 'src/models/push_configs.dart';
export 'src/models/page_result.dart';
export 'src/models/userInfo.dart';
export 'src/models/group_shared_file.dart';
export 'src/models/group_options.dart';
export 'src/models/fetch_message_options.dart';
export 'src/models/chat_enums.dart';
export 'src/models/reaction_operation.dart';
export 'src/models/message_pin_info.dart';

export 'src/models/message.dart';
export 'src/models/download_callback.dart';
export 'src/models/message_reaction.dart';
export 'src/models/chat_thread.dart';
export 'src/models/chat_silent_mode.dart';
export 'src/models/conversation_fetch_options.dart';
export 'src/models/recall_message_info.dart';

export 'src/event_handler/manager_event_handler.dart';
export 'src/tools/chat_area_code.dart';
