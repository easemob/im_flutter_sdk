package com.easemob.im_flutter_sdk;

import androidx.annotation.NonNull;

import com.hyphenate.chat.EMChatRoom.EMChatRoomPermissionType;
import com.hyphenate.chat.EMChatThreadEvent;
import com.hyphenate.chat.EMConversation;
import com.hyphenate.chat.EMFileMessageBody.EMDownloadStatus;
import com.hyphenate.chat.EMGroup;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMMessageReactionOperation;
import com.hyphenate.chat.EMPushManager;
import com.hyphenate.chat.EMSilentModeParam;


public class EnumTools {

    static int reactionOperationToInt(EMMessageReactionOperation.Operation operation) {
        return operation.ordinal();
    }

    static EMMessageReactionOperation.Operation reactionOperationFromInt(int iType) {
        return EMMessageReactionOperation.Operation.values()[iType];
    }

    static int threadOperationToInt(EMChatThreadEvent.TYPE type) {
        return type.ordinal();
    }

    static EMChatThreadEvent.TYPE threadOperationFromInt(int iType) {
        return EMChatThreadEvent.TYPE.values()[iType];
    }

    static int messageBodyTypeToInt(@NonNull EMMessage.Type type) {
        return type.ordinal();
    }

    static EMMessage.Direct messageDirectFromInt(int iType) {
        return EMMessage.Direct.values()[iType];
    }

    static int messageDirectToInt(@NonNull EMMessage.Direct direct) {
        return  direct.ordinal();
    }

    static EMMessage.Type messageBodyTypeFromInt(int iType) {
        return EMMessage.Type.values()[iType];
    }

    static int downloadStatusToInt(@NonNull EMDownloadStatus status) {
        return status.ordinal();
    }

    static EMDownloadStatus downloadStatusFromInt(int iStatus) {
        return  EMDownloadStatus.values()[iStatus];
    }

    static int chatTypeToInt(@NonNull EMMessage.ChatType type) {
        return  type.ordinal();
    }

    static EMMessage.ChatType chatTypeFromInt(int iType) {
        return EMMessage.ChatType.values()[iType];
    }

    static int chatRoomPermissionTypeToInt(@NonNull EMChatRoomPermissionType type) {
        return type.ordinal();
    }

    static EMChatRoomPermissionType chatRoomPermissionTypeFromInt(int iType) {
        return EMChatRoomPermissionType.values()[iType];
    }

    static int groupPermissionTypeToInt(@NonNull EMGroup.EMGroupPermissionType type) {
        return type.ordinal();
    }

    static EMGroup.EMGroupPermissionType groupPermissionTypeFromInt(int iType) {
        return EMGroup.EMGroupPermissionType.values()[iType];
    }


    static int searchDirectionToInt(EMConversation.EMSearchDirection direction) {
        return direction.ordinal();
    }

    static EMConversation.EMSearchDirection searchDirectionFromInt(int iDirection) {
        return  EMConversation.EMSearchDirection.values()[iDirection];
    }

    static EMConversation.EMConversationType conversationTypeFromInt(int iType) {
        return  EMConversation.EMConversationType.values()[iType];
    }

    static int conversationTypeToInt(EMConversation.EMConversationType type) {
        return type.ordinal();
    }

    static int silentModeParamTypeToInt(EMSilentModeParam.EMSilentModeParamType type) {
        return type.ordinal();
    }

    static EMSilentModeParam.EMSilentModeParamType silentModeParamTypeFromInt(int iType) {
        return EMSilentModeParam.EMSilentModeParamType.values()[iType];
    }


    static int remindTypeToInt(EMPushManager.EMPushRemindType type) {
        return type.ordinal();
    }

    static EMPushManager.EMPushRemindType remindTypeFromInt(int iType) {
        return EMPushManager.EMPushRemindType.values()[iType];
    }
    static EMMessage.Status messageStatusFromInt(int iStatus) {
        switch (iStatus) {
            case 0 :{
                return EMMessage.Status.CREATE;
            }
            case 1 :{
                return EMMessage.Status.INPROGRESS;
            }
            case 2 :{
                return EMMessage.Status.SUCCESS;
            }
            case 3 :{
                return EMMessage.Status.FAIL;
            }
        }
        return EMMessage.Status.FAIL;
    }

    static int messageStatusToInt(EMMessage.Status status) {
        switch (status){
            case CREATE:
                return 0;
            case INPROGRESS:
                return 1;
            case SUCCESS:
                return 2;
            case FAIL:
                return 3;
        }
        return 3;
    }
 }
