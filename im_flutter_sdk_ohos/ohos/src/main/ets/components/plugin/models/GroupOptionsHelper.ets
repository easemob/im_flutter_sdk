import { GroupOptions } from "@easemob/chatsdk";
import { Any } from "@ohos/flutter_ohos";
import { GetSafetyValue, SafetyValue } from "../SafetyMapTool";

export default class GroupOptionsHelper {
  static fromJson(json: object): GroupOptions {
    let options = new GroupOptions();

    let map =  GetSafetyValue(json, "options") as Map<string, Object>;
    options.maxUsers = GetSafetyValue(map, "maxCount");
    options.inviteNeedConfirm = GetSafetyValue(map, "inviteNeedConfirm");
    options.extField = GetSafetyValue(map, "ext");
    options.style = GetSafetyValue(map, "style");

    options.groupName = GetSafetyValue(json, "groupName");
    options.members = GetSafetyValue(json, "inviteMembers");
    options.desc = GetSafetyValue(json, "desc");
    options.reason = GetSafetyValue(json, "inviteReason");

    return options;
  }
}