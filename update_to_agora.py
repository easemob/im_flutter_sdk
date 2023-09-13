#!/usr/bin/python
# -*- coding: UTF-8 -*-
import os
import shutil
import re
import sys
import getopt

# 使用方法
# python update_to_agora.py -s testApplication -t agora-brand
# 执行上述命令，指定要复制的文件夹和目标文件夹的名字
#
# 修改 FOLDER_dict中的字符串用作文件路径的修改
# 修改 UPDATE_dict中的字符串用作文件中内容的修改
# walkFile 中判断文件后缀名，按需要修改
#


def main(argv):
    sourcePath = ''
    targetPath = ''

    try:
        opts, args = getopt.getopt(
            argv[1:], "-h-s:-t:", ["source=", "target="])

    except getopt.GetoptError:
        print 'update_to_agora.py -s <source> -t <target>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'update_to_agora.py -s <source> -t <target>'
            sys.exit()
        if opt in ("-s", "--source"):
            sourcePath = arg
            print 'source folder: ', sourcePath
        if opt in ("-t", "--target"):
            targetPath = arg
            print 'target folder: ', targetPath

    if(sourcePath == '' or targetPath == ''):
        print 'need source and target path.'
        return

    # 当前文件路径
    # print(os.path.realpath(__file__))
    # 当前文件所在的目录，即父路径
    currentFolder = os.path.split(os.path.realpath(__file__))[0]
    # print(os.path.split(os.path.realpath(__file__))[0])
    sourcePath = currentFolder + "/" + sourcePath
    targetPath = currentFolder + "/" + targetPath

    print 'target folder: ', targetPath

    if sourcePath == '' or targetPath == '':
        print "missing source or target"
        sys.exit(2)

    copyFolder(sourcePath, targetPath)

    #oldName = outputfile + "/app/src"
    renameFolder(targetPath)
    walkFile(targetPath)


# 需要修改的文件夹名
FOLDER_dict = {
    
}

# 修改文件夹名称


def renameFolder(folderName):
    print 'renameFolder: ' + folderName
    # 修改文件夹名
    for parent, dirnames, filenames in os.walk(folderName, topdown=False):

        for filename in filenames:
            file_ext = filename.rsplit('.', 1)
            if len(file_ext) != 2:
                continue
            changeFileName(parent, filename)

        for dirname in dirnames:
            pathdir = os.path.join(parent, dirname)
            for k in FOLDER_dict.keys():
                if dirname == k:
                    print 'rename: ' + pathdir
                    os.renames(pathdir, pathdir.replace(k, FOLDER_dict.get(k)))


