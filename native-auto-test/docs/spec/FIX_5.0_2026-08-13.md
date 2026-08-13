# 5.0 适配与测试修复记录（2026-08-13）

> 本文件按模块记录本轮 5.0 适配的修复、决策与遗留事项。
> 测试链路：Python → WS → im_flutter_test → interface → wrapper → 原生（不经 im_flutter_sdk Dart 层）。

---

## 概览

- **wrapper**：透传原生为原则；修复用错方法/漏转发字段；残留协议本地兜底保留（发布 SDK 兼容，测试不调）。
- **矩阵/manifest**：残留协议（5.0 移除）全部删除；manifest 由 `generate_manifests.py` 从矩阵自动生成。
- **case**：残留协议 → 5.0 本地协议 / REST / skip（无对应能力）；5.0 语义断言修正。
- **连锁根因**：5.0 统一 token 登录（直接传密码被拒 202）→ 所有登录改 token。

---

## Client 模块

- **acceptInvitationAlways 修复**（Android `ClientWrapper.java`）：
  - 误用 `setAutoAcceptGroupInvitation`（群邀请）→ 改 `setAcceptInvitationAlways`（好友邀请，对齐 iOS `autoAcceptFriendInvitation`）。
- **登录统一 token**（5.0 `loginWithToken` 只接受 token，传密码被拒 202）：
  - `_switch_user`（group 3 文件 + chat conversation）→ `fetch_user_token` + `loginWithToken(token)`。
  - conftest `_do_login`（登录重试）→ token。
  - conftest `_login_one` else 分支（use_token=False 保险）→ token。
  - `test_friend_info_sync`（4 处登出重登）→ token（+ helper `_token_for`）。
  - `test_client.py` 重新登录 → token。
  - 保留：`test_client_login_invalid_password`（故意错误密码测登录失败，5.0 密码登录 202 也是失败，意图符合）。
- **createAccount fallback 删除**（conftest 2 处 + global_login_logout）：5.0 移除客户端注册，用户预创建仅走 REST。
- **updateRequireAckSetting**：残留（5.0 移除全局回执开关），参数化项去掉；iOS wrapper 造 null 成功（no-op）。

## Contact 模块

- **getAllContactsFromServer → getAllContactsFromDB**（5.0 本地读取）：
  - `test_contact.py` 9 处、chat/conftest 辅助、conversation_cursor_pagination 辅助、remaining 伪同步步骤删。
- **fetchAllContactIds / getAllContactIds / fetchContacts**（5.0 无分页拉联系人）→ skip（专门测残留）。
- **friend_info_sync 密码登录 → token**（登出后重登）。

## Chat 模块

- **残留 server 会话协议 → loadAllConversations**（5.0 本地会话）：
  - 辅助轮询（4 文件）+ `test_chat_get_conversations_from_server_success`（去 skip）。
- **fetchConversationsByOptions → loadAllConversations**（手段，验证 pin/mark 状态）。
- **分页/cursor 专门 case → skip**（5.0 无分页拉会话）：cursor/page/pinned 边界。
- **reportMessage → skip**（5.0 移除）：s2 4 case + report_message_boundaries 整文件。
- **conversation cursor 分页 case → skip**（`test_chat_conversation_pinned_and_marked_cursor_pagination`）。
- **chatroom 公告事件 groupId→roomId**（此前）。

## Chatroom 模块

- **createChatRoom / destroyChatRoom**（5.0 移除，服务端管理）：
  - 专门测客户端创建/销毁 → skip。
  - 手段（销毁验证事件 / 销毁后 fetch）→ REST（`safe_delete_chatroom` → `delete_chat_room`）。
- **ChatRoomManagerWrapper 编译修复**：匿名类 `onSuccess` → `ChatRoomManagerWrapper.this.onSuccess`（2 处）。
- **whiteList 操作透传原生 room**（此前）。

## Group 模块

- **iOS GroupHelper fromJson 补映射**（此前）：`allowInvites`（style>0）+ `joinApprovalRequired`（style==2）。
- **isMemberOnly → isPublic**（5.0 移除 isMemberOnly）：
  - case 断言改 `isPublic: False`（joined_groups/exceptions_lifecycle/roles）。
  - 两端 wrapper 群 toJson 补输出 `isPublic` + `joinApprovalRequired`（原生值，透传）。
- **required_all 去单数事件**（5.0 只发复数 `onGroupMembersJoined`）：lifecycle/announcement/owner_removal/invitation_state_matrix。
- **mute 事件字段 mutes**：group_helpers 候选字段加 `mutes`（两端 wrapper 一致）。
- **_fetch_group 快照 is_member_allow_to_invite=True**（style=2 审批群 → 原生 allowInvites=true）。
- **declined 事件 groupName**：
  - Android wrapper 补转发 `groupName`（原生回调有，漏写）。
  - case 删 `"groupName": None`（两端差异：iOS 原生无 groupName）。
