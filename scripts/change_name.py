# -*- coding: utf-8 -*-
import argparse  # 导入 argparse 模块用于命令行参数解析
import os
import shutil
import re

AGORA_CHAT_PACKAGE = "agora_chat_sdk"
SHENGWANG_CHAT_PACKAGE = "shengwang_chat_sdk"
CHAT_PACKAGE = "im_flutter_sdk"
IOS_DIR = "ios"
SDK_PUBSPEC_FILE = "pubspec.yaml"
EXAMPLE_DIR = "example"

EXAMPLE_MAIN_FILE = f"{EXAMPLE_DIR}/lib/main.dart"
EXAMPLE_PUBSPEC_FILE = f"{EXAMPLE_DIR}/{SDK_PUBSPEC_FILE}"
EXAMPLE_IOS_APP_DELEGATE_FILE = f"{EXAMPLE_DIR}/{IOS_DIR}/Runner/AppDelegate.swift"

IOS_PODSPEC_FILE = f"{IOS_DIR}/{CHAT_PACKAGE}.podspec"
AGORA_CHAT_IOS_PODSPEC_FILE = f"{IOS_DIR}/{AGORA_CHAT_PACKAGE}.podspec"
SHENGWANG_CHAT_IOS_PODSPEC_FILE = f"{IOS_DIR}/{SHENGWANG_CHAT_PACKAGE}.podspec"
ANDROID_FILE_PATH = "android/src/main/java/com/easemob/im_flutter_sdk"


