import { MethodCallHandler } from "@ohos/flutter_ohos";
import Wrapper from "./Wrapper";
import { ChatError } from "@easemob/chatsdk";

export default class ProgressManager extends Wrapper implements MethodCallHandler {
  public sendDownloadProgressToFlutter(fileId: string, progress: number) {
    let data = new Map<string, Object>();
    data.set("fileId", fileId);
    data.set("progress", progress)
    this.channel?.invokeMethod("onProgress", data);
  }

  public sendDownloadSuccessToFlutter(fileId: string, path: string) {
    let data = new Map<string, Object>();
    data.set("fileId", fileId);
    data.set("savePath", path)
    this.channel?.invokeMethod("onSuccess", data);
  }

  public sendDownloadErrorToFlutter(fileId: string, error: ChatError) {
    let e = new Map<string, Object>();
    e.set("code", error.errorCode);
    e.set("description", error.description);
    let data = new Map<string, Object>();
    data.set("fileId", fileId);
    data.set("error", e);
    this.channel?.invokeMethod("onError", data);
  }
}