- **createGroup 边界（exceptions_lifecycle）**：群名 256/512 字符 → 5.0 原生接受（创建成功），期望成功（不再报 300）；已验证 Android + iOS。
- **getJoinedGroupsFromServer → getJoinedGroups**（本地已加入群）。
- **getPublicGroupsFromServer → skip**（5.0 无公开群列表）。
- **destroyGroup/removeMembers → @YES**（对齐 Android wrapper true）。

## 矩阵 / manifest / 协议

- **android.yaml 289→284 / ios.yaml 263→258**：删残留协议（getConversationsFromServer×3、getPublicGroupsFromServer、getAllContactsFromServer、startCallback、fetchContacts、fetchConversationsByOptions、getJoinedGroupsFromServer 等 16 个）。
- **android-5.0.0.json manifest 289→284**（capabilities 与矩阵对齐；ios manifest 为 `['*']` 通配符无需同步）。
- **manifest 生成**：`python3 native-auto-test/scripts/generate_manifests.py --platform android [--version X]`。
- **capability 豁免**：conftest `_TEST_SUPPORT_CMDS = {"startCallback"}`（测试支撑 cmd 不参与 capability 检查，否则全 skip）。
- **协议映射验证**：case 的 (manager, cmd) 两端归属 0 错配；wrapper 调用全在 5.0 原生（无 4.23 残留方法名）。
- **protocol-android-ios-5.0-pure-native-map.md 评估**：API 表 0 错误；Event 表漏 iOS-only 好友同步事件（onFriendStartSync/onFriendSyncFailed/onFriendSyncFinished）—— 待补。

## 追加修复（2026-08-13 晚，group 全量失败 triage）

全量 `tests/group`（25 failed）triage：17 个环境连锁（单跑全过）+ 8 个真实问题（已修）。

- **多端 fixture 变量名不一致（4 NameError）**：
  - `test_group_join_requests_and_invitations.py`：`request_to_join_and_accept/decline_success` 签名补 `device_b_sec`（body 用了但签名没声明）。
  - `test_group_metadata.py`：`update_subject/update_description` body `sec_b` → `device_b_sec`（签名有但变量名写错）。
- **单数事件残留（5.0 只发复数，批量修漏网）**：
  - `request_to_join_and_accept_success`：删单数 `onGroupMemberJoined` 断言（KeyError）。
  - `invitation_explicit_accept_when_auto_accept_disabled`：`accepted_event_types` 去单数（required_all 会挂）。
  - `joined_lists_follow_invite_remove_readd_and_member_leave`：`exited_event_types` 去单数 `onGroupMemberExited`。
- **isMemberAllowToInvite（style=2 审批群 allowInvites=true）**：`request_to_join_and_accept/decline_success` 最终快照断言补 `is_member_allow_to_invite=True`。
- **message_ack_boundary_methods**：`ackGroupMessageRead` 非法 msgId 5.0 原生本地校验 → 110 "messages is empty"（原 500 断言错误）；wrapper 透传（本地 getMessage=null → 空列表 → asyncSendMessageReadReceipts([])）。
- **onGroupAutoAcceptInvitation 只回投主端**（WS-DUMP 实证）：`invitation_auto_accept_when_confirmation_required` 副端改由 `onGroupMembersJoined` 验证 auto-accept 生效；`assert_no_group_event` 范围收窄为仅邀请接受事件；已记 consistency.md。
- **joined_lists 投影**：`_joined_group_expected` 补 `joinApprovalRequired: False`（wrapper 透传原生新增输出）+ `memberList` 参数化（邀请后含成员）。
- **环境连锁确认（非回归）**：owner_removal ×14（Network is unavailable，sequence 448-462 连续）+ fetch_members_info/mute_list 超时 —— 单跑全部通过。

## 环境 / 连锁问题（非 SDK/case）

- **登录 202（User authentication failed）**：5.0 `loginWithToken` 只接受 token，直接传密码被拒 → 所有登录改 token（见 Client 模块）。
- **chat thread 305（thread not open）**：测试环境未开通 thread 功能（服务端配置）→ 需开通或 skip。
- **createGroup -1 / 600 got None（全量）**：长时间/跨文件连锁（登录/服务端），单跑正常 → 分批跑。
- **`getUnreadMessageCount` 免打扰过滤**：透传原生（5.0 行为由原生决定）。

## 遗留事项

- [ ] Event 表补 iOS-only 好友同步 3 事件（onFriendStartSync / onFriendSyncFailed / onFriendSyncFinished）。
- [ ] chat thread case（305）：服务端开通 thread 功能后跑。
- [ ] 全量重跑（分文件汇总）确认最终状态（本轮 group 真实失败已清零：8 修 + 17 连锁单跑过）。
- [ ] 矩阵改动后跑 `generate_manifests.py` 同步 manifest（规范）。