# 需要修改的文件名
FILE_dict = {
    "im_flutter_sdk.iml":"agora_chat_sdk.iml",

    # /lib/
    "im_flutter_sdk.dart":"agora_chat_sdk.dart",

    # /lib/src/
    "em_client.dart":"chat_client.dart",
    "em_contact_manager.dart":"chat_contact_manager.dart",
    "em_group_manager.dart":"chat_group_manager.dart",
    "em_listeners.dart":"chat_listeners.dart",
    "em_chat_manager.dart":"chat_manager.dart",
    "em_push_manager.dart":"chat_push_manager.dart",
    "em_chat_room_manager.dart":"chat_room_manager.dart",
    "em_userInfo_manager.dart":"chat_userInfo_manager.dart",
    "em_chat_manager_moderation_plugin.dart":"chat_manager_moderation_plugin.dart",
    "em_chat_manager_reaction_plugin.dart":"chat_manager_reaction_plugin.dart",
    "em_chat_manager_transform_plugin.dart":"chat_manager_transform_plugin.dart",
    "em_chat_thread_manager.dart":"chat_thread_manager.dart",
    "em_message_status_callback.dart":"chat_message_status_callback.dart",
    "em_presence_manager.dart":"chat_presence_manager.dart",
    "em_status_listener.dart":"chat_status_listener.dart",

    # /lib/src/internal
    "em_sdk_method.dart":"chat_method_keys.dart",
    "em_push_config.dart":"chat_push_config.dart",
    "em_channel_manager.dart":"chat_channel_manager.dart",
    "em_event_keys.dart":"chat_event_keys.dart",
    "em_transform_tools.dart":"chat_transform_tools.dart",
    
    
    # /lib/src/models/
    "em_conversation.dart":"chat_conversation.dart",
    "em_cursor_result.dart":"chat_cursor_result.dart",
    "em_deviceInfo.dart":"chat_deviceInfo.dart",
    "em_chat_enums.dart":"chat_enums.dart",
    "em_error.dart":"chat_error.dart",
    "em_group_message_ack.dart":"chat_group_message_ack.dart",
    "em_group_options.dart":"chat_group_options.dart",
    "em_group.dart":"chat_group.dart",
    "em_message.dart":"chat_message.dart",
    "em_options.dart":"chat_options.dart",
    "em_page_result.dart":"chat_page_result.dart",
    "em_push_configs.dart":"chat_push_configs.dart",
    "em_chat_room.dart":"chat_room.dart",
    "em_userInfo.dart":"chat_userInfo.dart",
    "em_group_shared_file.dart":"chat_group_shared_file.dart",
    "em_chat_thread_event.dart":"chat_thread_event.dart",
    "em_chat_thread.dart":"chat_thread.dart",
    "em_cmd_message_body.dart":"chat_cmd_message_body.dart",
    "em_custom_message_body.dart":"chat_custom_message_body.dart",
    "em_download_callback.dart":"chat_download_callback.dart",
    "em_file_message_body.dart":"chat_file_message_body.dart",
    "em_group_info.dart":"chat_group_info.dart",
    "em_image_message_body.dart":"chat_image_message_body.dart",
    "em_location_message_body.dart":"chat_location_message_body.dart",
    "em_message_body.dart":"chat_message_body.dart",
    "em_message_reaction_change.dart":"chat_message_reaction_change.dart",
    "em_message_reaction.dart":"chat_message_reaction.dart",
    "em_presence.dart":"chat_presence.dart",
    "em_text_message_body.dart":"chat_text_message_body.dart",
    "em_translate_language.dart":"chat_translate_language.dart",
    "em_video_message_body.dart":"chat_video_message_body.dart",
    "em_voice_message_body.dart":"chat_voice_message_body.dart",
    "em_domain_terms.dart":"chat_domain_terms.dart",
    
    
    # /lib/src/tools/
    "em_extension.dart":"chat_extension.dart",
    "em_log.dart":"chat_log.dart",
    "em_progress_manager.dart":"chat_progress_manager.dart",

    # /ios/
    "im_flutter_sdk.podspec":"agora_chat_sdk.podspec"
}


def changeFileName(parent, filename):
    pathdir = os.path.join(parent, filename)
    for k in FILE_dict.keys():
        if filename == k:
            value = FILE_dict.get(k)
            print '%-40s' % filename + value
            os.renames(pathdir, pathdir.replace(k, value))


# 遍历文件夹
def walkFile(file):
    print 'begin walkFile'
    total_yaml_num = 0
    total_gradle_num = 0
    total_dart_num = 0
    total_podspec_num = 0
    total_md_num = 0

    for root, dirs, files in os.walk(file):

        # root 表示当前正在访问的文件夹路径
        # dirs 表示该文件夹下的子目录名list
        # files 表示该文件夹下的文件list

        # 遍历文件
        for f in files:
            #print(os.path.join(root, f))
            file_path = os.path.join(root, f)
            file_ext = file_path.rsplit('.', 1)
            if len(file_ext) != 2:
                # 没有后缀名
                continue
            if file_ext[1] == 'yaml' or file_ext[1] == 'gradle' or file_ext[1] == 'dart' or file_ext[1] == 'podspec' or file_ext[1] == 'md':
                if file_ext[1] == 'yaml':
                    total_yaml_num += 1
                if file_ext[1] == 'gradle':
                    total_gradle_num += 1
                if file_ext[1] == 'dart':
                    total_dart_num += 1
                if file_ext[1] == 'podspec':
                    total_podspec_num += 1
                if file_ext[1] == 'md':
                    total_md_num += 1

                fullname = os.path.join(root, f)
                updateFile(fullname)
                reBackFile(fullname)


        # 遍历所有的文件夹
        # for d in dirs:
        #    print(os.path.join(root, d))

    print 'total .yaml files: ' + str(total_yaml_num)
    print 'total .gradle files: ' + str(total_gradle_num)
    print 'total .dart files: ' + str(total_dart_num)
    print 'total .podspec files: ' + str(total_podspec_num)
    print 'total .md files: ' + str(total_md_num)


