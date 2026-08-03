# FIX 7.31 — 待修复清单

日期：2026-07-31

## ✅ 1. Case 断言校准（新路径返回值与旧断言不一致）

新路径跳过 Dart 业务层，直接暴露 Wrapper 原始返回值，部分 Case 断言基于旧路径（Dart 层加工后）的值编写，需要逐条校准。

| Case | API | 旧值 | 新值 | 根因 |
|---|---|---|---|---|
| test_chat_send_and_received | hasDeliverAck | false | true | Dart EMMessage 默认值 false，新路径直连 Wrapper 暴露 SDK 真实值 |
| test_presence_publish_subscribe_query_unsubscribe | unsubscribe result | None | {} | EMWrapperCallBack 固定返回空 Map，Dart 层 unsubscribe 为 void 丢弃返回值 |

校准原则：以新路径（Wrapper decode 后）实际返回值为准。

> ⚠️ 补充发现（2026-07-31）：
> - `fetch_support_languages`：Matrix/Manifest 中 API 名写错（`fetchSupportedLanguages` → `fetchSupportLanguages`），已修。
> - `MessageManager.getChatThread`：cmd 名应为 `chatThread`（Java 常量名 ≠ 实际值），已修。
> - `recallMessage` 返回 `505 Service is not enabled`：**真实功能问题**，不能改断言，需查服务端撤回功能是否启用。
> - `getMessage`/`removeReaction` 无效 id 返回 `{}` 而非 `None`：需判断是"查不到"还是 Wrapper bug。
>
> **2026-07-31 进一步定位（4 条失败分类）**：
> | Case | 真实返回 | 类型 | 该改谁 | 状态 |
> |---|---|---|---|---|
> | getMessage/removeReaction 无效 id | 稳定返回 `{}`（Wrapper.onSuccess(null) 包成空 Map） | Dart 层归一化差异 | ✅ 改 Case 期望 `{}` | **已修，通过** |
> | fetch_support_languages | `{"code": 303, "description": "Unknown server error"}` | **翻译功能服务端未开启** | 不改 Case，提示开启翻译 | ⏳ 待服务端开启 |
> | translate_recalled_message | 撤回返回 505 + `data.value`（旧期望 `data.infos`） | **撤回功能服务端未开启** + 结构差异 | 不改 Case，提示开启撤回 | ⏳ 待服务端开启 |
>
> **getMessage/removeReaction 修正说明**：`Wrapper.onSuccess(result, key, null)` 对 null 返回空 Map `{}`（非 null），Dart 业务层此前归一化为 null。新路径暴露 `{}` 是确定性行为，Case 断言改为期望 `{}` 合理。
>
> **fetch_support_languages / translate_recalled 判断**：依据 `.doc/specs/chat-case-batch1/requirements.md` 第 8、16 条——翻译、撤回等依赖服务端开关的能力未开启时，不得把"功能关闭"的错误固化为预期，应记录所需开关并提示开启后验证。当前 AppKey 未开启翻译（303）和撤回（505）能力。
>
> **2026-07-31 新增：Case 使用了生产 Wrapper 不支持的 cmd**（Python 枚举有、生产 Wrapper 无）：
> | cmd | 原因 | 处理 |
> |---|---|---|
> | `sendMessageWithType` | Dart 层封装方法，最终调 sendMessage，原生无此 cmd | 改 Case 用 sendMessage，或标记 Skip |
> | `fetchAllContactIds` | 生产 Wrapper 未实现 | 确认是否需要实现，或标记 Skip |
> | `getAllContactIds` | 生产 Wrapper 未实现 | 同上 |
> | `updateAPNsPushToken` | iOS 推送 token，Android 天然无 | 标记 Skip |
>
> **2026-07-31 新增：group 模块事件命名差异（已修复）**
> - **根因**：Python `GroupChangeEvent` 标准 = `onGroupXxx` = 生产 Wrapper 发的；但部分 Case 硬编码了 SDK 原生名 `onXxxFromGroup`，匹配不上
> - **已修复**：`tests/group/group_helpers.py` 加 `normalize_group_event()`（白名单映射 `onGroupXxx → onXxxFromGroup`，20 个），在 collect/assert 阶段归一化，并把 matched 事件的 eventType 改写为归一化值
> - 验证：test_group_create_group / test_group_members.py 全过
> - 映射原则：只转白名单（Case 用 FromGroup 形式的事件），onGroupDestroyed/onGroupSpecificationDidUpdate 等保持原样
> - 不能动生产 Wrapper
>
> **2026-07-31 新增：group 事件 data 字段名差异（已修复）**
> - Wrapper 对 `onGroupAdminAdded` 事件用 `administrator` 字段，Case 候选缺 → 已加 `administrator` 到 `_assert_member_field`
> - Wrapper 用 `operatorId`，Case 候选是 `operator` → 已加 `operatorId` 到各 operator 候选元组
> - 验证：test_group_admin_update_announcement_notifies_owner 通过
>
> **2026-07-31 新增：group 事件映射补全（已修复，白名单 23 个）**
> - `normalize_group_event` 白名单现含 23 个映射（`onGroupXxx → onXxxFromGroup` + 特殊映射）
> - 特殊映射：`onGroupAttributesChangedOfMember → onAttributesChangedOfGroupMember`、`onGroupWhiteListAdded → onAllowListAddedFromGroup`、`onGroupWhiteListRemoved → onAllowListRemovedFromGroup`
> - 验证：test_group_moderation.py 15 passed
>
> **2026-07-31 补充：群组事件名统一为 onGroupXxx（已重构）**
> - 确认 Android 与 iOS Wrapper 事件名一致，均为 `onGroupXxx`，与 Python GroupChangeEvent 枚举一致
> - **已删掉 group_helpers 归一化**（Case 硬编码 FromGroup → onGroupXxx，397 处批量替换）
> - Case 统一认 onGroupXxx，Wrapper 也发 onGroupXxx，直接匹配，跨平台一致
> - **后续发现**：`onGroupMemberExited` SDK 回调只带 groupId+member（无 groupName），已拆出单独校验 member
> - **残留事件名修正**：`onSpecificationDidUpdate` → `onGroupSpecificationDidUpdate`、`onAllGroupMemberMuteStateChanged` → `onGroupAllMemberMuteStateChanged`（11 处）
> - ⏳ 待办：test_group_join_and_leave_public_group 疑似加入事件残留时序问题
> - ⏳ 待办：shared_files 上传不传 filePath，依赖"默认素材"（旧路径隐式行为，新路径无默认文件 → 上传返回 true 但 fileId 无效 → remove 401）
> - ⏳ 待办：test_group_joined_lists memberList 字段（成员离开后服务端列表未更新，数据时序）
> - ⏳ 待办：test_group_invitation_explicit_accept 的 assert_no_group_event(device_b) 断言可能错（B 入群会收到成员加入事件，不该断言 B 未收到）
> - ⏳ 待办：join_application 事件 data 字段差异（onGroupRequestToJoinDeclined 无 groupName，但 Case 断言带 groupName）
> - ⏳ 待办：exceptions_lifecycle 群名超长期望报错 300，实际服务端接受（服务端行为变化）
>
> **group 模块整体（2026-08-03 验证）**：约 30 个文件跑过，绝大多数通过（43 passed 3 skipped、34 passed 15 skipped 等批次）；剩余失败集中在 join_application 事件字段、shared_files 上传 filePath、事件残留时序、群名超长服务端行为，均属长尾适配或服务端行为，非框架/命名问题
>
> **2026-07-31 新增：contact 模块 6 个失败 = 服务端黑名单服务未开通**
> - 关键错误：`getBlockListFromServer → {"code": 300, "description": "easemob-demo#wanganqi2 block service not allow"}`
> - 当前 AppKey `wanganqi2` **未开通黑名单服务**（block service）
> - 受影响：add_user_to_block_list / get_block_list_from_server / block_list_flow_then_unblock / remove_from_block_list / get_block_list_from_db / friend_info_sync
> - **处理**：不改 Case，提示服务端开通黑名单服务
>
> **2026-07-31 新增：`hasDeliverAck` 真实语义调查（结论）**
> - `hasDeliverAck` 原生映射 `message.isDelivered()`（EMHelper.java:592），原生 toJson **总是**输出该字段
> - **`isDelivered()` 语义**：消息是否已送达接收方；`onMessageSuccess` = "发送成功" ≠ "已送达"，正常时送达还没发生 → `isDelivered() = false`
> - **Case 期望按消息生命周期阶段分**（不是按方向）：
>   - onMessageSuccess（发送方刚发）→ False（未送达，语义正确）
>   - onMessagesReceived（接收方收到）→ True（已发回执）
>   - onMessagesDelivered（发送方收到回执）→ True
> - **稳定性测试结果**：`test_chat_get_unread_count_positive_then_zero` 连跑 3 次全 PASSED，事件里 onMessageSuccess 稳定 False、Received/Delivered 稳定 True
> - **结论**：Case 期望 False 是对的；偶发 True 是**原生 SDK 竞态**——`onMessageSuccess` 回调时送达恰好已完成（消息快/网络快）。不是 Wrapper bug、不是框架 bug、不是 Case 写错
> - **修法**：`onMessageSuccess` 阶段的 `hasDeliverAck` 属时序敏感字段（类似 localTime/serverTime），应进该阶段断言的 ignore_keys；`onMessagesReceived`/`onMessagesDelivered` 阶段稳定 True，保留断言
> - **注意**：不能全局忽略 hasDeliverAck，只能放宽 onMessageSuccess 阶段，否则会漏掉真实异常
>
> **补充理解：生产 Wrapper 的编解码职责**
> - MethodChannel 按 manager 分通道（`com.chat.im/chat_manager`），cmd 在通道内按 `call.method` 分发
> - Wrapper = 编解码层：`JSON → 原生对象`（MessageHelper.toNativeMessage 等）→ 调原生 SDK → `原生对象 → Map/JSON`（toJson）回传
> - `on*` 是原生主动发给 Flutter 的事件标识，不是被调用的 cmd，不在 Matrix
> - "不支持某个 cmd" = 该 manager 通道内没有这个 cmd 的 switch 分支 → unsupported
> - `sendMessageWithType` 等 cmd 是 Dart 层独有的封装方法（内部转成 EMMessage 再调 sendMessage），原生 Wrapper 无此入口 → 新路径（跳过 Dart 层）下必然 Skip
>
> 其余 `on*` cmd 是事件监听方法，不在 Matrix 属正常。

