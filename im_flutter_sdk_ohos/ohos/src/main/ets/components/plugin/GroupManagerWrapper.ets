import { ChatClient,
  ChatError, Group, GroupListener, SharedFile,
 } from "@easemob/chatsdk";
import { Any, FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodResult } from "@ohos/flutter_ohos";
import ClientWrapper from "./ClientWrapper";
import MethodKey from "./MethodKeys";
import CursorResultHelper from "./models/CursorResultHelper";
import GroupHelper from "./models/GroupHelper";
import GroupOptionsHelper from "./models/GroupOptionsHelper";
import SharedFileHelper from "./models/SharedFileHelper";
import { IsObj, ObjToMap } from "./SafetyMapTool";
import Wrapper from "./Wrapper";

export default class GroupManagerWrapper extends Wrapper implements MethodCallHandler {
  private listener: GroupListener | undefined;
  public clientWrapper: ClientWrapper | null = null;

  constructor(binding: FlutterPluginBinding, channelName: string) {
    super(binding, channelName);
  }

  registerEaseListener() {
    this.unRegisterEaseListener();
    let weakRef = new WeakRef(this);
    this.listener = {
      onWhitelistAdded(groupId, whitelist) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupWhiteListAdded");
        data.set("groupId", groupId);
        data.set("whitelist", whitelist);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onWhitelistRemoved(groupId, whitelist) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupWhiteListRemoved");
        data.set("groupId", groupId);
        data.set("whitelist", whitelist);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onAllMemberMuteStateChanged(groupId, isMuted) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupAllMemberMuteStateChanged");
        data.set("groupId", groupId);
        data.set("isMuted", isMuted);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onInvitationReceived(groupId, groupName, inviter, reason){
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupInvitationReceived");
        data.set("groupId", groupId);
        data.set("groupName", groupName);
        data.set("inviter", inviter);
        data.set("reason", reason);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onRequestToJoinReceived(groupId: string, groupName: string, applicant: string, reason: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupRequestToJoinReceived");
        data.set("groupId", groupId);
        data.set("groupName", groupName);
        data.set("applicant", applicant);
        data.set("reason", reason);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onRequestToJoinAccepted(groupId: string, groupName: string, accepter: string){
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupRequestToJoinAccepted");
        data.set("groupId", groupId);
        data.set("groupName", groupName);
        data.set("accepter", accepter);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onRequestToJoinDeclined(groupId: string, _: string, decliner: string, applicant: string, reason: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupRequestToJoinDeclined");
        data.set("groupId", groupId);
        data.set("applicant", applicant);
        data.set("decliner", decliner);
        data.set("reason", reason);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onInvitationAccepted(groupId: string, invitee: string, reason: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupInvitationAccepted");
        data.set("groupId", groupId);
        data.set("invitee", invitee);
        data.set("reason", reason);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onInvitationDeclined(groupId: string, invitee: string, reason: string){
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupInvitationDeclined");
        data.set("groupId", groupId);
        data.set("invitee", invitee);
        data.set("reason", reason);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onUserRemoved(groupId: string, groupName: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupUserRemoved");
        data.set("groupId", groupId);
        data.set("groupName", groupName);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onGroupDestroyed(groupId: string, groupName: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupDestroyed");
        data.set("groupId", groupId);
        data.set("groupName", groupName);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onAutoAcceptInvitationFromGroup(groupId: string, inviter: string, inviteMessage: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupAutoAcceptInvitation");
        data.set("groupId", groupId);
        data.set("inviter", inviter);
        data.set("inviteMessage", inviteMessage);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onMutelistAdded(groupId: string, mutes: string[], muteExpire: number) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupMuteListAdded");
        data.set("groupId", groupId);
        data.set("mutes", mutes);
        data.set("muteExpire", muteExpire);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onMutelistRemoved(groupId: string, mutes: string[]) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupMuteListRemoved");
        data.set("groupId", groupId);
        data.set("mutes", mutes);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onAdminAdded(groupId: string, administrator: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupAdminAdded");
        data.set("groupId", groupId);
        data.set("administrator", administrator);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onAdminRemoved(groupId: string, administrator: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupAdminRemoved");
        data.set("groupId", groupId);
        data.set("administrator", administrator);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onOwnerChanged(groupId: string, newOwner: string, oldOwner: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupOwnerChanged");
        data.set("groupId", groupId);
        data.set("newOwner", newOwner);
        data.set("oldOwner", oldOwner);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onMemberJoined(groupId: string, member: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupMemberJoined");
        data.set("groupId", groupId);
        data.set("member", member);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onMemberExited(groupId: string, member: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupMemberExited");
        data.set("groupId", groupId);
        data.set("member", member);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onAnnouncementChanged(groupId: string, announcement: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupAnnouncementChanged");
        data.set("groupId", groupId);
        data.set("announcement", announcement);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onSharedFileAdded(groupId: string, sharedFile: SharedFile) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupSharedFileAdded");
        data.set("groupId", groupId);
        data.set("sharedFile", SharedFileHelper.toJson(sharedFile));
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onSharedFileDeleted(groupId: string, fileId: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupSharedFileDeleted");
        data.set("groupId", groupId);
        data.set("fileId", fileId);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onSpecificationChanged(group) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupSpecificationDidUpdate");
        data.set("group", GroupHelper.toJson(group)!);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onStateChanged(group: Group, isDisabled: boolean) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupStateChanged");
        data.set("groupId", group.groupId());
        data.set("isDisabled", isDisabled);
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
      onGroupMemberAttributeChanged(groupId: string, member: string, attributes: Map<string, string>, from: string) {
        let retrievedObject = weakRef.deref();
        let data = new Map<string, Object>();
        data.set("type", "onGroupAttributesChangedOfMember");
        data.set("groupId", groupId);
        data.set("userId", member);
        if (from != null) {
          data.set("operatorId", from);
        }
        if (attributes != null) {
          data.set("attributes", attributes);
        }
        retrievedObject?.channel?.invokeMethod(MethodKey.onGroupChanged, data);
      },
    }

    ChatClient.getInstance().groupManager()?.addListener(this.listener);
  }

  unRegisterEaseListener() {
    if(this.listener != null) {
      ChatClient.getInstance().groupManager()?.removeListener(this.listener);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (MethodKey.getGroupWithId == call.method) {
      this.getGroupWithId(call, result);
    } else if (MethodKey.getJoinedGroups == call.method) {
      this.getJoinedGroups(call, result);
    } else if (MethodKey.getJoinedGroupsFromServer == call.method) {
      this.getJoinedGroupsFromServer(call, result);
    } else if (MethodKey.getPublicGroupsFromServer == call.method) {
      this.getPublicGroupsFromServer(call, result);
    } else if (MethodKey.createGroup == call.method) {
      this.createGroup(call, result);
    } else if (MethodKey.getGroupSpecificationFromServer == call.method) {
      this.getGroupSpecificationFromServer(call, result);
    } else if (MethodKey.getGroupMemberListFromServer == call.method) {
      this.getGroupMemberListFromServer(call, result);
    } else if (MethodKey.getGroupMuteListFromServer == call.method) {
      this.getGroupMuteListFromServer(call, result);
    } else if (MethodKey.getGroupWhiteListFromServer == call.method) {
      this.getGroupWhiteListFromServer(call, result);
    } else if (MethodKey.isMemberInWhiteListFromServer == call.method) {
      this.isMemberInWhiteListFromServer(call, result);
    } else if (MethodKey.getGroupFileListFromServer == call.method) {
      this.getGroupFileListFromServer(call, result);
    } else if (MethodKey.getGroupAnnouncementFromServer == call.method) {
      this.getGroupAnnouncementFromServer(call, result);
    } else if (MethodKey.getGroupBlockListFromServer == call.method) {
      this.getGroupBlockListFromServer(call, result);
    } else if (MethodKey.addMembers == call.method) {
      this.addMembers(call, result);
    } else if (MethodKey.inviterUser == call.method){
      this.inviterUser(call, result);
    } else if (MethodKey.removeMembers == call.method) {
      this.removeMembers(call, result);
    } else if (MethodKey.blockMembers == call.method) {
      this.blockMembers(call, result);
    } else if (MethodKey.unblockMembers == call.method) {
      this.unblockMembers(call, result);
    } else if (MethodKey.updateGroupSubject == call.method) {
      this.updateGroupSubject(call, result);
    } else if (MethodKey.updateDescription == call.method) {
      this.updateDescription(call, result);
    } else if (MethodKey.leaveGroup == call.method) {
      this.leaveGroup(call, result);
    } else if (MethodKey.destroyGroup == call.method) {
      this.destroyGroup(call, result);
    } else if (MethodKey.blockGroup == call.method) {
      this.blockGroup(call, result);
    } else if (MethodKey.unblockGroup == call.method) {
      this.unblockGroup(call, result);
    } else if (MethodKey.updateGroupOwner == call.method) {
      this.updateGroupOwner(call, result);
    } else if (MethodKey.addAdmin == call.method) {
      this.addAdmin(call, result);
    } else if (MethodKey.removeAdmin == call.method) {
      this.removeAdmin(call, result);
    } else if (MethodKey.muteMembers == call.method) {
      this.muteMembers(call, result);
    } else if (MethodKey.unMuteMembers == call.method) {
      this.unMuteMembers(call, result);
    } else if (MethodKey.muteAllMembers == call.method) {
      this.muteAllMembers(call, result);
    } else if (MethodKey.unMuteAllMembers == call.method) {
      this.unMuteAllMembers(call, result);
    } else if (MethodKey.addWhiteList == call.method) {
      this.addWhiteList(call, result);
    } else if (MethodKey.removeWhiteList == call.method) {
      this.removeWhiteList(call, result);
    } else if (MethodKey.uploadGroupSharedFile == call.method) {
      this.uploadGroupSharedFile(call, result);
    } else if (MethodKey.downloadGroupSharedFile == call.method) {
      this.downloadGroupSharedFile(call, result);
    } else if (MethodKey.removeGroupSharedFile == call.method) {
      this.removeGroupSharedFile(call, result);
    } else if (MethodKey.updateGroupAnnouncement == call.method) {
      this.updateGroupAnnouncement(call, result);
    } else if (MethodKey.updateGroupExt == call.method) {
      this.updateGroupExt(call, result);
    } else if (MethodKey.joinPublicGroup == call.method) {
      this.joinPublicGroup(call, result);
    } else if (MethodKey.requestToJoinPublicGroup == call.method) {
      this.requestToJoinPublicGroup(call, result);
    } else if (MethodKey.acceptJoinApplication == call.method) {
      this.acceptJoinApplication(call, result);
    } else if (MethodKey.declineJoinApplication == call.method) {
      this.declineJoinApplication(call, result);
    } else if (MethodKey.acceptInvitationFromGroup == call.method) {
      this.acceptInvitationFromGroup(call, result);
    } else if (MethodKey.declineInvitationFromGroup == call.method) {
      this.declineInvitationFromGroup(call, result);
    } else if (MethodKey.setMemberAttributesFromGroup == call.method) {
      this.setMemberAttributes(call, result);
    } else if (MethodKey.removeMemberAttributesFromGroup == call.method) {
      this.removeMemberAttributes(call, result);
    } else if (MethodKey.fetchMemberAttributesFromGroup == call.method) {
      this.fetchMemberAttributes(call, result);
    } else if (MethodKey.fetchMembersAttributesFromGroup == call.method) {
      this.fetchMembersAttributes(call, result);
    } else if (MethodKey.fetchJoinedGroupCount == call.method) {
      this.fetchJoinedGroupCount(call, result);
    } else if (MethodKey.clearAllGroupsFromDB == call.method) {
      this.clearAllGroupsFromDB(call, result);
    } else if (MethodKey.isMemberInGroupMuteList == call.method) {
      this.isMemberInGroupMuteList(call, result);
    } else {
      super.onMethodCall(call, result);
    }
  }

  private getGroupWithId(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let group = ChatClient.getInstance().groupManager()?.getGroup(groupId);
    if(group != null) {
      this.onSuccess(result, call.method, GroupHelper.toJson(group));
    }else {
      this.onSuccess(result, call.method);
    }
  }

  private getJoinedGroups(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().groupManager()?.getAllGroups()
      .then((groups)=>{
        this.onSuccess(result, call.method, GroupHelper.listToJson(groups));
      })
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getJoinedGroupsFromServer(call: MethodCall, result: MethodResult) {
    let pageSize = call.argument("pageSize") as number;
    let pageNum = call.argument("pageNum") as number;
    ChatClient.getInstance().groupManager()?.fetchJoinedGroupsFromServer(pageSize, pageNum)
      .then((groups)=>{
        this.onSuccess(result, call.method, GroupHelper.listToJson(groups));
      })
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getPublicGroupsFromServer(call: MethodCall, result: MethodResult) {
    let pageSize = call.argument("pageSize") as number;
    let cursor: string | null = null;
    if(call.hasArgument("cursor")) {
      cursor = call.argument("cursor");
    }

    ChatClient.getInstance().groupManager()?.fetchPublicGroupsFromServer(pageSize, cursor)
      .then((value)=>this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private createGroup(call: MethodCall, result: MethodResult) {
    let options = GroupOptionsHelper.fromJson(call.args);
    ChatClient.getInstance().groupManager()?.createGroup(options)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getGroupSpecificationFromServer(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.fetchGroupFromServer(groupId)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private getGroupMemberListFromServer(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let cursor: string | undefined;
    if(call.hasArgument("cursor")) {
      cursor = call.argument("cursor");
    }
    let pageSize = call.argument("pageSize") as number;

    ChatClient.getInstance().groupManager()?.fetchGroupMembers(groupId, pageSize, cursor)
      .then((value)=>this.onSuccess(result, call.method, CursorResultHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private getGroupMuteListFromServer(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let pageSize = call.argument("pageSize") as number;
    let pageNum = call.argument("pageNum") as number;
    ChatClient.getInstance().groupManager()?.fetchGroupMutelist(groupId, pageNum, pageSize)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private getGroupWhiteListFromServer(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.fetchGroupWhitelist(groupId)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private isMemberInWhiteListFromServer(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.checkIfInGroupWhitelist(groupId)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private getGroupFileListFromServer(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let pageSize = call.argument("pageSize") as number;
    let pageNum = call.argument("pageNum") as number;
    ChatClient.getInstance().groupManager()?.fetchGroupSharedFileList(groupId, pageNum, pageSize)
      .then(value=>this.onSuccess(result, call.method, SharedFileHelper.listToJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private getGroupAnnouncementFromServer(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.fetchGroupAnnouncement(groupId)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private getGroupBlockListFromServer(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let pageSize = call.argument("pageSize") as number;
    let pageNum = call.argument("pageNum") as number;
    ChatClient.getInstance().groupManager()?.fetchGroupBlocklist(groupId, pageNum, pageSize)
      .then(value=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private addMembers(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let members = call.argument("members") as Array<string>;
    let welcome: string | undefined;
    if(call.hasArgument("welcome")) {
      welcome = call.argument("welcome");
    }
    ChatClient.getInstance().groupManager()?.addUsersToGroup(groupId, members, welcome)
      .then(value=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private inviterUser(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let members = call.argument("members") as Array<string>;
    let reason: string | undefined;
    if(call.hasArgument("reason")) {
      reason = call.argument("reason");
    }
    ChatClient.getInstance().groupManager()?.inviteUsers(groupId, members, reason)
      .then(value=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private removeMembers(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().groupManager()?.removeUsersFromGroup(groupId, members)
      .then(value=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private blockMembers(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().groupManager()?.blockUsers(groupId, members)
      .then(value=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private unblockMembers(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().groupManager()?.unblockUsers(groupId, members)
      .then(value=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private updateGroupSubject(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let name = call.argument("name") as string;
    ChatClient.getInstance().groupManager()?.changeGroupName(groupId, name)
      .then(value=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private updateDescription(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let desc = call.argument("desc") as string;
    ChatClient.getInstance().groupManager()?.changeGroupDescription(groupId, desc)
      .then(value=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private leaveGroup(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.leaveGroup(groupId)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private destroyGroup(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.destroyGroup(groupId)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private blockGroup(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.blockGroupMessage(groupId)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private unblockGroup(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.unblockGroupMessage(groupId)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private updateGroupOwner(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let owner = call.argument("owner") as string;
    ChatClient.getInstance().groupManager()?.changeOwner(groupId, owner)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private addAdmin(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let admin = call.argument("admin") as string;
    ChatClient.getInstance().groupManager()?.addGroupAdmin(groupId, admin)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private removeAdmin(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let admin = call.argument("admin") as string;
    ChatClient.getInstance().groupManager()?.removeGroupAdmin(groupId, admin)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private muteMembers(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let members = call.argument("members") as Array<string>;
    let duration = call.argument("duration") as number;
    ChatClient.getInstance().groupManager()?.muteGroupMembers(groupId, members, duration)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private unMuteMembers(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().groupManager()?.unmuteGroupMembers(groupId, members)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private muteAllMembers(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.muteAllMembers(groupId)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private unMuteAllMembers(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.unmuteAllMembers(groupId)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private addWhiteList(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().groupManager()?.addToGroupWhitelist(groupId, members)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private removeWhiteList(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let members = call.argument("members") as Array<string>;
    ChatClient.getInstance().groupManager()?.removeFromGroupWhitelist(groupId, members)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private uploadGroupSharedFile(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let filePath = call.argument("filePath") as string;
    let weakRef = new WeakRef(this);
    ChatClient.getInstance().groupManager()?.uploadGroupSharedFile(groupId, filePath)
      .then((_)=>this.onSuccess(result, call.method, true))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private downloadGroupSharedFile(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let fileId = call.argument("fileId") as string;
    let savePath = call.argument("savePath") as string;
    let weakRef = new WeakRef(this);
    ChatClient.getInstance().groupManager()?.downloadGroupSharedFile(groupId, fileId, savePath, {
      onSuccess(){
        let retrievedObject = weakRef.deref();
        retrievedObject?.clientWrapper?.progressManager?.sendDownloadSuccessToFlutter(fileId, savePath);
      },
      onProgress(progress) {
        let retrievedObject = weakRef.deref();
        retrievedObject?.clientWrapper?.progressManager?.sendDownloadProgressToFlutter(fileId, progress);
      },
      onError(code, desc){
        let retrievedObject = weakRef.deref();
        retrievedObject?.clientWrapper?.progressManager?.sendDownloadErrorToFlutter(fileId, new ChatError(code, desc));
      },
    }).then(()=>this.onSuccess(result, call.method));
  }
  private removeGroupSharedFile(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let fileId = call.argument("fileId") as string;
    ChatClient.getInstance().groupManager()?.deleteGroupSharedFile(groupId, fileId)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private updateGroupAnnouncement(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let announcement = call.argument("announcement") as string;
    ChatClient.getInstance().groupManager()?.updateGroupAnnouncement(groupId, announcement)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private updateGroupExt(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let ext = call.argument("ext") as string;
    ChatClient.getInstance().groupManager()?.updateGroupExtension(groupId, ext)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private joinPublicGroup(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.joinGroup(groupId)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private requestToJoinPublicGroup(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let reason: string | undefined;
    if(call.hasArgument("reason")) {
      reason = call.argument("reason");
    }

    ChatClient.getInstance().groupManager()?.applyJoinToGroup(groupId, reason)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private acceptJoinApplication(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let username = call.argument("username") as string;
    ChatClient.getInstance().groupManager()?.acceptApplication(groupId, username)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }


  private declineJoinApplication(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let username = call.argument("username") as string;
    let reason: string | undefined;
    if(call.hasArgument("reason")) {
      reason = call.argument("reason");
    }
    ChatClient.getInstance().groupManager()?.declineApplication(groupId, username, reason)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private acceptInvitationFromGroup(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.acceptInvitation(groupId)
      .then((value)=>this.onSuccess(result, call.method, GroupHelper.toJson(value)))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private declineInvitationFromGroup(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let reason: string | undefined;
    if(call.hasArgument("reason")) {
      reason = call.argument("reason");
    }
    ChatClient.getInstance().groupManager()?.declineInvitation(groupId, reason)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }
  private setMemberAttributes(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let userId = call.argument("userId") as string;
    let map = ObjToMap(call.argument("attributes"))
    ChatClient.getInstance().groupManager()?.setMemberAttributes(groupId, userId, map)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private removeMemberAttributes(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let userId: string| undefined;
    if(call.hasArgument("userId")) {
      userId = call.argument("userId") as string;
    }else {
      userId = ChatClient.getInstance().getCurrentUser();
    }
    let keys = call.argument("keys") as Array<string>;
    let map = new Map<string, string>();
    for (let index = 0; index < keys.length; index++) {
      const key= keys[index];
      map.set(key, "");
    }
    ChatClient.getInstance().groupManager()?.setMemberAttributes(groupId, userId, map)
      .then(()=>this.onSuccess(result, call.method))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private fetchMemberAttributes(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let userId: string| undefined;
    if(call.hasArgument("userId")) {
      userId = call.argument("userId") as string;
    }else {
      userId = ChatClient.getInstance().getCurrentUser();
    }
    ChatClient.getInstance().groupManager()?.fetchMemberAttributes(groupId, userId)
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private fetchMembersAttributes(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    let userIds = call.argument("userIds") as Array<string>;

    ChatClient.getInstance().groupManager()?.fetchMembersAttributes(groupId, userIds)
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private fetchJoinedGroupCount(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().groupManager()?.fetchJoinedGroupsCount()
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }

  private clearAllGroupsFromDB(call: MethodCall, result: MethodResult) {
    ChatClient.getInstance().groupManager()?.clearAllLocalGroups()
    this.onSuccess(result, call.method);
  }

  private isMemberInGroupMuteList(call: MethodCall, result: MethodResult) {
    let groupId = call.argument("groupId") as string;
    ChatClient.getInstance().groupManager()?.checkIfInGroupMutelist(groupId)
      .then((value)=>this.onSuccess(result, call.method, value))
      .catch((e: ChatError) => this.onError(result, e));
  }
}