# 需要替换的字符串map
UPDATE_dict = {
    # pubspec.yaml
    "name: im_flutter_sdk": "name: agora_chat_sdk",
    
    # lib/src/agora_chat_sdk.dart
    "library im_flutter_sdk":"library agora_chat_sdk",
    "Easemob IM flutter SDK.":"agora chat flutter SDK.",
    "http://www.easemob.com/product/im":"https://www.agora.io",

    # agora_chat_sdk.dart
    "em_client":"chat_client",
    "em_chat_manager":"chat_manager",
    "em_contact_manager":"chat_contact_manager",
    "em_group_manager":"chat_group_manager",
    "em_push_manager":"chat_push_manager",
    "em_userInfo_manager":"chat_userInfo_manager",
    "em_domain_terms":"chat_domain_terms",
    "em_message":"chat_message",
    "em_group_message_ack":"chat_group_message_ack",
    "em_log":"chat_log",
    "em_listeners":"chat_listeners",
    "em_chat_room":"chat_room",
    "em_conversation":"chat_conversation",
    "em_cursor_result":"chat_cursor_result",
    "em_deviceInfo":"chat_deviceInfo",
    "em_error":"chat_error",
    "em_group":"chat_group",
    "em_options":"chat_options",
    "em_push_config":"chat_push_config",
    "em_page_result":"chat_page_result",
    "em_userInfo":"chat_userInfo",
    "em_chat_enums":"chat_enums",
    "em_transform_tools":"chat_transform_tools",
    "em_presence":"chat_presence",
    "em_file_message_body":"chat_file_message_body",
    "em_chat_thread":"chat_thread",
    "em_text_message_body":"chat_text_message_body",
    "em_image_message_body":"chat_image_message_body",
    "em_location_message_body":"chat_location_message_body",
    "em_voice_message_body":"chat_voice_message_body",
    "em_video_message_body":"chat_video_message_body",
    "em_custom_message_body":"chat_custom_message_body",
    "em_cmd_message_body":"chat_cmd_message_body",
    "em_status_listener":"chat_status_listener",
    "em_progress_manager":"chat_progress_manager",
    "em_event_keys":"chat_event_keys",
    "em_download_callback":"chat_download_callback",
    "em_chat_thread_event":"chat_thread_event",
    "em_channel_manager":"chat_channel_manager",
    "em_translate_language":"chat_translate_language",
    
    "em_extension":"chat_extension",
    "/im_flutter_sdk.dart":"/agora_chat_sdk.dart",
    "package:im_flutter_sdk":"package:agora_chat_sdk",
    "im_flutter_sdk:":"agora_chat_sdk:",

    #class name.
    "EMClient":"ChatClient",
    "EMMessageChatType":"ChatMessageChatType",
    "EMMessageDirection":"ChatMessageDirection",
    "EMMessageStatus":"ChatMessageStatus",
    "EMDownloadStatus":"ChatDownloadStatus",
    "EMMessageBodyType":"ChatMessageBodyType",
    "EMMessageStatusListener":"ChatMessageStatusListener",
    "EMMessage":"ChatMessage",
    "EMMessageBody":"ChatMessageBody",
    "EMTextMessageBody":"ChatTextMessageBody",
    "EMLocationMessageBody":"ChatLocationMessageBody",
    "EMFileMessageBody":"ChatFileMessageBody",
    "EMImageMessageBody":"ChatImageMessageBody",
    "EMVideoMessageBody":"ChatVideoMessageBody",
    "EMVoiceMessageBody":"ChatVoiceMessageBody",
    "EMCmdMessageBody":"ChatCmdMessageBody",
    "EMCustomMessageBody":"ChatCustomMessageBody",
    "EMOptions":"ChatOptions",
    "EMPushConfig":"ChatPushConfig",
    "EMPageResult":"ChatPageResult",
    "EMImPushStyle":"ChatPushStyle",
    "EMPushConfigExtension":"ChatPushConfigExtension",
    "EMChatRoom":"ChatRoom",
    "EMUserInfo":"ChatUserInfo",
    "EMImPushStyle":"ChatPushStyle",
    "EMConversationType":"ChatConversationType",
    "EMConversation":"ChatConversation",
    "EMConversationExtension":"ChatConversationExtension",
    "EMError":"ChatError",
    "EMMessageSearchDirection":"ChatMessageSearchDirection",
    "EMCursorResult":"ChatCursorResult",
    "EMDeviceInfo":"ChatDeviceInfo",
    "EMChatManagerListener":"ChatManagerListener",
    "EMGroupMessageAck":"ChatGroupMessageAck",
    "EMGroupStyle":"ChatGroupStyle",
    "EMGroup":"ChatGroup",
    "EMGroupPermissionType":"ChatGroupPermissionType",
    "EMGroupOptions":"ChatGroupOptions",
    "EMGroupSharedFile":"ChatGroupSharedFile",
    "EMContactGroupEvent":"ChatContactGroupEvent",
    "EMContactManager":"ChatContactManager",
    "EMChatManager":"ChatManager",
    "EMGroupManager":"ChatGroupManager",
    "EMPushManager":"ChatPushManager",
    "EMContactEventListener":"ChatContactEventListener",
    "EMContactChangeEvent":"ChatContactChangeEvent",
    "EMImPushConfig":"ChatPushConfig",
    "EMMethodChannel":"ChatMethodChannel",
    "EMDownloadCallback":"ChatDownloadCallback",
    "EMChatThread":"ChatThread",
    "EMCustomListener":"ChatCustomListener",
    "EMMultiDeviceListener":"ChatMultiDeviceListener",
    "EMMultiDevicesEvent":"ChatMultiDevicesEvent",
    "EMPresenceManagerListener":"ChatPresenceManagerListener",
    "EMTransformPlugin":"ChatTransformPlugin",
    "EMReactionPlugin":"ChatReactionPlugin",
    "EMModerationPlugin":"ChatModerationPlugin",
    "EMConnectionListener":"ChatConnectionListener",
    "EMSearchDirection":"ChatSearchDirection",
    "EMProgressManager":"ChatProgressManager",
    "EMChatRoom":"ChatRoom",
    "EMRoomManager":"ChatRoomManager",
    "EMPresence":"ChatPresence",
    "EMTranslateLanguage":"ChatTranslateLanguage",
    "EMContact":"Contact",
    "EMConnection":"Connection",
    "EMMultiDevice":"ChatMultiDevice",
    "EMChatEventHandler":"ChatEventHandler",
    "EMCombineMessageBody":"CombineMessageBody",
    

    #podspec
     "= 'im_flutter_sdk'":"= 'agora_chat_sdk'",

    #doc
    #"im_flutter_sdk":"agora_chat_sdk",
    
    "环信即时通讯":" Agora ",
}

