import { ChatMessageBody, CmdMessageBody, CombineMessageBody, CustomMessageBody, FileMessageBody, ImageMessageBody, LocationMessageBody, TextMessageBody, VideoMessageBody, VoiceMessageBody } from "@easemob/chatsdk";
export default class MessageBodyHelper {
    static getParentMap(body: ChatMessageBody): Map<string, Object>;
    static textBodyFromJson(json: object): TextMessageBody;
    static textBodyToJson(body: TextMessageBody): Map<string, Object>;
    static localBodyFromJson(json: object): LocationMessageBody;
    static localBodyToJson(body: LocationMessageBody): Map<string, Object>;
    static cmdBodyFromJson(json: object): CmdMessageBody;
    static cmdBodyToJson(body: CmdMessageBody): Map<string, Object>;
    static customBodyFromJson(json: object): CustomMessageBody;
    static customBodyToJson(body: CustomMessageBody): Map<string, Object>;
    static fileBodyFromJson(json: object): FileMessageBody;
    static fileBodyToJson(body: FileMessageBody): Map<string, Object>;
    static imageBodyFromJson(json: object): ImageMessageBody;
    static imageBodyToJson(body: ImageMessageBody): Map<string, Object>;
    static videoBodyFromJson(json: object): VideoMessageBody;
    static videoBodyToJson(body: VideoMessageBody): Map<string, Object>;
    static voiceBodyFromJson(json: object): VoiceMessageBody;
    static voiceBodyToJson(body: VoiceMessageBody): Map<string, Object>;
    static combineBodyFromJson(json: object): CombineMessageBody;
    static combineBodyToJson(body: CombineMessageBody): Map<string, Object>;
}
