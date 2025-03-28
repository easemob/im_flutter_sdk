import { RecallMessageInfo } from "@easemob/chatsdk";
export default class RecallMessageInfoHelper {
    static toJson(info: RecallMessageInfo): Map<string, Object>;
    static listToJson(infos: RecallMessageInfo[]): Map<string, Object>[];
}