# 将修改错误的再改回来
RE_BACK_dict = {
    "rootProject.name = 'agora_chat_sdk'":"rootProject.name = 'im_flutter_sdk'"
}


# 按照UPDATE_dict中的内容查找替换文件内容


def updateFile(file):
    """
    替换文件中的字符串
    :param file:文件名
    :param old_str:旧字符串
    :param new_str:新字符串
    :return:
    """
    file_data = ""
    with open(file, "r") as f:
        for line in f:
            for k in UPDATE_dict.keys():
                line = line.replace(k, UPDATE_dict.get(k))

            file_data += line

    with open(file, "w") as f:
        f.write(file_data)


def reBackFile(file):
    file_data = ""
    with open(file, "r") as f:
        for line in f:
            for k in RE_BACK_dict.keys():
                line = line.replace(k, RE_BACK_dict.get(k))

            file_data += line

    with open(file, "w") as f:
        f.write(file_data)



# 复制文件夹


def copyFolder(source, target):
    source_path = source
    target_path = target
    print 'begin copy ' + source
    print 'to         ' + target

    if not os.path.exists(target_path):
        # 如果目标路径不存在原文件夹的话就创建
        os.makedirs(target_path)

    if os.path.exists(source_path):
        # 如果目标路径存在原文件夹的话就先删除
        shutil.rmtree(target_path)

    shutil.copytree(source_path, target_path)
    print('copy dir finished!')


if __name__ == "__main__":
    main(sys.argv)
