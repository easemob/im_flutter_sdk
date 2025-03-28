import { Group } from "@easemob/chatsdk";
export default class GroupHelper {
    static toJson(group: Group | null | undefined): Map<string, Object> | null;
    static listToJson(groups: Group[]): Map<string, Object>[];
}