## ✅ 2. AC-09 多设备推送 — 根因已定位：B 模拟器内存不足

`test_third_party_message_reaches_both_same_account_devices`：B 发送成功（onMessageSuccess），但只有 device_a_sec 收到 onMessagesReceived，device_a 未收到。

- 根因：**device_b（5556）AVD 只有 2GB 内存** → IM 心跳超时 → 频繁 onDisconnected → 消息投递失败/请求超时
- 已修复：三个 AVD（Pixel_5/5_2/5_3）内存全部调到 4096MB
- 验证：调内存后 `test_chat_ack_read_strict.py` 2 passed，连接稳定

## ✅ 3. APK 重 build

- TestControlBridge 已改为**不输出 capabilities 字段**（由 Manifest + Matrix 管理）
- Manifest 已同步 258 个 API（含命名修正）
- RunnerInfo.toJson() 空 capabilities 时不输出该字段
- **待办：重新 build APK 使改动生效**（改了 TestControlBridge.java + runner_info.dart）

```bash
cd im_flutter_test && flutter build apk --flavor sdk423 --debug
```

## ✅ 4. launch race — 已修复

`android_device.py` launch 时，旧任务恢复的 Intent 会覆盖带 runner 参数的新 Intent，导致 App 回到 config.yaml 默认 URL/topic（runnerId 变成默认值）。

