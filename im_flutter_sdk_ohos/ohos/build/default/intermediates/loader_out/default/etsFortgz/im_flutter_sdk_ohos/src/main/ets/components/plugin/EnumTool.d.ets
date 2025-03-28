import { SearchDirection, GroupPermissionType, ChatType, MessageDirection, ContentType, ReactionOperation, DownloadStatus, ConversationType, SilentModeParamType, PushRemindType, MessageStatus } from "@easemob/chatsdk";
export default class EnumTool {
    static reactionOperationToInt(operation: ReactionOperation): number;
    static reactionOperationFromInt(iType: number): ReactionOperation;
    static messageBodyTypeToInt(type: ContentType): number;
    static messageBodyTypeFromInt(iType: number): ContentType;
    static messageDirectFromInt(iType: number): MessageDirection;
    static messageDirectToInt(direct: MessageDirection): number;
    static downloadStatusToInt(status: DownloadStatus): number;
    static downloadStatusFromInt(iStatus: number): DownloadStatus;
    static chatTypeToInt(type: ChatType): number;
    static chatTypeFromInt(iType: number): ChatType;
    static groupPermissionTypeToInt(type: GroupPermissionType): number;
    static searchDirectionToInt(direction: SearchDirection): number;
    static searchDirectionFromInt(iDirection: number): SearchDirection;
    static conversationTypeFromInt(iType: number): ConversationType;
    static conversationTypeToInt(type: ConversationType): number;
    static silentModeParamTypeToInt(type: SilentModeParamType): number;
    static silentModeParamTypeFromInt(iType: number): SilentModeParamType;
    static remindTypeToInt(type: PushRemindType): number;
    static remindTypeFromInt(iType: number): PushRemindType;
    static messageStatusFromInt(iStatus: number): MessageStatus;
    static messageStatusToInt(status: MessageStatus): number;
}
