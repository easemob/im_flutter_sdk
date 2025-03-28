import { ChatMessageBody, CmdMessageBody,
  CombineMessageBody,
  CombineMessageParams,
  CustomMessageBody,
  FileMessageBody,
  ImageMessageBody,
  LocationMessageBody, TextMessageBody,
  VideoMessageBody,
  VoiceMessageBody,
  ContentType,
} from "@easemob/chatsdk";
import { Any } from "@ohos/flutter_ohos";
import EnumTool from "../EnumTool";
import { GetSafetyValue, IsObj, ObjToMap, SafetyValue } from "../SafetyMapTool";

export default  class MessageBodyHelper {
  static getParentMap(body: ChatMessageBody): Map<string, Object> {
    let data = new Map<string, Object>();
    if(body.type() == ContentType.TXT ){
      SafetyValue(body.operatorId(), (value)=>data.set("operatorId", value));
      SafetyValue(body.operationCount(), (value)=>data.set("operatorCount", value));
      SafetyValue(body.operationTime(), (value)=>data.set("operatorTime", value));
    }
    data.set("type", EnumTool.messageBodyTypeToInt(body.type()));
    return data;
  }


  static textBodyFromJson(json: object): TextMessageBody {
    let content = GetSafetyValue(json, "content") as string;
    // TODO: 鸿蒙暂不支持翻译
    let ret = new TextMessageBody(content);
    return ret;
  }

  static textBodyToJson(body: TextMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.getParentMap(body);
    data.set("content", body.getContent());
    return data;
  }

  static localBodyFromJson(json: object): LocationMessageBody {
    let latitude = GetSafetyValue(json, "latitude") as number;
    let longitude = GetSafetyValue(json, "longitude") as number;
    let ret = new LocationMessageBody(
      latitude,
      longitude,
      GetSafetyValue(json, "address"),
      GetSafetyValue(json, "buildingName")
    );
    return ret;
  }

  static localBodyToJson(body: LocationMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.getParentMap(body);
    SafetyValue(body.getLatitude(),(value)=> data.set("latitude", value));
    SafetyValue(body.getLongitude(),(value)=> data.set("longitude", value));
    SafetyValue(body.getAddress(),(value)=> data.set("address", value));
    SafetyValue(body.getBuildingName(),(value)=> data.set("buildingName", value));
    return data;
  }

  static cmdBodyFromJson(json: object): CmdMessageBody {
    let action = GetSafetyValue(json, "action") as string;
    let ret = new CmdMessageBody(action);
    return ret;
  }

  static cmdBodyToJson(body: CmdMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.getParentMap(body);
    SafetyValue(body.action(), (value)=>data.set("action", value));
    return data;
  }

  static customBodyFromJson(json: object): CustomMessageBody {
    let event = GetSafetyValue(json, "event") as string;
    let ret = new CustomMessageBody(event);
    let obj : Any = GetSafetyValue(json, "params");
    if(IsObj(obj)) {
      ret.setParams(ObjToMap(obj));
    }
    return ret;
  }

  static customBodyToJson(body: CustomMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.getParentMap(body);
    SafetyValue(body.event(), (value)=>data.set("event", value));
    SafetyValue(body.getParams(), (value)=>data.set("params", value));
    return data;
  }

  static fileBodyFromJson(json: object): FileMessageBody {
    let localPath = GetSafetyValue(json, "localPath") as string;
    let ret = new FileMessageBody(localPath);
    ret.setFileName(GetSafetyValue(json, "displayName"));
    ret.setRemoteUrl(GetSafetyValue(json, "remotePath"));
    ret.setSecretKey(GetSafetyValue(json, "secret"));
    ret.setDownloadStatus(EnumTool.downloadStatusFromInt(GetSafetyValue(json, "fileStatus")!));
    ret.setFileLength(GetSafetyValue(json, "fileSize"));
    return ret;
  }

  static fileBodyToJson(body: FileMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.getParentMap(body);
    SafetyValue(body.getLocalPath(), (value)=>data.set("localPath", value));
    SafetyValue(body.getFileLength(), (value)=>data.set("fileSize", value));
    SafetyValue(body.getFileName(), (value)=>data.set("displayName", value));
    SafetyValue(body.getRemoteUrl(), (value)=>data.set("remotePath", value));
    SafetyValue(body.getSecretKey(), (value)=>data.set("secret", value));
    SafetyValue(body.getDownloadStatus(), (value)=>data.set("fileStatus", EnumTool.downloadStatusToInt(value)));
    return data;
  }

