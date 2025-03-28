import { SharedFile } from "@easemob/chatsdk";
export default class SharedFileHelper {
    static toJson(file: SharedFile): Map<string, Object>;
    static listToJson(files: SharedFile[]): Map<string, Object>[];
}
