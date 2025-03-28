import type { MethodCallHandler } from "@normalized:N&&&@ohos/flutter_ohos/index&1.0.0-0e6b4521d4";
import Wrapper from "@normalized:N&&&im_flutter_sdk_ohos/src/main/ets/components/plugin/Wrapper&1.0.0";
import type { ChatError } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
export default class ProgressManager extends Wrapper implements MethodCallHandler {
    public sendDownloadProgressToFlutter(fileId: string, progress: number) {
        let data = new Map<string, Object>();
        data.set("fileId", fileId);
        data.set("progress", progress);
        this.channel?.invokeMethod("onProgress", data);
    }
    public sendDownloadSuccessToFlutter(fileId: string, path: string) {
        let data = new Map<string, Object>();
        data.set("fileId", fileId);
        data.set("savePath", path);
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