  static imageBodyFromJson(json: object): ImageMessageBody {
    let localPath = GetSafetyValue(json, "localPath") as string;
    let ret = new ImageMessageBody(localPath);
    ret.setFileName(GetSafetyValue(json, "displayName"));
    ret.setRemoteUrl(GetSafetyValue(json, "remotePath"));
    ret.setSecretKey(GetSafetyValue(json, "secret"));
    ret.setThumbnailLocalPath(GetSafetyValue(json, "thumbnailLocalPath"));
    ret.setThumbnailRemoteUrl(GetSafetyValue(json, "thumbnailRemotePath"));
    ret.setThumbnailDownloadStatus(GetSafetyValue(json, "thumbnailStatus"));
    ret.setDownloadStatus(EnumTool.downloadStatusFromInt(GetSafetyValue(json, "fileStatus")!));
    ret.setFileLength(GetSafetyValue(json, "fileSize"));
    ret.setSize(GetSafetyValue(json, "width"), GetSafetyValue(json, "height"));
    // 不支持发送原图参数，所以不添加
    // GetSafetyValue(json, "sendOriginalImage")
    return ret;
  }

  static imageBodyToJson(body: ImageMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.getParentMap(body);
    SafetyValue(body.getLocalPath(), (value)=>data.set("localPath", value));
    SafetyValue(body.getFileName(), (value)=>data.set("displayName", value));
    SafetyValue(body.getRemoteUrl(), (value)=>data.set("remotePath", value));
    SafetyValue(body.getSecretKey(), (value)=>data.set("secret", value));
    SafetyValue(body.getDownloadStatus(), (value)=>data.set("fileStatus", EnumTool.downloadStatusToInt(value)));
    SafetyValue(body.getThumbnailLocalPath(), (value)=>data.set("thumbnailLocalPath", value));
    SafetyValue(body.getThumbnailRemoteUrl(), (value)=>data.set("thumbnailRemotePath", value));
    SafetyValue(body.getSecretKey(), (value)=>data.set("thumbnailSecret", value));
    SafetyValue(body.getThumbnailDownloadStatus(), (value)=>data.set("thumbnailStatus", EnumTool.downloadStatusToInt(value)));
    SafetyValue(body.getHeight(), (value)=>data.set("height", value));
    SafetyValue(body.getWidth(), (value)=>data.set("width", value));
    SafetyValue(body.getFileLength(), (value)=>data.set("fileSize", value));
    // 不支持原图参数，默认为true
    data.set("sendOriginalImage", true);
    return data;
  }

  static videoBodyFromJson(json: object): VideoMessageBody {
    let localPath = GetSafetyValue(json, "localPath") as string;
    let ret = new VideoMessageBody(localPath, 10);
    ret.setDuration(GetSafetyValue(json, "duration"));
    ret.setThumbnailRemoteUrl(GetSafetyValue(json, "thumbnailRemotePath"));
    ret.setThumbnailLocalPath(GetSafetyValue(json, "thumbnailLocalPath"));
    ret.setThumbnailSecret(GetSafetyValue(json, "thumbnailSecret"));
    ret.setThumbnailDownloadStatus(EnumTool.downloadStatusFromInt(GetSafetyValue(json, "thumbnailStatus")! as number))
    ret.setFileName(GetSafetyValue(json, "displayName"));
    ret.setRemoteUrl(GetSafetyValue(json, "remotePath"));
    ret.setSecretKey(GetSafetyValue(json, "secret"));
    ret.setFileLength(GetSafetyValue(json, "fileSize"));
    ret.setDownloadStatus(EnumTool.downloadStatusFromInt(GetSafetyValue(json, "fileStatus")! as number));
    ret.setThumbnailSize(GetSafetyValue(json, "width"), GetSafetyValue(json, "height"))

    return ret;
  }

