import { ChatClient, ChatError, ChatroomListener } from "@easemob/chatsdk";
import { FlutterPluginBinding,
 MethodCall,
 MethodCallHandler,
 MethodResult } from "@ohos/flutter_ohos";
import MethodKey from "./MethodKeys";
import ChatRoomHelper from "./models/ChatRoomHelper";
import CursorResultHelper from "./models/CursorResultHelper";
import PageResultHelper from "./models/PageResultHelper";
import { GetSafetyValue, ObjToMap } from "./SafetyMapTool";
import Wrapper from "./Wrapper";

export default class ChatRoomManagerWrapper extends Wrapper implements MethodCallHandler {
  private listener: ChatroomListener | undefined;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.joinChatRoom == call.method) {
      this.joinChatRoom(call, result);
    } else if (MethodKey.leaveChatRoom == call.method) {
      this.leaveChatRoom(call, result);
    } else if (MethodKey.fetchPublicChatRoomsFromServer == call.method) {
      this.fetchPublicChatRoomsFromServer(call, result);
    } else if (MethodKey.fetchChatRoomInfoFromServer == call.method) {
      this.fetchChatRoomInfoFromServer(call, result);
    } else if (MethodKey.getChatRoom == call.method) {
      this.getChatRoom(call, result);
    } else if (MethodKey.getAllChatRooms == call.method) {
      this.getAllChatRooms(call, result);
    } else if (MethodKey.createChatRoom == call.method) {
      this.createChatRoom(call, result);
    } else if (MethodKey.destroyChatRoom == call.method) {
      this.destroyChatRoom(call, result);
    } else if (MethodKey.changeChatRoomSubject == call.method) {
      this.changeChatRoomSubject(call, result);
    } else if (MethodKey.changeChatRoomDescription == call.method) {
      this.changeChatRoomDescription(call, result);
    } else if (MethodKey.fetchChatRoomMembers == call.method) {
      this.fetchChatRoomMembers(call, result);
    } else if (MethodKey.muteChatRoomMembers == call.method) {
      this.muteChatRoomMembers(call, result);
    } else if (MethodKey.unMuteChatRoomMembers == call.method) {
      this.unMuteChatRoomMembers(call, result);
    } else if (MethodKey.changeChatRoomOwner == call.method) {
      this.changeChatRoomOwner(call, result);
    } else if (MethodKey.addChatRoomAdmin == call.method) {
      this.addChatRoomAdmin(call, result);
    } else if (MethodKey.removeChatRoomAdmin == call.method) {
      this.removeChatRoomAdmin(call, result);
    } else if (MethodKey.fetchChatRoomMuteList == call.method) {
      this.fetchChatRoomMuteList(call, result);
    } else if (MethodKey.removeChatRoomMembers == call.method) {
      this.removeChatRoomMembers(call, result);
    } else if (MethodKey.blockChatRoomMembers == call.method) {
      this.blockChatRoomMembers(call, result);
    } else if (MethodKey.unBlockChatRoomMembers == call.method) {
      this.unBlockChatRoomMembers(call, result);
    } else if (MethodKey.fetchChatRoomBlockList == call.method) {
      this.fetchChatRoomBlockList(call, result);
    } else if (MethodKey.updateChatRoomAnnouncement == call.method) {
      this.updateChatRoomAnnouncement(call, result);
    } else if (MethodKey.fetchChatRoomAnnouncement == call.method) {
      this.fetchChatRoomAnnouncement(call, result);
    } else if (MethodKey.addMembersToChatRoomWhiteList == call.method) {
      this.addMembersToChatRoomWhiteList(call, result);
    } else if (MethodKey.removeMembersFromChatRoomWhiteList == call.method) {
      this.removeMembersFromChatRoomWhiteList(call, result);
    } else if (MethodKey.isMemberInChatRoomWhiteListFromServer == call.method) {
      this.isMemberInChatRoomWhiteListFromServer(call, result);
    } else if (MethodKey.fetchChatRoomWhiteListFromServer == call.method) {
      this.fetchChatRoomWhiteListFromServer(call, result);
    } else if (MethodKey.muteAllChatRoomMembers == call.method) {
      this.muteAllChatRoomsMembers(call, result);
    } else if (MethodKey.unMuteAllChatRoomMembers == call.method) {
      this.unMuteAllChatRoomsMembers(call, result);
    } else if (MethodKey.fetchChatRoomAttributes == call.method) {
      this.fetchChatRoomAttributes(call, result);
    } else if (MethodKey.setChatRoomAttributes == call.method) {
      this.setChatRoomAttributes(call, result);
    } else if (MethodKey.removeChatRoomAttributes == call.method) {
      this.removeChatRoomAttributes(call, result);
    } else {
      super.onMethodCall(call, result);
    }

  }

  private joinChatRoom(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let ext = call.argument("ext") as string;
    let leaveOther = GetSafetyValue(call.args, "leaveOtherRooms") as boolean;
    ChatClient.getInstance().chatroomManager()?.joinChatroom(roomId, leaveOther, ext)
      .then((value)=>this.onSuccess(result, call.method, ChatRoomHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private leaveChatRoom(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    ChatClient.getInstance().chatroomManager()?.leaveChatroom(roomId);
    this.onSuccess(result, call.method);
  }

  private fetchPublicChatRoomsFromServer(call: MethodCall, result: MethodResult) {

    const pageSize = call.argument('pageSize') as number;
    const pageNum = call.argument('pageNum') as number;
    ChatClient.getInstance().chatroomManager()?.fetchPublicChatroomsFromServer(pageNum, pageSize)
      .then((value) => this.onSuccess(result, call.method, PageResultHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));

  }

  private fetchChatRoomInfoFromServer(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  private getChatRoom(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  private getAllChatRooms(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  private createChatRoom(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  private destroyChatRoom(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  private changeChatRoomSubject(call: MethodCall, result: MethodResult) {
    this.noSupport(result);
  }

  private changeChatRoomDescription(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let description = call.argument("description") as string;
    ChatClient.getInstance().chatroomManager()?.changeChatroomDescription(roomId,description)
      .then((room) => this.onSuccess(result, call.method, ChatRoomHelper.toJson(room)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private fetchChatRoomMembers(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let cursor: string | null = null;
    if (call.hasArgument("cursor")){
      cursor = call.argument("cursor");
    }
    let pageSize = call.argument("pageSize") as number;
    let finalCursor = cursor;
    ChatClient.getInstance().chatroomManager()?.fetchChatroomMembers(roomId, finalCursor, pageSize)
      .then((cursorResult) => this.onSuccess(result, call.method, CursorResultHelper.toJson(cursorResult)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private muteChatRoomMembers(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let duration: number| undefined = GetSafetyValue(call.args, "duration");
    let muteMembers: Array<string> = GetSafetyValue(call.args, "muteMembers")!;
    ChatClient.getInstance().chatroomManager()?.muteChatroomMembers(roomId, muteMembers, duration)
      .then((room) => this.onSuccess(result, call.method, ChatRoomHelper.toJson(room)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private unMuteChatRoomMembers(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let unMuteMembersList: Array<string> = GetSafetyValue(call.args, "unMuteMembers")!;
    ChatClient.getInstance().chatroomManager()?.unmuteChatroomMembers(roomId, unMuteMembersList)
      .then((room) => this.onSuccess(result, call.method, ChatRoomHelper.toJson(room)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private changeChatRoomOwner(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let newOwner = call.argument("newOwner") as string;
    ChatClient.getInstance().chatroomManager()?.changeChatroomOwner(roomId, newOwner)
      .then((room) => this.onSuccess(result, call.method, ChatRoomHelper.toJson(room)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private addChatRoomAdmin(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let admin = call.argument("admin") as string;

    ChatClient.getInstance().chatroomManager()?.addChatroomAdmin(roomId, admin)
      .then((room) => this.onSuccess(result, call.method, ChatRoomHelper.toJson(room)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private removeChatRoomAdmin(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let admin = call.argument("admin") as string;

    ChatClient.getInstance().chatroomManager()?.removeChatroomAdmin(roomId, admin)
      .then((room) => this.onSuccess(result, call.method, ChatRoomHelper.toJson(room)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private fetchChatRoomMuteList(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    const pageSize = call.argument('pageSize') as number;
    const pageNum = call.argument('pageNum') as number;
    ChatClient.getInstance().chatroomManager()?.fetchChatroomMutes(roomId, pageNum, pageSize)
      .then((room) => this.onSuccess(result, call.method, Array.from(room.keys())))
      .catch((e: ChatError) => this.onError(result, e));
  }

  ///
  private removeChatRoomMembers(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().chatroomManager()?.removeChatroomMembers(roomId, members)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private blockChatRoomMembers(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().chatroomManager()?.blockChatroomMembers(roomId, members)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private unBlockChatRoomMembers(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().chatroomManager()?.unblockChatroomMembers(roomId, members)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private fetchChatRoomBlockList(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let pageSize = call.argument("pageSize") as number;
    let pageNum = call.argument("pageNum") as number;
    ChatClient.getInstance().chatroomManager()?.fetchChatroomBlocklist(roomId, pageSize, pageNum)
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private updateChatRoomAnnouncement(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let announcement = call.argument("announcement") as string;
    ChatClient.getInstance().chatroomManager()?.changeChatroomAnnouncement(roomId, announcement)
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private fetchChatRoomAnnouncement(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    ChatClient.getInstance().chatroomManager()?.fetchChatroomAnnouncement(roomId)
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private addMembersToChatRoomWhiteList(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().chatroomManager()?.addToChatroomWhitelist(roomId, members)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private removeMembersFromChatRoomWhiteList(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().chatroomManager()?.removeFromChatroomWhitelist(roomId, members)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private isMemberInChatRoomWhiteListFromServer(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    ChatClient.getInstance().chatroomManager()?.checkIfInWhitelist(roomId)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private fetchChatRoomWhiteListFromServer(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    ChatClient.getInstance().chatroomManager()?.fetchChatroomWhitelist(roomId)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private muteAllChatRoomsMembers(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    ChatClient.getInstance().chatroomManager()?.muteAllMembers(roomId)
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private unMuteAllChatRoomsMembers(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    ChatClient.getInstance().chatroomManager()?.unmuteAllMembers(roomId)
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  fetchChatRoomAttributes(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let userId: string| undefined;
    if(call.hasArgument("userId")) {
      userId = call.argument("userId") as string;
    }else {
      userId = ChatClient.getInstance().getCurrentUser();
    }
    ChatClient.getInstance().chatroomManager()?.fetchChatroomAttributes(roomId, userId)
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  setChatRoomAttributes(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().chatroomManager()?.setChatroomAttributes({
      chatroomId: GetSafetyValue(call.args, "roomId") ?? "",
      attributeKeyOrMap: ObjToMap(call.argument("attributes")),
      attributeValue:GetSafetyValue(call.args, "attributeValue") ?? "true",
      autoDelete:GetSafetyValue(call.args, "autoDelete") ?? true,
      isForced:GetSafetyValue(call.args, "forced") ?? false,
    })
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }
  removeChatRoomAttributes(call: MethodCall, result: MethodResult) {
    let roomId = call.argument("roomId") as string;
    let keys = call.argument("keys") as Array<string>;
    ChatClient.getInstance().chatroomManager()?.removeChatroomAttributes({
      chatroomId: roomId,
      attributeKey: keys,
      isForced: GetSafetyValue(call.args, "forced") ?? false
    })
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  //注册监听事件
  public registerEaseListener(): void {
    let weakRef = new WeakRef(this);
    this.unRegisterEaseListener();
    this.listener = {
      //
      onWhitelistAdded(chatRoomId: string, whitelist: string[]) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomWhiteListAdded");
        data.set("roomId", chatRoomId);
        data.set("whitelist", whitelist);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onWhitelistRemoved(chatRoomId: string, whitelist: string[]) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomWhiteListRemoved");
        data.set("roomId", chatRoomId);
        data.set("whitelist", whitelist);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onAllMemberMuteStateChanged(chatRoomId: string, isMuted: boolean) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomAllMemberMuteStateChanged");
        data.set("roomId", chatRoomId);
        data.set("isMuted", isMuted);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      onMemberJoined(roomId: string, participant: string, ext: string|undefined) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomMemberJoined");
        data.set("roomId", roomId);
        data.set("participant", participant);
        if(ext != null) {
          data.set("ext", ext);
        }
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onMemberExited(roomId: string, roomName: string, participant: string,) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomMemberExited");
        data.set("roomId", roomId);
        data.set("roomName", roomName);
        data.set("participant", participant);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onRemovedFromChatroom(reason: number, roomId: string, roomName: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomRemovedFromChatRoom");
        data.set("reason", reason);
        data.set("roomId", roomId);
        data.set("roomName", roomName);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onMutelistAdded(chatRoomId: string, mutes: Array<string>, expireTime: number) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomMuteListAdded");
        data.set("roomId", chatRoomId);
        data.set("mutes", mutes);
        data.set("expireTime", expireTime);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onMuteMapAdded(chatRoomId: string, mutes: Map<string, number>) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomMuteListAdded");
        data.set("roomId", chatRoomId);
        data.set("mutes", mutes);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onMutelistRemoved(chatRoomId: string, mutes: string[]) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomMuteListRemoved");
        data.set("roomId", chatRoomId);
        data.set("mutes", mutes);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      onAdminAdded(chatRoomId: string, admin: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomAdminAdded");
        data.set("roomId", chatRoomId);
        data.set("admin", admin);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onAdminRemoved(chatRoomId: string, admin: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomAdminRemoved");
        data.set("roomId", chatRoomId);
        data.set("admin", admin);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onOwnerChanged(chatRoomId: string, newOwner: string, oldOwner: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomOwnerChanged");
        data.set("roomId", chatRoomId);
        data.set("newOwner", newOwner);
        data.set("oldOwner", oldOwner);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      //
      onAnnouncementChanged(chatRoomId: string, announcement: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomAnnouncementChanged");
        data.set("roomId", chatRoomId);
        data.set("announcement", announcement);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      ///---
      onSpecificationChanged(room) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomSpecificationChanged");
        data.set("room", ChatRoomHelper.toJson(room)!);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      ///---
      onAttributesUpdate(chatRoomId: string, attributeMap: Map<string, string>, from: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomAttributesDidUpdated");
        data.set("roomId", chatRoomId);
        data.set("attributes", attributeMap);
        data.set("fromId", from);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
      onAttributesRemoved(chatRoomId: string, keyList: string[], from: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onRoomAttributesDidRemoved");
        data.set("roomId", chatRoomId);
        data.set("keys", keyList);
        data.set("from", from);
        retrievedObject?.channel?.invokeMethod(MethodKey.chatRoomChange, data);
      },
    }
    ChatClient.getInstance().chatroomManager()?.addListener(this.listener);
  }
  public unRegisterEaseListener(): void {
    if(this.listener != null) {
      ChatClient.getInstance().chatroomManager()?.removeListener(this.listener);
    }
  }
}