SHENGWANG_ANDROID_MAP = {
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


AGORA_CHAT_MAP = {
    "import 'package:im_flutter_sdk/im_flutter_sdk.dart'":"import 'package:agora_chat_sdk/agora_chat_sdk.dart'",
    "EMOptions":"ChatOptions",
    "EMClient":"ChatClient",
    "EMConnectionEventHandler":"ConnectionEventHandler",
    "EMChatEventHandler":"ChatEventHandler",
    "EMTextMessageBody":"ChatTextMessageBody",
    "EMError":"ChatError",
    "EMMessage":"ChatMessage",
}

SHENGWANG_CHAT_MAP = {
    "import 'package:im_flutter_sdk/im_flutter_sdk.dart'":"import 'package:shengwang_chat_sdk/shengwang_chat_sdk.dart'",
    "EMOptions":"ChatOptions",
    "EMClient":"ChatClient",
    "EMConnectionEventHandler":"ConnectionEventHandler",
    "EMChatEventHandler":"ChatEventHandler",
    "EMTextMessageBody":"ChatTextMessageBody",
    "EMError":"ChatError",
    "EMMessage":"ChatMessage",
}



def copy_file_to_target_path(source_path, type):

    if not os.path.exists(source_path):
        print(f"source path: {source_path} not exist")
        return

    if type == "agorachat":
        target_path = os.path.join(os.getcwd(), AGORA_CHAT_PACKAGE)

    if type == "shengwang":
        target_path = os.path.join(os.getcwd(), SHENGWANG_CHAT_PACKAGE)

    if type == "easemob":
        target_path = os.path.join(os.getcwd(), CHAT_PACKAGE)

    os.makedirs(target_path, exist_ok=True)
    # 复制文件
    if os.path.isfile(source_path):
        if not source_path.startswith('.'):
            shutil.copy2(source_path, target_path)
    elif os.path.isdir(source_path):
        def ignore_patterns(src, names):
            # 排除以点开头的文件和 build 目录
            return [n for n in names if n.startswith('.') or n == 'build' or n == 'doc' or n ==  'Pods' or n == 'scripts']

        shutil.copytree(source_path, target_path, dirs_exist_ok=True, ignore=ignore_patterns)

    if type == "agorachat":
        change_agorachat_name(target_path)

    if type == "shengwang":
        change_shengwang_name(target_path)

    if type == "easemob":
        create_easemob_path(target_path)


def change_agorachat_name(path):
    change_sdk_pubspec_file(path, AGORA_CHAT_PACKAGE)
    change_example_main_file(path, AGORA_CHAT_PACKAGE, AGORA_CHAT_MAP)
    change_example_pubspec_file(path, AGORA_CHAT_PACKAGE)
    change_ios_podspec_file(path, AGORA_CHAT_PACKAGE)
    choice_api_reference_language(path, "english")
    lib_dir = os.path.join(path, 'lib')
    if os.path.exists(lib_dir):
        for file_name in ['im_flutter_sdk.dart', 'shengwang_chat_sdk.dart']:
            file_path = os.path.join(lib_dir, file_name)
            if os.path.isfile(file_path):
                os.remove(file_path)  # 删除文件

def change_shengwang_name(path):
    change_sdk_pubspec_file(path, SHENGWANG_CHAT_PACKAGE)
    change_example_main_file(path, SHENGWANG_CHAT_PACKAGE, SHENGWANG_CHAT_MAP)
    change_example_pubspec_file(path, SHENGWANG_CHAT_PACKAGE)
    change_ios_podspec_file(path, SHENGWANG_CHAT_PACKAGE)
    switch_ios_import_header(path)
    chang_android_import_header(path, SHENGWANG_ANDROID_MAP)
    choice_api_reference_language(path, "chinese")
    lib_dir = os.path.join(path, 'lib')
    if os.path.exists(lib_dir):
        for file_name in ['agora_chat_sdk.dart', 'im_flutter_sdk.dart']:
            file_path = os.path.join(lib_dir, file_name)
            if os.path.isfile(file_path):
                os.remove(file_path)  # 删除文件

def create_easemob_path(path):
    choice_api_reference_language(path, "chinese")
    lib_dir = os.path.join(path, 'lib')
    if os.path.exists(lib_dir):
        for file_name in ['agora_chat_sdk.dart', 'shengwang_chat_sdk.dart']:
            file_path = os.path.join(lib_dir, file_name)
            if os.path.isfile(file_path):
                os.remove(file_path)  # 删除文件


# 修改 pubspec.yaml 文件中的 package 名称
def change_sdk_pubspec_file(path, package_name: str):
    yaml_file = os.path.join(path, SDK_PUBSPEC_FILE)

    # 读取 yaml 文件内容
    with open(yaml_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 查找并替换 name: 后面的内容
    lines = content.split('\n')
    new_lines = []
    for line in lines:
        if line.strip().startswith('name:'):
            new_lines.append(f'name: {package_name}')
        else:
            new_lines.append(line)

    # 写回文件
    with open(yaml_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(new_lines))

# 处理 example 目录下的 EM前缀为Map中的前缀
def change_example_main_file(path, package_name: str, chat_map: dict[str:str]):
    example_main_file = os.path.join(path, EXAMPLE_MAIN_FILE)
    if os.path.exists(example_main_file):
        with open(example_main_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # 使用 AGORA_CHAT_MAP 进行替换
        for old_text, new_text in chat_map.items():
            content = content.replace(old_text, new_text)

        with open(example_main_file, 'w', encoding='utf-8') as f:
            f.write(content)

    app_delegate_file = os.path.join(path, EXAMPLE_IOS_APP_DELEGATE_FILE)
    if os.path.exists(app_delegate_file):
        # 读取并修改文件内容
        with open(app_delegate_file, 'r', encoding='utf-8') as f:
            content = f.read()
        # 替换依赖名称
        content = content.replace(CHAT_PACKAGE, package_name)
                    # 写回文件
        with open(app_delegate_file, 'w', encoding='utf-8') as f:
            f.write(content)


# 处理 example 的 pubspec.yaml 文件
def change_example_pubspec_file(path, package_name: str):
    example_pubspec = os.path.join(path, EXAMPLE_PUBSPEC_FILE)
    if os.path.exists(example_pubspec):
        with open(example_pubspec, 'r', encoding='utf-8') as f:
            content = f.read()

        # 替换依赖名称
        content = content.replace(CHAT_PACKAGE, package_name)

        # 写回文件
        with open(example_pubspec, 'w', encoding='utf-8') as f:
            f.write(content)

def change_ios_podspec_file(path, package_name: str):

    old_podspec = os.path.join(path, IOS_PODSPEC_FILE)
    new_podspec = os.path.join(path, f"{IOS_DIR}/{package_name}.podspec")

    if os.path.exists(old_podspec):
        # 重命名 podspec 文件
        os.rename(old_podspec, new_podspec)

        # 读取并修改文件内容
        with open(new_podspec, 'r', encoding='utf-8') as f:
            content = f.read()

        # 替换 podspec 名称
        content = content.replace(CHAT_PACKAGE, package_name)
        # 写回文件
        with open(new_podspec, 'w', encoding='utf-8') as f:
            f.write(content)

        #TODO: 修改引入的包路径

def switch_ios_import_header(path):
    header_file = os.path.join(path, f"{IOS_DIR}/Classes/ChatHeaders.h")
    if os.path.exists(header_file):
        # 读取并修改文件内容
        with open(header_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # 查找并替换 name: 后面的内容
            lines = content.split('\n')
            new_lines = []
            for line in lines:
                if line.strip().startswith('#define AgoraChat'):
                    new_lines.append(f'#define AgoraChat 1')
                else:
                    new_lines.append(line)

            # 写回文件
            with open(header_file, 'w', encoding='utf-8') as f:
                f.write('\n'.join(new_lines))

def chang_android_import_header(path, chat_map: dict[str:str]):
    directory = os.path.join(path, ANDROID_FILE_PATH)
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.java'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as file:
                    content = file.read()  # 读取文件内容
                    for old_keyword, new_keyword in chat_map.items():
                        content = content.replace(old_keyword, new_keyword)  # 替换关键字

                    with open(file_path, 'w', encoding='utf-8') as file:
                        file.write(content)  # 写回替换后的内容


def choice_api_reference_language(path, language: str = "chinese"):
    '''
    修改目录下所有 dart 文件中注释的内容
    '''
    # 遍历目录下的所有文件
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()

                if language == "english":
                    # 只保留 ~english 到 ~end 的内容
                    content = remove_chinese_comments(content)
                elif language == "chinese":
                    # 只保留 ~chinese 到 ~end 的内容
                    content = remove_english_comments(content)
 
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)

def remove_english_comments(content: str) -> str:
    # 移除中文注释和两侧的标记
    new_str = re.sub(r'/// ~english.*?/// ~end', '', content, flags=re.DOTALL)
    new_str = new_str.replace(' ~chinese', '').replace(' ~end', '')
    return new_str

def remove_chinese_comments(content: str) -> str:
    # 移除英文注释和两侧的标记
    new_str = re.sub(r'/// ~chinese.*?/// ~end', '', content, flags=re.DOTALL)
    new_str = new_str.replace(' ~english', '').replace(' ~end', '')
    return new_str


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="改名工具")
    # directory 作为位置参数，默认就是必传的
    parser.add_argument('path', help='需要修改的目录路径')
    # type 通过 required=True 设置为必传参数
    parser.add_argument('--type', choices=['agorachat', 'shengwang', 'easemob'],
                       required=True, help='固定参数选项：agorachat 或 shengwang 或 easemob')

    # 解析命令行参数
    args = parser.parse_args()
    copy_file_to_target_path(args.path, args.type)



