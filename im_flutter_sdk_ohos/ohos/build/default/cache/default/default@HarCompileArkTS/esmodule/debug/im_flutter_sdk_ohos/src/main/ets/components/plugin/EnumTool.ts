import type { SearchDirection, GroupPermissionType, ChatType, MessageDirection, ContentType, ReactionOperation, DownloadStatus, ConversationType, SilentModeParamType, PushRemindType, MessageStatus } from "@normalized:N&&&@easemob/chatsdk/Index&1.5.3";
// TODO: 待验证
export default class EnumTool {
    static reactionOperationToInt(operation: ReactionOperation): number {
        return operation;
    }
    static reactionOperationFromInt(iType: number): ReactionOperation {
        return iType;
    }
    static messageBodyTypeToInt(type: ContentType): number {
        return type;
    }
    static messageBodyTypeFromInt(iType: number): ContentType {
        return iType;
    }
    static messageDirectFromInt(iType: number): MessageDirection {
        return iType;
    }
    static messageDirectToInt(direct: MessageDirection): number {
        return direct;
    }
    static downloadStatusToInt(status: DownloadStatus): number {
        return status;
    }
    static downloadStatusFromInt(iStatus: number): DownloadStatus {
        return iStatus;
    }
    static chatTypeToInt(type: ChatType): number {
        return type;
    }
    static chatTypeFromInt(iType: number): ChatType {
        return iType;
    }
    static groupPermissionTypeToInt(type: GroupPermissionType): number {
        return type;
    }
    static searchDirectionToInt(direction: SearchDirection): number {
        return direction;
    }
    static searchDirectionFromInt(iDirection: number): SearchDirection {
        return iDirection;
    }
    static conversationTypeFromInt(iType: number): ConversationType {
        return iType;
    }
    static conversationTypeToInt(type: ConversationType): number {
        return type;
    }
    static silentModeParamTypeToInt(type: SilentModeParamType): number {
        return type;
    }
    static silentModeParamTypeFromInt(iType: number): SilentModeParamType {
        return iType;
    }
    static remindTypeToInt(type: PushRemindType): number {
        return type;
    }
    static remindTypeFromInt(iType: number): PushRemindType {
        return iType;
    }
    static messageStatusFromInt(iStatus: number): MessageStatus {
        return iStatus;
    }
    static messageStatusToInt(status: MessageStatus): number {
        return status;
    }
}
