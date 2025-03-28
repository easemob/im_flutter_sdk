import { Group } from "@easemob/chatsdk";
import { SafetyValue } from "../SafetyMapTool";

export default class GroupHelper {
  static toJson(group: Group | null | undefined): Map<string, Object> | null {
    if(!group) {
      return null;
    }
    let data = new Map<string, Object>();
    SafetyValue(group.groupId(), (str)=>data.set("groupId", str));
    SafetyValue(group.groupName(), (str)=>data.set("name", str));
    SafetyValue(group.description(), (str)=>data.set("desc", str));
    SafetyValue(group.owner(), (str)=>data.set("owner", str));
    SafetyValue(group.announcement(), (str)=>data.set("announcement", str));
    SafetyValue(group.membersCount(), (str)=>data.set("memberCount", str));
    SafetyValue(group.members(), (str)=>data.set("memberList", str));
    SafetyValue(group.adminList(), (str)=>data.set("adminList", str));
    SafetyValue(group.blocklist(), (str)=>data.set("blockList", str));
    SafetyValue(group.mutelist(), (str)=>data.set("muteList", str));
    SafetyValue(group.isMsgBlocked(), (str)=>data.set("messageBlocked", str));
    SafetyValue(group.isDisabled(), (str)=>data.set("isDisabled", str));
    SafetyValue(group.isAllMemberMuted(), (str)=>data.set("isAllMemberMuted", str));
    SafetyValue(group.groupPermissionType(), (str)=>data.set("permissionType", str));
    SafetyValue(group.maxUserCount(), (str)=>data.set("maxUserCount", str));
    SafetyValue(group.isMemberAllowToInvite(), (str)=>data.set("isMemberAllowToInvite", str));
    // TODO:
    // SafetyStr(group.isMemberOnly(), (str)=>data.set("isMemberOnly", str));
    SafetyValue(group.extension(), (str)=>data.set("ext", str));
    return data;
  }

  static listToJson(groups: Group[]): Map<string, Object>[] {
    let list = new Array<Map<string, Object>>();
    for (let index = 0; index < groups.length; index++) {
      const group = groups[index];
      list.push(GroupHelper.toJson(group)!);
    }
    return list;
  }
}

