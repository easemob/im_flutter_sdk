import { ConversationFilter, MarkType } from "@easemob/chatsdk";
import { GetSafetyValue } from "./SafetyMapTool";

export default class ConversationFilterHelper {
  static fromJson(json: Map<string, Object>): ConversationFilter {
    let filter = new ConversationFilter();
    let mark: MarkType | undefined = GetSafetyValue(json, "mark");
    if(mark != undefined) {
      filter.markType = mark;
    }

    let pageSize: number | undefined = GetSafetyValue(json, "pageSize");
    if(pageSize != undefined) {
      filter.pageSize = pageSize;
    }

    let cursor: string | undefined = GetSafetyValue(json, "cursor");
    if (cursor != undefined) {
      filter.cursor = cursor;
    }
    return filter;
  }
}