# iOS / Android 5.0 方法名与 callback 名映射

## 方法名映射

| 模块/能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| Group/注册回调 | addDelegate:delegateQueue: | addGroupChangeListener | SIGNATURE_DIFFERENCE |
| Group/移除回调 | removeDelegate: | removeGroupChangeListener | SIGNATURE_DIFFERENCE |
| Group/本地群列表 | getJoinedGroups | getAllGroups | SIGNATURE_DIFFERENCE |
| Group/按 ID 读本地群 | — | getGroup | ANDROID_ONLY |
| Group/清空本地群 | cleanAllGroupsFromDB | cleanAllGroupsFromLocal | SIGNATURE_DIFFERENCE |
| Group/创建群 | createGroupWithSubject:avatar:description:invitees:message:setting:completion: | createGroup / asyncCreateGroup | SIGNATURE_DIFFERENCE |
| Group/销毁群 | destroyGroup:finishCompletion: | destroyGroup / asyncDestroyGroup | SIGNATURE_DIFFERENCE |
| Group/添加成员 | addMembers:toGroup:message:completion: | addUsersToGroup / asyncAddUsersToGroup | SIGNATURE_DIFFERENCE |
| Group/专用邀请 API | addMembers:toGroup:message:completion: | inviteUser / asyncInviteUser | SIGNATURE_DIFFERENCE |
| Group/移除成员 | removeMembers:fromGroup:completion: | removeUserFromGroup / asyncRemoveUserFromGroup / removeUsersFromGroup / asyncRemoveUsersFromGroup | SIGNATURE_DIFFERENCE |
| Group/退出群 | leaveGroup:completion: | leaveGroup / asyncLeaveGroup | SIGNATURE_DIFFERENCE |
| Group/服务端群详情 | getGroupSpecificationFromServerWithId:completion: / getGroupSpecificationFromServerWithId:fetchMembers:completion: | getGroupFromServer / asyncGetGroupFromServer | SIGNATURE_DIFFERENCE |
| Group/已加入群数量 | getJoinedGroupsCountFromServerWithCompletion: | asyncGetJoinedGroupsCountFromServer | SIGNATURE_DIFFERENCE |
| Group/加入公开群 | joinPublicGroup:completion: | joinGroup / asyncJoinGroup | SIGNATURE_DIFFERENCE |
| Group/申请入群 | requestToJoinPublicGroup:message:completion: | applyJoinToGroup / asyncApplyJoinToGroup | SIGNATURE_DIFFERENCE |
| Group/改名称 | updateGroupSubject:forGroup:completion: | changeGroupName / asyncChangeGroupName | SIGNATURE_DIFFERENCE |
| Group/改头像 | updateGroupAvatar:groupId:completion: | changeGroupAvatar / asyncChangeGroupAvatar | SIGNATURE_DIFFERENCE |
| Group/改描述 | updateDescription:forGroup:completion: | changeGroupDescription / asyncChangeGroupDescription | SIGNATURE_DIFFERENCE |
| Group/更新群配置 | updateGroupWithId:types:configs:completion: | updateGroupConfigs / asyncUpdateGroupConfigs | SIGNATURE_DIFFERENCE |
| Group/更新群扩展 | updateGroupExtWithId:ext:completion: | updateGroupExtension / asyncUpdateGroupExtension | SIGNATURE_DIFFERENCE |
| Group/接受邀请 | acceptInvitationFromGroup:inviter:completion: | acceptInvitation / asyncAcceptInvitation | SIGNATURE_DIFFERENCE |
| Group/拒绝邀请 | declineGroupInvitation:inviter:reason:completion: | declineInvitation / asyncDeclineInvitation | SIGNATURE_DIFFERENCE |
| Group/批准入群申请 | approveJoinGroupRequest:sender:completion: | acceptApplication / asyncAcceptApplication | SIGNATURE_DIFFERENCE |
| Group/拒绝入群申请 | declineJoinGroupRequest:sender:reason:completion: | declineApplication / asyncDeclineApplication | SIGNATURE_DIFFERENCE |
| Group/屏蔽群消息 | blockGroup:completion: | blockGroupMessage / asyncBlockGroupMessage | SIGNATURE_DIFFERENCE |
| Group/取消屏蔽群消息 | unblockGroup:completion: | unblockGroupMessage / asyncUnblockGroupMessage | SIGNATURE_DIFFERENCE |
| Group/加入黑名单 | blockMembers:fromGroup:completion: | blockUser / asyncBlockUser / blockUsers / asyncBlockUsers | SIGNATURE_DIFFERENCE |
| Group/移出黑名单 | unblockMembers:fromGroup:completion: | unblockUser / asyncUnblockUser / unblockUsers / asyncUnblockUsers | SIGNATURE_DIFFERENCE |
| Group/取黑名单（legacy） | getGroupBlacklistFromServerWithId:pageNumber:pageSize:completion: | getBlockedUsers / asyncGetBlockedUsers | SIGNATURE_DIFFERENCE |
| Group/取黑名单 | getGroupBlacklistFromServerWithId:pageNumber:pageSize:completion: | fetchGroupBlackList / asyncFetchGroupBlackList | SIGNATURE_DIFFERENCE |
| Group/取成员 | getGroupMemberListFromServerWithId:cursor:pageSize:completion: | fetchGroupMembers / asyncFetchGroupMembers | SIGNATURE_DIFFERENCE |
| Group/取成员详情 | fetchGroupMemberInfoListFromServerWithGroupId:cursor:limit:completion: | asyncFetchGroupMembersInfo | SIGNATURE_DIFFERENCE |
| Group/转让群主 | updateGroupOwner:newOwner:completion: | changeOwner / asyncChangeOwner | SIGNATURE_DIFFERENCE |
| Group/加管理员 | addAdmin:toGroup:completion: | addGroupAdmin / asyncAddGroupAdmin | SIGNATURE_DIFFERENCE |
| Group/删管理员 | removeAdmin:fromGroup:completion: | removeGroupAdmin / asyncRemoveGroupAdmin | SIGNATURE_DIFFERENCE |
| Group/禁言成员 | muteMembers:muteMilliseconds:fromGroup:completion: | muteGroupMembers / asyncMuteGroupMembers | SIGNATURE_DIFFERENCE |
| Group/解除禁言 | unmuteMembers:fromGroup:completion: | unMuteGroupMembers / asyncUnMuteGroupMembers | SIGNATURE_DIFFERENCE |
| Group/取禁言列表（含过期时间） | fetchGroupMuteListFromServerWithId:pageNumber:pageSize:completion: | fetchGroupMuteList / asyncFetchGroupMuteList | SIGNATURE_DIFFERENCE |
| Group/取禁言列表（仅 ID） | getGroupMuteListFromServerWithId:pageNumber:pageSize:completion: | — | IOS_ONLY |
| Group/检查自己是否禁言 | isMemberInMuteListFromServerWithGroupId:completion: | asyncCheckIfInMuteList | SIGNATURE_DIFFERENCE |
| Group/取白名单 | getGroupWhiteListFromServerWithId:completion: | fetchGroupWhiteList | SIGNATURE_DIFFERENCE |
| Group/检查自己是否在白名单 | isMemberInWhiteListFromServerWithGroupId:completion: | checkIfInGroupWhiteList | SIGNATURE_DIFFERENCE |
| Group/加入白名单 | addWhiteListMembers:fromGroup:completion: | addToGroupWhiteList | SIGNATURE_DIFFERENCE |
| Group/移出白名单 | removeWhiteListMembers:fromGroup:completion: | removeFromGroupWhiteList | SIGNATURE_DIFFERENCE |
| Group/全员禁言 | muteAllMembersFromGroup:completion: | muteAllMembers | SIGNATURE_DIFFERENCE |
| Group/解除全员禁言 | unmuteAllMembersFromGroup:completion: | unmuteAllMembers | SIGNATURE_DIFFERENCE |
| Group/更新公告 | updateGroupAnnouncementWithId:announcement:completion: | updateGroupAnnouncement / asyncUpdateGroupAnnouncement | SIGNATURE_DIFFERENCE |
| Group/取公告 | getGroupAnnouncementWithId:completion: | fetchGroupAnnouncement / asyncFetchGroupAnnouncement | SIGNATURE_DIFFERENCE |
| Group/上传共享文件 | uploadGroupSharedFileWithId:filePath:progress:completion: | uploadGroupSharedFile / asyncUploadGroupSharedFile | SIGNATURE_DIFFERENCE |
| Group/共享文件列表 | getGroupFileListWithId:pageNumber:pageSize:completion: | fetchGroupSharedFileList / asyncFetchGroupSharedFileList | SIGNATURE_DIFFERENCE |
| Group/删除共享文件 | removeGroupSharedFileWithId:sharedFileId:completion: | deleteGroupSharedFile / asyncDeleteGroupSharedFile | SIGNATURE_DIFFERENCE |
| Group/下载共享文件 | downloadGroupSharedFileWithId:filePath:sharedFileId:progress:completion: | downloadGroupSharedFile / asyncDownloadGroupSharedFile | SIGNATURE_DIFFERENCE |
| Group/设置成员属性 | setMemberAttribute:userId:attributes:completion: | asyncSetGroupMemberAttributes | SIGNATURE_DIFFERENCE |
| Group/取单成员全部属性 | fetchMemberAttribute:userId:completion: | asyncFetchGroupMemberAllAttributes | SIGNATURE_DIFFERENCE |
| Group/取多成员指定属性 | fetchMembersAttributes:userIds:keys:completion: | asyncFetchGroupMembersAttributes | SIGNATURE_DIFFERENCE |
| Group/更新自己群名片 | updateGroupNamecard:namecard:completion: | asyncUpdateGroupNamecard | SIGNATURE_DIFFERENCE |
| Group/读群名片 | getGroupNamecardWithGroupId:userId: | getGroupNamecard | SIGNATURE_DIFFERENCE |
| Chatroom/注册回调 | addDelegate:delegateQueue: | addChatRoomChangeListener | SIGNATURE_DIFFERENCE |
| Chatroom/移除回调 | removeDelegate: | removeChatRoomChangeListener | SIGNATURE_DIFFERENCE |
| Chatroom/加入（基础） | joinChatroom:error: / joinChatroom:completion: | joinChatRoom | SIGNATURE_DIFFERENCE |
| Chatroom/加入（ext/离开其他房间） | joinChatroom:ext:leaveOtherRooms:completion: | joinChatRoom | SIGNATURE_DIFFERENCE |
| Chatroom/离开 | leaveChatroom:error: / leaveChatroom:completion: | leaveChatRoom | SIGNATURE_DIFFERENCE |
| Chatroom/公开聊天室分页 | getChatroomsFromServerWithPage:pageSize:error: / getChatroomsFromServerWithPage:pageSize:completion: | fetchPublicChatRoomsFromServer / asyncFetchPublicChatRoomsFromServer | SIGNATURE_DIFFERENCE |
| Chatroom/服务端详情 | getChatroomSpecificationFromServerWithId:error: / getChatroomSpecificationFromServerWithId:completion: / getChatroomSpecificationFromServerWithId:fetchMembers:completion: | fetchChatRoomFromServer / asyncFetchChatRoomFromServer | SIGNATURE_DIFFERENCE |
| Chatroom/按 ID 读本地聊天室 | — | getChatRoom | ANDROID_ONLY |
| Chatroom/改主题 | updateSubject:forChatroom:error: / updateSubject:forChatroom:completion: | changeChatRoomSubject / asyncChangeChatRoomSubject | SIGNATURE_DIFFERENCE |
| Chatroom/改描述 | updateDescription:forChatroom:error: / updateDescription:forChatroom:completion: | changeChatroomDescription / asyncChangeChatroomDescription | SIGNATURE_DIFFERENCE |
| Chatroom/取成员 | getChatroomMemberListFromServerWithId:cursor:pageSize:error: / getChatroomMemberListFromServerWithId:cursor:pageSize:completion: | fetchChatRoomMembers / asyncFetchChatRoomMembers | SIGNATURE_DIFFERENCE |
| Chatroom/禁言成员 | muteMembers:muteMilliseconds:fromChatroom:error: / muteMembers:muteMilliseconds:fromChatroom:completion: | muteChatRoomMembers / asyncMuteChatRoomMembers | SIGNATURE_DIFFERENCE |
| Chatroom/解除禁言 | unmuteMembers:fromChatroom:error: / unmuteMembers:fromChatroom:completion: | unMuteChatRoomMembers / asyncUnMuteChatRoomMembers | SIGNATURE_DIFFERENCE |
| Chatroom/转让所有者 | updateChatroomOwner:newOwner:error: / updateChatroomOwner:newOwner:completion: | changeOwner / asyncChangeOwner | SIGNATURE_DIFFERENCE |
| Chatroom/加管理员 | addAdmin:toChatroom:error: / addAdmin:toChatroom:completion: | addChatRoomAdmin / asyncAddChatRoomAdmin | SIGNATURE_DIFFERENCE |
| Chatroom/删管理员 | removeAdmin:fromChatroom:error: / removeAdmin:fromChatroom:completion: | removeChatRoomAdmin / asyncRemoveChatRoomAdmin | SIGNATURE_DIFFERENCE |
| Chatroom/取禁言列表 | getChatroomMuteListFromServerWithId:pageNumber:pageSize:error: / getChatroomMuteListFromServerWithId:pageNumber:pageSize:completion: | fetchChatRoomMuteList / asyncFetchChatRoomMuteList | SIGNATURE_DIFFERENCE |
| Chatroom/移除成员 | removeMembers:fromChatroom:error: / removeMembers:fromChatroom:completion: | removeChatRoomMembers / asyncRemoveChatRoomMembers | SIGNATURE_DIFFERENCE |
| Chatroom/加入黑名单 | blockMembers:fromChatroom:error: / blockMembers:fromChatroom:completion: | blockChatroomMembers / asyncBlockChatroomMembers | SIGNATURE_DIFFERENCE |
| Chatroom/移出黑名单 | unblockMembers:fromChatroom:error: / unblockMembers:fromChatroom:completion: | unblockChatRoomMembers / asyncUnBlockChatRoomMembers | SIGNATURE_DIFFERENCE |
| Chatroom/取黑名单 | getChatroomBlacklistFromServerWithId:pageNumber:pageSize:error: / getChatroomBlacklistFromServerWithId:pageNumber:pageSize:completion: | fetchChatRoomBlackList / asyncFetchChatRoomBlackList | SIGNATURE_DIFFERENCE |
| Chatroom/加入白名单 | addWhiteListMembers:fromChatroom:error: / addWhiteListMembers:fromChatroom:completion: | addToChatRoomWhiteList | SIGNATURE_DIFFERENCE |
| Chatroom/移出白名单 | removeWhiteListMembers:fromChatroom:error: / removeWhiteListMembers:fromChatroom:completion: | removeFromChatRoomWhiteList | SIGNATURE_DIFFERENCE |
| Chatroom/检查自己是否在白名单 | isMemberInWhiteListFromServerWithChatroomId:error: / isMemberInWhiteListFromServerWithChatroomId:completion: | checkIfInChatRoomWhiteList | SIGNATURE_DIFFERENCE |
| Chatroom/检查自己是否禁言 | isMemberInMuteListFromServerWithChatroomId:completion: | asyncCheckIfInMuteList | SIGNATURE_DIFFERENCE |
| Chatroom/取白名单 | getChatroomWhiteListFromServerWithId:error: / getChatroomWhiteListFromServerWithId:completion: | fetchChatRoomWhiteList | SIGNATURE_DIFFERENCE |
| Chatroom/全员禁言 | muteAllMembersFromChatroom:error: / muteAllMembersFromChatroom:completion: | muteAllMembers | SIGNATURE_DIFFERENCE |
| Chatroom/解除全员禁言 | unmuteAllMembersFromChatroom:error: / unmuteAllMembersFromChatroom:completion: | unmuteAllMembers | SIGNATURE_DIFFERENCE |
| Chatroom/更新公告 | updateChatroomAnnouncementWithId:announcement:error: / updateChatroomAnnouncementWithId:announcement:completion: | updateChatRoomAnnouncement / asyncUpdateChatRoomAnnouncement | SIGNATURE_DIFFERENCE |
| Chatroom/取公告 | getChatroomAnnouncementWithId:error: / getChatroomAnnouncementWithId:completion: | fetchChatRoomAnnouncement / asyncFetchChatRoomAnnouncement | SIGNATURE_DIFFERENCE |
| Chatroom/批量设置属性 | setChatroomAttributes:attributes:autoDelete:completionBlock: | asyncSetChatroomAttributes | SIGNATURE_DIFFERENCE |
| Chatroom/设置单属性 | setChatroomAttribute:key:value:autoDelete:completionBlock: | asyncSetChatroomAttribute | SIGNATURE_DIFFERENCE |
| Chatroom/强制批量设置属性 | setChatroomAttributesForced:attributes:autoDelete:completionBlock: | asyncSetChatroomAttributesForced | SIGNATURE_DIFFERENCE |
| Chatroom/强制设置单属性 | setChatroomAttributeForced:key:value:autoDelete:completionBlock: | asyncSetChatroomAttributeForced | SIGNATURE_DIFFERENCE |
| Chatroom/按 keys 取属性 | fetchChatroomAttributes:keys:completion: | asyncFetchChatroomAttributesFromServer | SIGNATURE_DIFFERENCE |
| Chatroom/取全部属性 | fetchChatroomAllAttributes:completion: | asyncFetchChatRoomAllAttributesFromServer | SIGNATURE_DIFFERENCE |
| Chatroom/批量删属性 | removeChatroomAttributes:attributes:completionBlock: | asyncRemoveChatRoomAttributesFromServer | SIGNATURE_DIFFERENCE |
| Chatroom/删单属性 | removeChatroomAttribute:key:completionBlock: | asyncRemoveChatRoomAttributeFromServer | SIGNATURE_DIFFERENCE |
| Chatroom/强制批量删属性 | removeChatroomAttributesForced:attributes:completionBlock: | asyncRemoveChatRoomAttributesFromServerForced | SIGNATURE_DIFFERENCE |
| Chatroom/强制删单属性 | removeChatroomAttributeForced:key:completionBlock: | asyncRemoveChatRoomAttributeFromServerForced | SIGNATURE_DIFFERENCE |
| Multi-device/注册回调 | addMultiDevicesDelegate:delegateQueue: | addMultiDeviceListener | SIGNATURE_DIFFERENCE |
| Multi-device/移除回调 | removeMultiDevicesDelegate: | removeMultiDeviceListener | SIGNATURE_DIFFERENCE |
| Multi-device/取已登录设备 | getLoggedInDevicesFromServerWithUserId:token:completion: | fetchLoggedInDevicesFromServerWithToken | SIGNATURE_DIFFERENCE |
| Multi-device/踢指定设备 | kickDeviceWithUserId:token:resource:completion: | kickDeviceWithToken | SIGNATURE_DIFFERENCE |
| Multi-device/踢所有设备 | kickAllDevicesWithUserId:token:completion: | kickAllDevicesWithToken | SIGNATURE_DIFFERENCE |
| Multi-device/取当前设备信息 | getDeviceConfig: | — | IOS_ONLY |

