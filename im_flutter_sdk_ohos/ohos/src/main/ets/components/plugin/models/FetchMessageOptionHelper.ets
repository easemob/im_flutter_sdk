import { FetchMessageOption, ContentType } from "@easemob/chatsdk";
import EnumTool from "../EnumTool";
import { GetSafetyValue } from "../SafetyMapTool";


export default class FetchMessageOptionHelper {
  static fromJson(json: object | undefined | null): FetchMessageOption | undefined{
    if(!json) {
      return undefined;
    }
    let ret = new FetchMessageOption();
    ret.setDirection(GetSafetyValue(json, "direction"));
    ret.setIsSave(GetSafetyValue(json, "needSave"));
    ret.setStartTime(GetSafetyValue(json, "startTs"));
    ret.setEndTime(GetSafetyValue(json, "endTs"));
    let from : undefined | string = GetSafetyValue(json, "from");
    if(from != undefined) {
      ret.setFrom(from);
    }
    let typeList: Array<number> | undefined;
    typeList = GetSafetyValue(json, "msgTypes");
    if(typeList != undefined) {
      let types = new Array<ContentType>();
      for (let index = 0; index < typeList.length; index++) {
        const element = typeList[index];
        types.push(EnumTool.messageBodyTypeFromInt(element));
      }
      ret.setMsgTypes(types);
    }
    return ret;
  }
}