- 已修复：force-stop 后 `sleep(2)` 等旧任务恢复完 + `am start` 加 `CLEAR_TASK`（0x4000）清任务栈
- 验证：framework 17 passed

## ⬜ 5. 设备池平台匹配

Spec §3.1 要求的设备池尚未实现，当前 `ensure_started()` 只从在线设备里随便挑，不看 platform。

- 现状：单平台（全 Android）场景没问题；iOS + Android 混合会挑错平台
- 设备匹配只认 platform（+ 系统版本/状态），**不认 sdk_version** —— sdk_version 由安装的 APK（Artifact）决定，不是设备属性
- 目标：Scenario 声明 platform → 从对应平台池挑空闲设备；不匹配报 Environment Error
- 方案：先做 platform 过滤（防呆），完整设备池等 iOS 入场再做

## ⬜ 6. Allure 自动生成

当前跑 pytest 不传 `--alluredir` 不生成报告，需手动 `allure generate`。

- 目标：加 `--allure-open` 参数，跑完自动 `allure generate` + 打开浏览器
- 结果目录按 runId 分目录，避免覆盖
- `allure-results/` 与 `allure-report/` 已加入 .gitignore
- ✅ 已加：Case 结束时 dump 未消费事件到 Allure（`drain_pending_events`），便于定位等待事件超时

## ⬜ 7. 新增（2026-07-31）

- **能力一致性：Matrix/Manifest/Runner 三方命名对齐** — 已修 2 处命名错误，需长期维护"只改 Matrix，Manifest 自动生成"
- **Manifest 自动生成** — 构建脚本从 Matrix + APK 自动生成 Manifest，避免手写对不上



