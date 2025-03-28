import { MethodCallHandler } from "@ohos/flutter_ohos";
import Wrapper from "./Wrapper";
import { ChatError } from "@easemob/chatsdk";
export default class ProgressManager extends Wrapper implements MethodCallHandler {
    sendDownloadProgressToFlutter(fileId: string, progress: number): void;
    sendDownloadSuccessToFlutter(fileId: string, path: string): void;
    sendDownloadErrorToFlutter(fileId: string, error: ChatError): void;
}
