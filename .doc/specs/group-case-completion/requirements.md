# Group 缺失 Case 补齐

## User Story

作为 Group 自动化测试维护者，我希望使用现有 Flutter SDK API 补齐可自动化的群组正常链路、状态组合和双端事件断言，使每条 case 都明确记录步骤、预期和严格断言，并以两台 Android 模拟器的真实 ADB/WebSocket 日志作为唯一事件字段依据。

## Acceptance Criteria（EARS）

1. 当 `autoAcceptGroupInvitation=false`、群设置 `inviteNeedConfirm=true` 且 A 邀请 B 时，测试应分别覆盖 B 显式接受和显式拒绝两条链路，并严格断言 A/B 双端真实同步响应、邀请事件和最终群成员状态。
2. 当 `autoAcceptGroupInvitation=true` 且群设置 `inviteNeedConfirm=true` 时，测试应覆盖自动接受邀请组合，并按真实日志断言 B 的自动接受事件和双方最终群状态。
3. 当依赖 `autoAcceptGroupInvitation` 的 case 结束时，无论测试成功或失败，测试都应将 B 的开关恢复为当前基线 `true`，避免污染后续 case。
4. 当 B 加入 `EMGroupStyle.PublicOpenJoin` 群时，测试应使用真实枚举映射 `style=3`，断言加入成功、双方真实事件和服务端成员状态；当 B 退出后，应断言退出成功、双方真实事件和服务端状态。
5. 当 B 尝试通过 `joinPublicGroup` 加入非 `PublicOpenJoin` 群时，测试应保留独立错误场景，并冻结真实错误码和描述，不得把该错误冒充公开群成功链路。
6. 当群成员经历邀请加入、移除、再次加入和主动退出等状态迁移时，测试应在必要的固定短暂等待后，对 `getJoinedGroups` 与 `getJoinedGroupsFromServer` 分别验证目标群的出现或消失，并关联本次动态 groupId。
7. 当创建至少两个公开群并使用较小 `pageSize` 查询时，测试应使用 `fetchPublicGroupsFromServer` 返回的真实非空 cursor 继续翻页，逐页严格断言响应结构和本次创建群的可追踪结果；若真实 cursor 为空，应保留 discovery 证据且不得伪造翻页。
8. 当群主 A 更新公告且 B 是群成员时，测试应断言同步响应、服务端公告值，并按真实 ADB 日志断言 A/B 哪一端收到 `onAnnouncementChangedFromGroup` 及其稳定字段。
9. 当管理员 B 更新公告且 A 是群主时，测试应覆盖群主/管理员角色组合，并按真实 ADB 日志断言双方事件行为和服务端公告值。
10. 当上传群共享文件时，测试 App 应提供 Android 设备本地可读文件路径，不得将 Python 宿主机路径直接传给 Android SDK。
11. 当群主或管理员上传并删除共享文件成功时，测试应覆盖操作者/观察者角色组合，严格断言同步响应、文件列表和 `onSharedFileAddedFromGroup` / `onSharedFileDeletedFromGroup` 的真实双端行为。
12. 当共享文件传入不存在的设备路径或群 ID 时，测试应保留独立异常场景，并冻结真实错误语义。
13. 当 SDK 只暴露 `onGroupStateChanged`/`onDisableChanged` 监听而没有群启用/禁用操作 API 时，测试不得伪造客户端触发链路；该项应继续记录所需 REST、管理后台或服务端前置。
14. 当新增或修改任一正常 case 时，case 函数前的文档字符串应明确写出前置条件、操作步骤、预期结果和严格断言点。
15. 当 discovery 日志中的字段具有动态性时，测试只能忽略 `sequence`、时间、动态路径、动态 URL 等经真实日志证明不稳定的字段；不得用类型检查、非空检查或 actual 自证 expected 替代业务断言。
16. 当任一操作可能在 A/B 两端产生事件时，测试应分别收集并断言双方真实行为，包括“收到指定事件”和经独立等待窗口确认“未收到指定事件”。
17. 当实现完成时，Group 台账应列出每个新增 case 的具体场景，并从 deferred 中移除已具备自动化前置的项目；测试名与台账对账应保持缺失 0、多余 0。
18. 当验证本批改动时，系统应先逐 case 运行 discovery 和 strict，再运行受影响文件及完整 `tests/group`；所有失败必须按真实响应诊断，不得通过放宽断言获得通过。
19. 当创建 `PrivateOnlyOwnerInvite(style=0)` 群时，测试应覆盖群主邀请成功、普通成员和管理员邀请被拒绝，并断言失败操作不会改变成员列表或产生成功事件。
20. 当创建 `PrivateMemberCanInvite(style=1)` 群时，测试应覆盖群主、普通成员和管理员邀请成功；普通成员邀请链路应使用 A/B 两台真实设备分别承担邀请方和受邀方，并校验双端事件与服务端成员状态。
21. 当创建 `PublicJoinNeedApproval(style=2)` 群时，测试应覆盖申请后群主同意、申请后群主拒绝、直接 `joinPublicGroup` 被拒绝，以及群主主动邀请用户加入。
22. 当创建 `PublicOpenJoin(style=3)` 群时，测试应覆盖直接加入成功，并覆盖错误调用 `requestToJoinPublicGroup` 的真实稳定语义。
23. 当 `joinPublicGroup` 或 `requestToJoinPublicGroup` 被用于不匹配的群类型时，测试应分别覆盖四种 style 的有效和无效映射，不得用一个私有群错误样本代表其他群类型。
24. 当入群申请被处理时，测试应覆盖合法原因、空原因、重复申请、有效群但无待处理申请、重复同意/拒绝和处理顺序冲突，并验证成员状态不会重复或回滚。
25. 当普通成员、管理员或非成员尝试处理入群申请时，测试应按 Dart API 公开权限和真实 ADB 行为冻结结果；若 Dart 方法注释与原生行为不一致，应保留严格 case 和失败证据。
26. 当处理入群邀请时，测试应覆盖有效邀请、有效群但无待处理邀请、错误 inviter、重复接受、拒绝后接受和接受后拒绝，并验证服务端成员状态与事件次数。
27. 当 `inviteNeedConfirm=false` 且受邀端 `autoAcceptGroupInvitation=false` 时，测试应验证受邀用户仍由服务端直接加入，且 case 结束后恢复设备 option 基线。
28. 当用户重复加入公开自由群、群已满或用户处于群黑名单时，测试应冻结接口结果，并验证成员数、成员列表及双方事件不出现重复或错误变化。
29. 当群主转让给普通成员或管理员时，测试应验证 A/B 双端 `onOwnerChangedFromGroup`、新旧 owner、管理员列表和成员列表；原群主应成为普通成员。
30. 当转让目标为空、为当前群主、非成员或不存在用户，或者调用方是普通成员、管理员或非成员时，测试应冻结成功/失败语义并验证 owner 不发生非预期变化。
31. 当群主完成转让后，新群主执行 owner-only API 应成功，原群主执行同一 API 应按普通成员权限处理。
32. 当调用 `removeMembers` 时，测试应覆盖群主移除普通成员、移除管理员、尝试移除当前群主、普通成员/管理员越权移除，以及包含有效成员、非成员和群主的混合批量请求。
33. 当 A 将群主转让给 B 后 B 移除原群主 A 时，测试应验证操作成功、A 收到 `onUserRemovedFromGroup`、B 收到成员退出事件，且服务端最终 owner/member/admin 状态准确。
34. 当当前群主调用 `leaveGroup` 时，测试应冻结必须先转让群主的错误语义；当原群主完成转让后主动退群时，测试应验证正常退出和双方事件。
35. 当新增矩阵 case 需要第三个账号形成 owner/member/invitee 角色时，可使用 `user_c` 作为服务端状态账号，但所有需要事件断言的操作双方必须由 deviceA/deviceB 两台真实设备承担。
36. 当用户决定暂时隔离已确认或待契约确认的 7 个 Group 场景时，测试应仅对对应参数添加带明确原因的 `skip`，保留原严格断言实现；其他矩阵参数不得被一并跳过，修复或契约确认后应删除对应 skip 并恢复验证。
37. 当测试发送群消息时，case 应归档在 `tests/group`，并对 `txt/file/image/video/voice/location/cmd/custom/combine` 九种公开发送类型分别覆盖发送响应、发送方 `onMessageSuccess` 和接收方消息回调。
38. 当群消息到达接收方时，测试应严格断言 `chatType=1`、`to/convId=groupId`、收发双方、方向、消息状态和类型特有 body；CMD 消息应通过 `onCmdMessagesReceived` 接收，其余类型应通过 `onMessagesReceived` 接收。
39. 当群消息需要群回执时，`ackGroupMessageRead` 与 `asyncFetchGroupAcks` 的正常和非法 ID 场景应归档在 `tests/group`，并继续使用真实动态 groupId/msgId 关联同步响应与双端消息事件。
40. 当 ChatThread case 需要群消息作为父消息时，ChatThread API 与群父消息前置链路应统一归档在 `tests/group`；父消息仍不得重复计为独立群消息发送 case，Chat 模块不得继续保留同一批 ChatThread 测试文件。
41. 当群消息目标为空或群不存在时，测试应使用文本消息覆盖共享群目标校验，关联临时 msgId 与异步失败终态，并确认另一真实设备未收到目标消息。
42. 当从未入群、主动退出或被群主移除的用户发送群消息时，测试应分别覆盖三种成员状态，冻结真实错误，并严格确认群主设备没有收到该消息。
43. 当群消息使用 `txt/location/cmd/custom/combine` 缺失类型必填字段或媒体四类型使用不存在设备路径时，测试应复用单聊已确认的构造边界，不因 `chatType=1` 重复测试与群权限无关的动态类型错误；仅在真实返回受 chatType 影响时保留独立 Group case。
44. 当共享目标和成员状态已经由文本消息覆盖时，九种类型正常矩阵与共享异常矩阵应分别统计；不得用笛卡尔积重复相同服务端权限语义，也不得因此漏掉群独有的未入群、退出后和被移除后状态。
