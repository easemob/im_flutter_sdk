# Group 模块失败 Cases

> 记录真实 A/B Android 设备上已复现的历史严格失败。按当前用户决定，这 7 个参数场景已暂时
> 标记为 skip；原严格断言和 ADB 证据保留，本轮只采集 ADB 日志，不采集 tracelog。

| # | Case | 预期 | 实际 | ADB / pytest 证据 |
|---|---|---|---|---|
| 1 | `test_group_invitation_explicit_decline_when_auto_accept_disabled` | B 调用 `declineInvitationFromGroup` 后，A 在 10 秒内收到 `onInvitationDeclinedFromGroup(groupId, invitee=B, reason=explicit-decline)`；双方无加入事件，成员数仍为 1。 | B 返回 `result=null`，双方无加入事件且成员数为 1，但 A 在 10 秒内收到的目标事件为 `[]`。 | `out/group_matrix_20260723/join_requests_invites_deviceA.log`、`join_requests_invites_deviceB.log`、`join_requests_and_invitations_final.xml` |
| 2 | `test_group_request_to_join_rejects_every_non_approval_style[public-open]` | `requestToJoinPublicGroup` 仅适用于 `PublicJoinNeedApproval(style=2)`；对 `PublicOpenJoin(style=3)` 应返回 `603 permission`，无加入事件，成员状态不变。 | 返回 `result=null`；A 收到 `onMembersJoinedFromGroup` 和 `onMemberJoinedFromGroup`，服务端确认 B 已直接成为成员。 | `out/group_matrix_20260723/style_contract_failures_deviceA.log`、`style_contract_failures_deviceB.log`、`style_contract_failures_final.xml` |
| 3 | `test_group_member_invitation_permission_depends_on_style[inviter-user-private-owner-admin-denied]` | `PrivateOnlyOwnerInvite(style=0)` 只允许群主邀请；管理员 B 调用 `inviterUser` 应返回 `603 invite is not allowed`，C 不入群。 | 返回 `result=true`；A 收到 C 的两类加入事件，服务端成员数变为 3，C 已入群。 | `out/group_matrix_20260723/style_contract_failures_deviceA.log`、`style_contract_failures_deviceB.log`、`style_admin_invite_failures_final.xml` |
| 4 | `test_group_member_invitation_permission_depends_on_style[add-members-private-owner-admin-denied]` | `PrivateOnlyOwnerInvite(style=0)` 的管理员 B 调用 `addMembers` 应返回 `603 invite is not allowed`，C 不入群。 | 返回 `result=true`；A 收到 C 的两类加入事件，服务端成员数变为 3，C 已入群。 | 同上 |
| 5 | `test_group_invitation_wrong_inviter_does_not_consume_pending[accept]` | B 用错误 `inviter=C` 接受 A 发出的邀请时应失败且不得消费 pending；随后使用正确 `inviter=A` 仍应接受成功。 | 错误 inviter 已接受邀请并使 B 入群；随后正确 inviter 接受返回 `601 already joined`。 | `out/group_matrix_20260723/invitation_state_full_deviceA.log`、`invitation_state_full_deviceB.log`、`invitation_state_matrix_final.xml` |
| 6 | `test_group_invitation_wrong_inviter_does_not_consume_pending[decline]` | B 用错误 `inviter=C` 拒绝 A 发出的邀请时应失败且不得消费 pending；随后使用正确 `inviter=A` 仍应接受成功。 | 错误 inviter 已拒绝并消费 pending；随后正确 inviter 接受返回 `603 is not in the invitee list`，B 未入群。 | 同上 |
| 7 | `test_group_join_application_processing_permission_by_role[admin-accept]` | 管理员 B 同意 C 的入群申请后，C 收到的 `onRequestToJoinAcceptedFromGroup.data.accepter` 应为实际审批人 B。 | 接口处理成功且 C 正常入群，但回调 `accepter` 实际为群主 A。 | `out/group_matrix_20260723/application_state_full_deviceA.log`、`application_state_full_deviceB.log`、`application_state_full_final.xml` |

## Bridge / SDK 链路复核

- 不存在遗漏的统一开关。邀请场景已显式设置 `autoAcceptGroupInvitation=false` 和
  `inviteNeedConfirm=true`，且 B 能收到邀请事件；同一 listener 的其他群事件也能正常送达。
- `im_flutter_test` 已注册并原样转发 `onInvitationDeclinedFromGroup`、
  `onRequestToJoinAcceptedFromGroup` 等事件，不会改写 `invitee/accepter/reason`。

## 群组离线专项结果