## Callback 名映射

| 模块/能力 | iOS 名 | Android 名 | 分类 |
|---|---|---|---|
| Group/收到群邀请 | groupInvitationDidReceive:groupName:inviter:message: | onInvitationReceived | SIGNATURE_DIFFERENCE |
| Group/收到入群申请 | joinGroupRequestDidReceive:user:reason: | onRequestToJoinReceived | SIGNATURE_DIFFERENCE |
| Group/入群申请获批 | joinGroupRequestDidApprove: | onRequestToJoinAccepted | SIGNATURE_DIFFERENCE |
| Group/入群申请被拒 | joinGroupRequestDidDecline:reason:decliner:applicant: | onRequestToJoinDeclined | SIGNATURE_DIFFERENCE |
| Group/群邀请被接受 | groupInvitationDidAccept:invitee: | onInvitationAccepted | SIGNATURE_DIFFERENCE |
| Group/群邀请被拒 | groupInvitationDidDecline:invitee:reason: | onInvitationDeclined | SIGNATURE_DIFFERENCE |
| Group/自动接受邀请入群 | didJoinGroup:inviter:message: | onAutoAcceptInvitationFromGroup | SIGNATURE_DIFFERENCE |
| Group/当前用户被移除或群销毁 | didLeaveGroup:reason: | onUserRemoved / onGroupDestroyed | SIGNATURE_DIFFERENCE |
| Group/群列表更新 | groupListDidUpdate: | — | IOS_ONLY |
| Group/成员加入禁言列表 | groupMuteListDidUpdate:addedMutedMembers:muteExpire: | onMuteListAdded | SIGNATURE_DIFFERENCE |
| Group/成员移出禁言列表 | groupMuteListDidUpdate:removedMutedMembers: | onMuteListRemoved | SIGNATURE_DIFFERENCE |
| Group/成员加入白名单 | groupWhiteListDidUpdate:addedWhiteListMembers: | onWhiteListAdded | SIGNATURE_DIFFERENCE |
| Group/成员移出白名单 | groupWhiteListDidUpdate:removedWhiteListMembers: | onWhiteListRemoved | SIGNATURE_DIFFERENCE |
| Group/全员禁言状态变化 | groupAllMemberMuteChanged:isAllMemberMuted: | onAllMemberMuteStateChanged | SIGNATURE_DIFFERENCE |
| Group/添加管理员 | groupAdminListDidUpdate:addedAdmin: | onAdminAdded | SIGNATURE_DIFFERENCE |
| Group/移除管理员 | groupAdminListDidUpdate:removedAdmin: | onAdminRemoved | SIGNATURE_DIFFERENCE |
| Group/群主变化 | groupOwnerDidUpdate:newOwner:oldOwner: | onOwnerChanged | SIGNATURE_DIFFERENCE |
| Group/成员加入 | userDidJoinGroup:users: | onMembersJoined | SIGNATURE_DIFFERENCE |
| Group/成员退出 | userDidLeaveGroup:users: | onMembersExited | SIGNATURE_DIFFERENCE |
| Group/公告更新 | groupAnnouncementDidUpdate:announcement: | onAnnouncementChanged | SIGNATURE_DIFFERENCE |
| Group/共享文件新增 | groupFileListDidUpdate:addedSharedFile: | onSharedFileAdded | SIGNATURE_DIFFERENCE |
| Group/共享文件删除 | groupFileListDidUpdate:removedSharedFile: | onSharedFileDeleted | SIGNATURE_DIFFERENCE |
| Group/群详情变化 | groupSpecificationDidUpdate: | onSpecificationChanged | SIGNATURE_DIFFERENCE |
| Group/群禁用状态变化 | groupStateChanged:isDisabled: | onStateChanged | SIGNATURE_DIFFERENCE |
| Group/成员属性变化 | onAttributesChangedOfGroupMember:userId:attributes:operatorId: | onGroupMemberAttributeChanged | SIGNATURE_DIFFERENCE |
| Group/群名片变化 | onUserGroupNamecardChanged:userId:namecard: | onUserGroupNamecardUpdated | SIGNATURE_DIFFERENCE |
| Chatroom/被移除、销毁或离线 | didDismissFromChatroom:reason: | onChatRoomDestroyed / onRemovedFromChatRoom | SIGNATURE_DIFFERENCE |
| Chatroom/成员加入 | userDidJoinChatroom:user:ext: | onMemberJoined | SIGNATURE_DIFFERENCE |
| Chatroom/成员加入（deprecated 无 ext） | userDidJoinChatroom:user: | — | IOS_ONLY |
| Chatroom/成员退出 | userDidLeaveChatroom:user: | onMemberExited | SIGNATURE_DIFFERENCE |
| Chatroom/成员加入禁言列表 | chatroomMuteListDidUpdate:addedMutedMembers: | onMuteListAdded | SIGNATURE_DIFFERENCE |
| Chatroom/成员加入禁言列表（deprecated） | chatroomMuteListDidUpdate:addedMutedMembers:muteExpire: | — | IOS_ONLY |
| Chatroom/成员移出禁言列表 | chatroomMuteListDidUpdate:removedMutedMembers: | onMuteListRemoved | SIGNATURE_DIFFERENCE |
| Chatroom/成员加入白名单 | chatroomWhiteListDidUpdate:addedWhiteListMembers: | onWhiteListAdded | SIGNATURE_DIFFERENCE |
| Chatroom/成员移出白名单 | chatroomWhiteListDidUpdate:removedWhiteListMembers: | onWhiteListRemoved | SIGNATURE_DIFFERENCE |
| Chatroom/全员禁言状态变化 | chatroomAllMemberMuteChanged:isAllMemberMuted: | onAllMemberMuteStateChanged | SIGNATURE_DIFFERENCE |
| Chatroom/添加管理员 | chatroomAdminListDidUpdate:addedAdmin: | onAdminAdded | SIGNATURE_DIFFERENCE |
| Chatroom/移除管理员 | chatroomAdminListDidUpdate:removedAdmin: | onAdminRemoved | SIGNATURE_DIFFERENCE |
| Chatroom/所有者变化 | chatroomOwnerDidUpdate:newOwner:oldOwner: | onOwnerChanged | SIGNATURE_DIFFERENCE |
| Chatroom/公告更新 | chatroomAnnouncementDidUpdate:announcement: | onAnnouncementChanged | SIGNATURE_DIFFERENCE |
| Chatroom/详情变化 | chatroomSpecificationDidUpdate: | onSpecificationChanged | SIGNATURE_DIFFERENCE |
| Chatroom/属性更新 | chatroomAttributesDidUpdated:attributeMap:from: | onAttributesUpdate | SIGNATURE_DIFFERENCE |
| Chatroom/属性删除 | chatroomAttributesDidRemoved:attributes:from: | onAttributesRemoved | SIGNATURE_DIFFERENCE |
| Multi-device/好友事件 | multiDevicesContactEventDidReceive:username:ext: | onContactEvent | SIGNATURE_DIFFERENCE |
| Multi-device/群事件 | multiDevicesGroupEventDidReceive:groupId:ext: | onGroupEvent | SIGNATURE_DIFFERENCE |
| Multi-device/Thread 事件 | multiDevicesChatThreadEventDidReceive:threadId:ext: | onChatThreadEvent | SIGNATURE_DIFFERENCE |
| Multi-device/历史消息移除 | multiDevicesMessageBeRemoved:deviceId: | onMessageRemoved | SIGNATURE_DIFFERENCE |
| Multi-device/会话事件 | multiDevicesConversationEvent:conversationId:conversationType: | onConversationEvent | SIGNATURE_DIFFERENCE |
| Multi-device/旧免打扰事件 | multiDevicesUndisturbEventNotifyFormOtherDeviceData: | — | IOS_ONLY |

