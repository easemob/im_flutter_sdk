# Android 4.23 新路径待解决问题清单

日期：2026-08-03
范围：新路径（跳过 Dart 业务层，直连生产 Wrapper）在 Android 4.23 上全模块验证发现的问题

## 说明

- **新路径** = Python → WS → im_flutter_test → im_flutter_sdk_interface → 生产 Wrapper → 原生 SDK
- 分类：
  - `待适配`：Case 或框架需改，方向已定
  - `服务端`：需服务端开通能力或确认行为
  - `待确认`：需进一步调查
  - `已知跳过`：Case 设计时主动 skip（SDK bug/契约待确认）

---

## 📦 group 模块

### 待适配
| Case | 问题 | 方向 |
|---|---|---|
| join_application_state_matrix | `onGroupRequestToJoinDeclined` 事件无 groupName，Case 断言带 | Case 调整断言 |
| shared_files | upload 不传 filePath 依赖旧默认素材，新路径无默认 → fileId 无效 → remove 401 | Case 传真实 filePath |

### 待确认（事件时序）
| Case | 现象 |
|---|---|
| join_and_leave_public_group | 加入事件延迟，落到后续 `assert_no_group_event` 窗口 |
| joined_lists_follow_invite | memberList 字段成员离开后未更新（数据时序） |

### 服务端行为
| Case | 现象 |
|---|---|
| exceptions_lifecycle 群名超长 | Case 期望报错 300，实际服务端接受（服务端行为变化） |

### 已知跳过（Case 设计时主动 skip，非新路径问题）
| 位置 | 理由 |
|---|---|
| join_requests:192 | 已知 Android adapter bug：declineInvitationFromGroup 丢 inviter |
| invitation_state_matrix:154 | 已知 inviter 处理缺口 |
| join_application:491 | 已知 SDK bug：admin accepter 被报为群主 |
| style_membership:170 | SDK/服务端契约：apply API 自动加入公开群 |
| style_membership:479 | 待确认：style 0 admin 能否邀请 |
| test_group.py:116 | 未复现"本地人数不正确" |

---

## 💬 chat 模块

### 待服务端
| Case | 问题 |
|---|---|
| fetch_support_languages | 翻译功能未开通（code 303） |
| translate_recalled / recallMessage | 撤回功能未开通（code 505） |

### 待适配
| Case | 问题 | 方向 |
|---|---|---|
| hasDeliverAck 相关（约 153 处断言） | onMessageSuccess 阶段 isDelivered() 偶发 true（SDK 时序竞态） | onMessageSuccess 阶段 hasDeliverAck 进 ignore_keys |

---

## 👤 contact 模块

### 待服务端
| Case | 问题 |
|---|---|
| block_list 相关（6 个） | 黑名单服务未开通（`block service not allow`，code 300） |

---

## 🔔 push 模块

### 待确认
| Case | 问题 |
|---|---|
| updateFCMPushToken 更新 token | Case 期望 result 带 code 110（Notifier name empty），实际响应含 error 字段，两次运行结构不一致 |

---

## 💬 chatroom 模块

### 待确认（事件推送）
| Case | 问题 |
|---|---|
| test_chatroom_callbacks member_exited / removed_and_destroyed | `create_chatroom_or_skip` 用 REST 创建聊天室，owner A 的 SDK 客户端未 join → A 收不到"成员退出/被移除"事件。疑似 Case 假设问题，待确认 |
| test_chatroom_members join_with_ext | 观察端未收到带 ext 的成员加入回调 |

---

## 👤 client 模块

---

## 📋 框架/协议层待办

| 项 | 状态 |
|---|---|
| 4 个 Wrapper 不支持 cmd（fetchAllContactIds/getAllContactIds/sendMessageWithType/updateAPNsPushToken） | 待确认原生 SDK 是否支持，或标记 skip |
| 设备池平台匹配（Spec §3.1） | 待实现（先 platform 过滤，完整池等 iOS） |
| Allure 自动生成（--allure-open） | 待实现 |