- 第六阶段新增的 31 个离线再上线 items 在补齐真实回放事件断言后，联合 strict 为
  `31 passed, 1 warning in 391.78s`，没有新增未解决的严格失败。
- 离线邀请拒绝仍复现本文件 Case 1 的既有问题：拒绝接口成功、最终成员状态正确，但邀请方
  没有拒绝结果事件。离线 case 按真实日志断言负向事件窗口和最终状态，不重复新增失败编号。
- 离线 read-ack 在发送方重登后需先调用 `asyncFetchGroupAcks` 同步服务端状态，随后
  `groupAckCount=1`；测试不校验回执详情，未扩大用户限定的 count-only 范围。
- 名称/描述更新、禁言成员检查和白名单列表均使用本轮真实 ADB/WebSocket 返回收紧；这些
  case 已通过，不以 discovery 阶段的预设差异记录为失败。
- 证据目录：`out/group_offline_20260730_185752/`。

| Case | 复核结论 | 定位依据 |
|---|---|---|
| 1 | **Android Flutter SDK 适配错误，不能归因于开关。** Dart 发送 `inviter`，Android 插件却读取 `userId`，最终把 `null` 作为 inviter 传给原生 `asyncDeclineInvitation`；这足以解释接口成功但邀请方收不到拒绝回调。 | `group_manager.dart` 的 `declineInvitation` 写入 `inviter`；Android `GroupManagerWrapper.declineInvitationFromGroup` 读取 `userId`；iOS 同接口正确读取 `inviter`。 |
| 2 | **不是 WebSocket bridge。** Android 插件未校验群类型，直接调用 `asyncApplyJoinToGroup`；ADB 中 `/apply` 返回 200，随后服务端下发 `APPLY_ACCEPT` 并使 B 入群。若 API 契约坚持只允许 style 2，则属于 Android SDK/服务端契约问题；没有相关客户端开关。 | Android `requestToJoinPublicGroup` 仅透传 groupId/reason；ADB 已确认 REST 200、双方加入事件和成员快照。 |
| 3、4 | **不是 bridge，也不是开关。** 两个 API 均真实发到服务端，`/invite` 返回 200，服务端下发 C 加入事件。当前行为是管理员在 `PrivateOnlyOwnerInvite` 中也可邀请。若枚举文档“仅群主”是权威契约，则是权限实现与文档不一致；若产品定义管理员具备群主管理权限，则应调整 case 预期。 | Android 分别调用 `asyncInviteUser` 和 `addUsersToGroup`；ADB 群快照确认 B 为 admin、`isMemberAllowToInvite=false`，调用仍成功。 |
| 5 | **不是 bridge。** ADB 原生日志明确打印传入 `inviter=test0723user3`，说明错误 inviter C 已传到原生 SDK；`/invite_verify` 仍返回 200。当前服务端实际按 groupId + 当前 invitee 处理 pending，是否必须校验 inviter 需要 API 契约确认。 | Android `acceptInvitationFromGroup` 正确读取并传递 `inviter`；ADB 有 `nativeacceptInvitationFromGroup ... inviter:test0723user3`。 |
| 6 | **与 Case 1 是同一个 Android 适配错误。** 测试传入的错误 inviter C 在 Android 插件中被丢弃并替换为 `null`，因此当前结果不能用于证明服务端是否会拒绝错误 inviter。修正字段后必须重跑。 | Android `declineInvitationFromGroup` 错读 `userId`；Dart/iOS 均使用 `inviter`。 |
| 7 | **不是 bridge，原生 Android SDK 回调字段与原始事件不一致。** ADB 的原始 MSYNC `APPLY_ACCEPT.from` 是管理员 B，但 `_EMAGroupListenerImpl` 生成的 callback 已把 `accepter` 变为群主 A；Flutter SDK和测试 bridge 都只是原样转发。 | 原始 MSYNC：`from=test0723user2`；最终事件：`accepter=test0723user1`；Android listener 与 `event_bridge_handler.dart` 均未改写字段。 |

### 当前定性

- 可直接定位为 Android Flutter SDK 适配问题：Case 1、6（同一字段名错误）。
- 原生 SDK/服务端真实行为与当前公开契约存在明显差异：Case 2、7。
- 真实行为已确认，但需要产品/API 契约确认后决定修实现还是改预期：Case 3、4、5。

## 统计

- 新增四个矩阵历史 strict 结果：`66 items`，其中 `60 passed, 6 failed`。
- 原邀请/申请文件历史 strict 结果：`11 items`，其中 `10 passed, 1 failed`。
- 当前 7 个已知问题参数均已精确标记为 skip；定向验证结果为 `7 skipped`。
