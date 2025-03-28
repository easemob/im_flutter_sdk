import { ChatError } from "@easemob/chatsdk";
export default class ChatErrorHelper {
    static toJson(err: ChatError): Map<string, Object>;
    static infoToJson(code: number, desc: string): Map<string, object>;
}
