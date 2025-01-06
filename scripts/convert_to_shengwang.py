# -*- coding: utf-8 -*-
import os
import shutil

# 需要替换的关键字字典
ANDROID_REPLACE_DICT = {
    "com.hyphenate" : "io.agora",
    "EMClient" : "ChatClient",
    "EMOptions" : "ChatOptions",
    "EMCallBack" : "CallBack",
    "EMResultCallBack":"ResultCallBack",
    "EMChatRoomChangeListener" : "ChatRoomChangeListener",
    "EMClientListener" : "ChatClientListener",
    "EMConnectionListener" : "ConnectionListener",
    "EMConversationListener" : "ConversationListener",
    "EMContactListener" : "ContactListener",
    "EMError" : "Error",
    "EMGroupChangeListener" : "GroupChangeListener",
    "EMMessageListener" : "MessageListener",
    "EMMultiDeviceListener" : "MultiDeviceListener",
    "EMValueCallBack" : "ValueCallBack",
    "EMChatManager" : "ChatManager",
    "EMChatRoom" : "ChatRoom",
    "EMChatRoomManager" : "ChatRoomManager",
    "EMCheckType" : "ChatCheckType",
    "EMCmdMessageBody" : "CmdMessageBody",
    "EMContactManager" : "ContactManager",
    "EMConversation" : "Conversation",
    "EMConversationType" : "ConversationType",
    "EMSearchDirection" : "SearchDirection",
    "EMCursorResult" : "CursorResult",
    "EMCustomMessageBody" : "CustomMessageBody",

    "EMCombineMessageBody" : "CombineMessageBody",

    "EMDeviceInfo" : "DeviceInfo",
    "EMFileMessageBody" : "FileMessageBody",
    "EMGroup" : "Group",
    "EMGroupInfo" : "GroupInfo",
    "EMGroupManager" : "GroupManager",
    "EMGroupOptions" : "GroupOptions",
    "EMGroupReadAck" : "GroupReadAck",
    "EMImageMessageBody" : "ImageMessageBody",
    "EMLocationMessageBody" : "LocationMessageBody",
    "EMMessageBody" : "MessageBody",
    "EMMucSharedFile" : "MucSharedFile",
    "EMNormalFileMessageBody" : "NormalFileMessageBody",
    "EMPageResult" : "PageResult",
    "EMPushConfigs" : "PushConfigs",
    "EMPushManager" : "PushManager",
    "EMTextMessageBody" : "TextMessageBody",
    "EMUserInfo" : "UserInfo",
    "EMUserInfoType" : "UserInfoType",
    "EMUserInfoManager" : "UserInfoManager",
    "EMVideoMessageBody" : "VideoMessageBody",
    "EMVoiceMessageBody" : "VoiceMessageBody",
    "HyphenateException" : "ChatException",
    "EMPushConfig" : "PushConfig",
    "EMPushHelper" : "PushHelper",
    "EMPushType" : "PushType",
    "EMFileHelper" : "FileHelper",
    "EMGroupPermissionType" : "GroupPermissionType",
    "EMGroupStyle" : "GroupStyle",
    "EMGroupStylePrivateOnlyOwnerInvite" : "GroupStylePrivateOnlyOwnerInvite",
    "EMGroupStylePrivateMemberCanInvite" : "GroupStylePrivateMemberCanInvite",
    "EMGroupStylePublicJoinNeedApproval" : "GroupStylePublicJoinNeedApproval",
    "EMGroupStylePublicJoinNeedApproval" : "GroupStylePublicJoinNeedApproval",
    "EMChatRoomPermissionType" : "ChatRoomPermissionType",
    "EMChatService" : "ChatService",
    "EMJobService" : "ChatJobService",
    "EMMonitorReceiver" : "MonitorReceiver",
    "EMMzMsgReceiver" : "MzMsgReceiver",
    "EMVivoMsgReceiver" : "VivoMsgReceiver",

    "EMLanguage" : "Language",
    "EMTranslateParams" : "TranslateParams",
    "EMTranslationManager" : "TranslationManager",
    "EMTranslationResult" : "TranslationResult",
    "EMTranslator" : "Translator",
    "EMTranslationInfo" : "TranslationInfo",

    "EMPresence" : "Presence",
    "EMPresenceManager" : "PresenceManager",
    "EMPresenceListener" : "PresenceListener",
    "EMSilentModeParam" : "SilentModeParam",
    "EMSilentModeResult" : "SilentModeResult",
    "EMSilentModeTime" : "SilentModeTime",
    "EMPushRemindType" : "PushRemindType",
    "EMSilentModeParamType" : "SilentModeParamType",

    "EMMessageReaction":"MessageReaction",
    "EMMessageReactionChange":"MessageReactionChange",

    "EMChatThreadEvent" : "ChatThreadEvent",
    "EMChatThreadManager" : "ChatThreadManager",
    "EMChatThreadChangeListener" : "ChatThreadChangeListener",

    "EMLogListener" : "ChatLogListener",

    "EMStatisticsManager" : "ChatStatisticsManager",
    "EMMessageStatistics" : "MessageStatistics",
    "EMFetchMessageOption" : "FetchMessageOption",

    "EMContact" : "Contact",
    "EMConversationFilter" : "ConversationFilter",
    "EMMessagePinInfo" : "MessagePinInfo",

    "EMRecallMessageInfo" : "RecallMessageInfo",
    "EMLoginExtensionInfo" : "LoginExtensionInfo",
    "EMCustomConversationFilter" : "CustomConversationFilter",
    "EMMessageReactionOperation" : "MessageReactionOperation",
    "EMMessageSearchScope" : "ChatMessageSearchScope",
    "EMMessage" : "ChatMessage",
    "EMChatThread" : "ChatThread",

    # 添加更多的替换项
}

IOS_REPLACE_DICT = {
}

def replace_keywords_in_file(file_path, replace_dict):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()  # 读取文件内容

    for old_keyword, new_keyword in replace_dict.items():
        content = content.replace(old_keyword, new_keyword)  # 替换关键字

    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)  # 写回替换后的内容

def replace_keywords_in_android_directory(directory):
    print("处理android文件: {}".format(directory))
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.java'):  # 只处理Java文件
                file_path = os.path.join(root, file)
                replace_keywords_in_file(file_path, ANDROID_REPLACE_DICT)  # 替换文件内容

def replace_keywords_in_ios_directory(directory):
    print("处理ios文件: {}".format(directory))
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.m') or file.endswith('.h'):
                file_path = os.path.join(root, file)
                replace_keywords_in_file(file_path, IOS_REPLACE_DICT)  # 替换文件内容

def copy_project(original_path, new_name, ignore_patterns):
    new_path = os.path.join(os.path.dirname(original_path), new_name)
    shutil.copytree(original_path, new_path, ignore=shutil.ignore_patterns(*ignore_patterns))  # 使用传入的忽略模式
    print("项目已复制到: {}".format(new_path))  # 输出复制结果


if __name__ == "__main__":
    ignore_patterns = ['.git', '.dart_tool', 'build', '.symlinks', '.gradle', '.fvm']  # 定义忽略模式
    copy_project(os.getcwd(), 'shengwang_chat_sdk', ignore_patterns)  # 传入忽略模式
    replace_keywords_in_android_directory('android/src')
    replace_keywords_in_ios_directory('ios/Classes')
