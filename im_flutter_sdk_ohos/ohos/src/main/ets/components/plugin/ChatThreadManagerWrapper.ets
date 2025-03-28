import { ChatMessageListener, ChatroomListener, ConversationListener } from "@easemob/chatsdk";
import { FlutterPluginBinding, JSONMethodCodec, MethodCallHandler, MethodChannel } from "@ohos/flutter_ohos";
import Wrapper from "./Wrapper";

export default class ChatThreadManagerWrapper extends Wrapper implements MethodCallHandler {

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }
}