  static videoBodyToJson(body: VideoMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.getParentMap(body);
    SafetyValue(body.getLocalPath(), (value)=>data.set("localPath", value));
    SafetyValue(body.getThumbnailLocalPath(), (value)=>data.set("thumbnailLocalPath", value));
    SafetyValue(body.getDuration(), (value)=>data.set("duration", value));
    SafetyValue(body.getThumbnailRemoteUrl(), (value)=>data.set("thumbnailRemotePath", value));
    SafetyValue(body.getThumbnailSecret(), (value)=>data.set("thumbnailSecret", value));
    SafetyValue(body.getThumbnailDownloadStatus(), (value)=>data.set("thumbnailStatus", EnumTool.downloadStatusToInt(value)));
    SafetyValue(body.getFileName(), (value)=>data.set("displayName", value));
    SafetyValue(body.getThumbnailHeight(), (value)=>data.set("height", value));
    SafetyValue(body.getThumbnailWidth(), (value)=>data.set("width", value));
    SafetyValue(body.getRemoteUrl(), (value)=>data.set("remotePath", value));
    SafetyValue(body.getDownloadStatus(), (value)=>data.set("fileStatus", EnumTool.downloadStatusToInt(value)));
    SafetyValue(body.getSecretKey(), (value)=>data.set("secret", value));
    SafetyValue(body.getFileLength(), (value)=>data.set("fileSize", value));

    return data;
  }

  static voiceBodyFromJson(json: object): VoiceMessageBody {
    let localPath = GetSafetyValue(json, "localPath") as string;
    let ret = new VoiceMessageBody(localPath, 10);
    ret.setDuration(GetSafetyValue(json, "duration"));
    ret.setDownloadStatus(EnumTool.downloadStatusFromInt(GetSafetyValue(json, "fileStatus")! as number));
    ret.setFileName(GetSafetyValue(json, "displayName"));
    ret.setSecretKey(GetSafetyValue(json, "secret"));
    ret.setRemoteUrl(GetSafetyValue(json, "remotePath"));
    ret.setFileLength(GetSafetyValue(json, "fileSize"));

    return ret;
  }

  static voiceBodyToJson(body: VoiceMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.getParentMap(body);
    SafetyValue(body.getLocalPath(), (value)=>data.set("localPath", value));
    SafetyValue(body.getDuration(), (value)=>data.set("duration", value));
    SafetyValue(body.getFileName(), (value)=>data.set("displayName", value));
    SafetyValue(body.getRemoteUrl(), (value)=>data.set("remotePath", value));
    SafetyValue(body.getDownloadStatus(), (value)=>data.set("fileStatus", EnumTool.downloadStatusToInt(value)));
    SafetyValue(body.getSecretKey(), (value)=>data.set("secret", value));
    SafetyValue(body.getFileLength(), (value)=>data.set("fileSize", value));

    return data;
  }

  static combineBodyFromJson(json: object): CombineMessageBody {
    let ret = new CombineMessageBody(new CombineMessageParams());
    ret.setTitle(GetSafetyValue(json, "title"));
    ret.setSummary(GetSafetyValue(json, "summary"));
    ret.setCompatibleText(GetSafetyValue(json, "compatibleText"));
    ret.setLocalPath(GetSafetyValue(json, "localPath"));
    ret.setRemoteUrl(GetSafetyValue(json, "remotePath"));
    ret.setSecretKey(GetSafetyValue(json, "secret"));
    ret.setMessageList(GetSafetyValue(json, "messageList"));
    ret.setDownloadStatus(EnumTool.downloadStatusFromInt(GetSafetyValue(json, "fileStatus")! as number));
    return ret;
  }

  static combineBodyToJson(body: CombineMessageBody): Map<string, Object> {
    let data = MessageBodyHelper.getParentMap(body);
    SafetyValue(body.getTitle(), (value)=>data.set("title", value));
    SafetyValue(body.getSummary(), (value)=>data.set("summary", value));
    SafetyValue(body.getCompatibleText(), (value)=>data.set("compatibleText", value));
    SafetyValue(body.getLocalPath(), (value)=>data.set("localPath", value));
    SafetyValue(body.getRemoteUrl(), (value)=>data.set("remotePath", value));
    SafetyValue(body.getSecretKey(), (value)=>data.set("secret", value));
    SafetyValue(body.getDownloadStatus(), (value)=>data.set("fileStatus", EnumTool.downloadStatusToInt(value)));

    return data;
  }
}

